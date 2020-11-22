//
//  AnimeInfoTableViewController.swift
//  Kuro
//
//  Created by Talha Rahman on 11/19/20.
//

import UIKit
import Foundation
import AVFoundation

private var post_query = """
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

public struct DetailedAniList : Decodable {
    let genres: [String]
    let averageScore: Int?
    let coverImage: [String : URL]
    let episodes: Int?
    let id: Int
    let nextAiringEpisode: [String : Int]?
    let rankings: [[String : JsonGeneric?]]?
    let season: String?
    let seasonYear: Int?
    let title: [String : String?]
    let description: String
    let status: String
    
    // type: "RATED" or "POPULAR"
    func getRank(_ type: String) -> String? {
        var season: String?
        var year = 0
        var rank = 0
        if let rankings = rankings {
            for ranking in rankings {
                if ranking["type"]??.stringValue != type {
                    continue
                }
                if ranking["allTime"]??.boolValue == true {
                    return "#\(ranking["rank"]!!.intValue!) All Time"
                }
                
                if year < (ranking["year"]??.intValue)! {
                    year = (ranking["year"]!!.intValue)!
                    season = ranking["season"]??.stringValue
                    rank = (ranking["rank"]??.intValue)!
                }
            }
        }
        if let season = season {
            return "#\(rank) \(season) \(year)"
        }
        if year != 0 {
            return "#\(rank) \(year)"
        }
        return nil
    }
}

class AnimeInfoTableViewController: UITableViewController {
    var tmpImg: UIImage?
    var anime_info: DetailedAniList?
    var desc: NSAttributedString?
    
    var query_variables: [String: Any] = [
        "id" : 1
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiQuery()
        
        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(self.favorite))
        self.navigationItem.rightBarButtonItem = favoriteButton
        
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
        let parameterDic: [String : Any] = ["query" : post_query, "variables" : query_variables]

        let url = URL(string: "https://graphql.anilist.co")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameterDic, options: [])

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : [String : Any]]
//                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    let show = json["data"]!["Media"]!
                    let jsonData = try JSONSerialization.data(withJSONObject: show, options: .prettyPrinted)
                    self.anime_info = try JSONDecoder().decode(DetailedAniList.self, from: jsonData)
                    
                    //debugging
//                    print(self.anime_info?.rankings as Any)
//                    print(self.anime_info?.rankings![0]["allTime"]!.intValue)
//                    print("Highest Rated \(String(describing: self.anime_info?.getRank("RATED")))")
//                    print("Popular \(String(describing: self.anime_info?.getRank("POPULAR")))")
//
//                    // html to string
                    let descData = self.anime_info!.description.data(using: .utf16)!
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
            
            if let anime_info = anime_info {
                switch anime_info.status {
                case "RELEASING":
                    imageCell.animeAiringStatusLabel.text = "Airing"
                    
                    let nextEpisode = anime_info.nextAiringEpisode!
                    if let totalEpisodes = anime_info.episodes {
                        imageCell.animeEpisodeLabel.text = "\(nextEpisode["episode"]!) / \(totalEpisodes)"
                    } else {
                        imageCell.animeEpisodeLabel.text = "\(nextEpisode["episode"]!) / ?"
                    }
                case "FINISHED":
                    imageCell.animeAiringStatusLabel.text = "Completed"
                    imageCell.animeEpisodeLabel.text = "\(anime_info.episodes!)"
                case "NOT_YET_RELEASED":
                    imageCell.animeAiringStatusLabel.text = "UNRELEASED"
                default:
                    imageCell.animeAiringStatusLabel.text = "CANCELLED"
                }

                imageCell.animeFormatLabel.text = anime_info.rankings![0]["format"]!!.stringValue
                
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
            }
            
            cell = imageCell
        case 1:
            let tagsCell = tableView.dequeueReusableCell(withIdentifier: TagsTableViewCell.identifier, for: indexPath) as! TagsTableViewCell
            if let anime_info = anime_info {
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
    
}
