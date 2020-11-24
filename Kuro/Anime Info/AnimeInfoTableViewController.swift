//
//  AnimeInfoTableViewController.swift
//  Kuro
//
//  Created by Talha Rahman on 11/19/20.
//

import UIKit
import Foundation
import AVFoundation

private var postQuery = """
        query ($id: Int) {
              Media (id: $id) {
                  averageScore
                  coverImage {
                      large
                  }
                  genres
                  episodes
                  id
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
                        format
                        context
                        season
                        year
                  }
                  nextAiringEpisode {
                        episode
                  }
                  status
              }
          }
        """

class AnimeInfoTableViewController: UITableViewController {
    var tmpImg: UIImage?
    var animeInfo: DetailedAniList?
    var desc: NSAttributedString?
    
    var queryVariables: [String: Any] = [
        "id" : 1
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiQuery()
        
        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(self.favorite))
        self.navigationItem.rightBarButtonItem = favoriteButton
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ImageTableViewCell.nib(), forCellReuseIdentifier: ImageTableViewCell.identifier)
        tableView.register(TagsTableViewCell.nib(), forCellReuseIdentifier: TagsTableViewCell.identifier)
        tableView.register(DescriptionTableViewCell.nib(), forCellReuseIdentifier: DescriptionTableViewCell.identifier)
    }
    
    @objc func favorite() {
        self.navigationItem.rightBarButtonItem!.image = UIImage(systemName: "star.fill")
        print("test")
        AudioServicesPlaySystemSound(SystemSoundID(1111)) // 1054 bell / 1111 confirm noise?
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
//                    print(show)
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

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        switch indexPath.row {
        case 0:
            let imageCell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.identifier, for: indexPath) as! ImageTableViewCell
            imageCell.configure(with: tmpImg!)
            
            if let anime_info = animeInfo {
                switch anime_info.status {
                case "RELEASING":
                    imageCell.animeAiringStatusLabel.text = "Airing"
                    
                    let nextEpisode = anime_info.nextAiringEpisode!
                    if let totalEpisodes = anime_info.episodes {
                        imageCell.animeEpisodeLabel.text = "\(nextEpisode["episode"]! - 1) / \(totalEpisodes)"
                    } else {
                        imageCell.animeEpisodeLabel.text = "\(nextEpisode["episode"]! - 1) / ?"
                    }
                case "FINISHED":
                    imageCell.animeAiringStatusLabel.text = "Completed"
                    imageCell.animeEpisodeLabel.text = "\(anime_info.episodes!)"
                case "NOT_YET_RELEASED":
                    imageCell.animeAiringStatusLabel.text = "Unreleased"
                default:
                    imageCell.animeAiringStatusLabel.text = "Cancelled"
                }
                
                if anime_info.rankings.count > 0 {
                    imageCell.animeFormatLabel.text = anime_info.rankings[0]["format"]??.stringValue
                } else if anime_info.episodes! == 1 {
                    imageCell.animeFormatLabel.text = "Movie"
                }
                
                if let season = anime_info.season, let year = anime_info.seasonYear {
                    imageCell.animeSeasonLabel.text = "\(season) \(year)"
                } else {
                    imageCell.animeSeasonLabel.text = "No Season \\ Year"
                }
                
                imageCell.animeRatingLabel.text = anime_info.getRank("RATED")
                imageCell.animePopularityLabel.text = anime_info.getRank("POPULAR")
                
                if let score = anime_info.averageScore {
                    imageCell.animeScoreLabel.text = String(score)
                } else {
                    imageCell.animeScoreLabel.text = "-1" // make invis for release
                }
                imageCell.animeScoreLabel.backgroundColor = .darkGray
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
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 1 {
//            return 44.0
//        }
//        return UITableView.automaticDimension
//    }
    
}
