//
//  AnimeInfoTableViewController.swift
//  Kuro
//
//  Created by Talha Rahman on 11/19/20.
//

import UIKit
import Foundation
import AVFoundation
import CoreData

private var postQuery = """
        query ($id: Int) {
              Media (id: $id) {
                  averageScore
                  genres
                  episodes
                  season
                  seasonYear
                  title {
                      romaji
                      english
                  }
                  description(asHtml: true)
                  rankings {
                        rank
                        type
                        allTime
                        season
                        year
                  }
                  nextAiringEpisode {
                        episode
                  }
                  status
                  format
              }
          }
        """

class AnimeInfoTableViewController: UITableViewController {
    var tmpImg: UIImage?
    var animeInfo: DetailedAniList?
    var desc: NSAttributedString?
    var savedAnime: Anime?
    var queryVariables: [String: Int] = [
        "id" : 1
    ]
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiQuery()
        
        do {
            let animeList: [Anime] = try context.fetch(Anime.fetchRequest())
            
            for anime in animeList {
                let id = queryVariables["id"]
                if anime.id == id!{
                    savedAnime = anime
                }
            }
        } catch {
            print(error.localizedDescription)
        }

        let symbol: String = savedAnime != nil ? "star.fill" : "star"
        
        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: symbol), style: .plain, target: self, action: #selector(self.favorite))
        self.navigationItem.rightBarButtonItem = favoriteButton
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ImageTableViewCell.nib(), forCellReuseIdentifier: ImageTableViewCell.identifier)
        tableView.register(TagsTableViewCell.nib(), forCellReuseIdentifier: TagsTableViewCell.identifier)
        tableView.register(DescriptionTableViewCell.nib(), forCellReuseIdentifier: DescriptionTableViewCell.identifier)
    }
    
    @objc func favorite() {
        let symbol: String = savedAnime != nil ? "star" : "star.fill"
        self.navigationItem.rightBarButtonItem!.image = UIImage(systemName: symbol)
        print("favorited")
        AudioServicesPlaySystemSound(SystemSoundID(1111)) // 1054 bell / 1111 confirm noise?
        
        if let savedAnime = savedAnime {
            self.context.delete(savedAnime)
        } else {
            let anime = Anime(context: self.context)
            anime.name = title
            
            if let animeInfo = animeInfo {
                anime.id = Int32(queryVariables["id"]!)
                
                if let score = animeInfo.averageScore {
                    anime.score = Int16(score)
                }
                anime.type = animeInfo.format
            }
            
            if let imageData = tmpImg?.pngData() {
                anime.image = imageData
            }
            savedAnime = anime
        }
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func apiQuery() {
        let parameterDic: [String : Any] = ["query" : postQuery, "variables" : queryVariables]

        let url = URL(string: "https://graphql.anilist.co")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameterDic, options: [])

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : [String : Any]]
                    let show = json["data"]!["Media"]!
                    let jsonData = try JSONSerialization.data(withJSONObject: show, options: .prettyPrinted)
                    self.animeInfo = try JSONDecoder().decode(DetailedAniList.self, from: jsonData)
                    
//                    // html to string
                    let descData = self.animeInfo!.description.data(using: .utf16)!
                    let attributedString = try? NSAttributedString(data: descData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                    self.desc = attributedString
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    print("54: \(error)")
                }
            }
        }.resume()
    }
}

extension AnimeInfoTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        switch indexPath.row {
        case 0:
            let imageCell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.identifier, for: indexPath) as! ImageTableViewCell
            imageCell.configure(with: tmpImg!)
    
            if let animeInfo = animeInfo {
                switch animeInfo.status {
                case "RELEASING":
                    imageCell.animeAiringStatusLabel.text = "Airing"
                    
                    let nextEpisode = animeInfo.nextAiringEpisode!
                    if let totalEpisodes = animeInfo.episodes {
                        imageCell.animeEpisodeLabel.text = "\(nextEpisode["episode"]! - 1) / \(totalEpisodes)"
                    } else {
                        imageCell.animeEpisodeLabel.text = "\(nextEpisode["episode"]! - 1) / ?"
                    }
                case "FINISHED":
                    imageCell.animeAiringStatusLabel.text = "Completed"
                    imageCell.animeEpisodeLabel.text = "\(animeInfo.episodes!)"
                case "NOT_YET_RELEASED":
                    imageCell.animeAiringStatusLabel.text = "Unreleased"
                default:
                    imageCell.animeAiringStatusLabel.text = "Cancelled"
                }
                
                switch animeInfo.format {
                case "TV_SHORT":
                    imageCell.animeFormatLabel.text = "TV Short"
                case "MOVIE":
                    imageCell.animeFormatLabel.text = "Movie"
                default:
                    imageCell.animeFormatLabel.text = animeInfo.format
                }
                
                if let season = animeInfo.season, let year = animeInfo.seasonYear {
                    imageCell.animeSeasonLabel.text = "\(season.lowerAndCapitalize()) \(year)"
                } else {
                    imageCell.animeSeasonLabel.text = ""
                }
                
                imageCell.animeRatingLabel.text = animeInfo.getRank("RATED")
                imageCell.animePopularityLabel.text = animeInfo.getRank("POPULAR")
                
                if let score = animeInfo.averageScore {
                    imageCell.animeScoreLabel.text = String(score)
                } else {
                    imageCell.animeScoreLabel.text = ""
                }
            }
            cell = imageCell
        case 1:
            let tagsCell = tableView.dequeueReusableCell(withIdentifier: TagsTableViewCell.identifier, for: indexPath) as! TagsTableViewCell
            if let anime_info = animeInfo {
                tagsCell.configure(with: anime_info.genres)
            }
            cell = tagsCell
        case 2:
            let descriptionCell = tableView.dequeueReusableCell(withIdentifier: DescriptionTableViewCell.identifier, for: indexPath) as! DescriptionTableViewCell
            if let desc = desc {
                descriptionCell.configure(with: desc)
            }
            cell = descriptionCell
        default:
            cell = nil
        }
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
