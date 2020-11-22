//
//  queries.swift
//  Kuro
//
//  Created by Talha Rahman on 11/2/20.
//

import Foundation

let query = """
query ($id: Int, $page: Int, $perPage: Int, $search: String) {
  Page (page: $page, perPage: $perPage) {
          pageInfo {
              total
              currentPage
              lastPage
              hasNextPage
              perPage
          }
          media (id: $id, search: $search) {
              id
              title {
                  romaji
                  english
                  native
              }
              averageScore
              meanScore
              seasonYear
          }
      }
  }
"""

let variables: [String: Any] = [
    "search": "Fate",
    "page": 1,
    "perPage": 5
]
let parameterDic: [String : Any] = ["query" : query, "variables" : variables]


let query2 = """
query ($id: Int) { # Define which variables will be used in the query (id)
  Media (id: $id, type: ANIME) { # Insert our variables into the query arguments (id) (type: ANIME is hard-coded in the query)
    id
    title {
      romaji
      english
      native
    }
    season
    seasonYear
    genres
    averageScore
    popularity
    description
    coverImage {
        large
    }
}
}
"""

let parameterDic2: [String : Any] = ["query" : query2, "variables" : ["id" : 5114]]


//
//  TrendingCollectionViewController.swift
//  Kuro
//
//  Created by Talha Rahman on 10/31/20.
//

import UIKit

private let reuseIdentifier = "AnimeCollectionViewCell"
private let cellSize = CGSize(width: 202, height: 295)

private var post_query = """
        query ($id: Int, $page: Int, $perPage: Int, $sort: [MediaSort], $genre: String, $type: MediaType, $season: MediaSeason, $seasonYear: Int, $isAdult: Boolean) {
            Page (page: $page, perPage: $perPage) {
                  media (id: $id, sort: $sort, genre: $genre, type: $type, season: $season, seasonYear: $seasonYear, isAdult: $isAdult) {
                      id
                      title {
                          romaji
                          english
                      }
                      coverImage {
                          large
                      }
                  }
              }
          }
        """

//public struct AniList: Decodable {
//    let id: Int
//    let title: [String : String?]
//    let coverImage: [String : URL]
//}

// OLD TRENDING

//class AnimeCollectionViewController: UICollectionViewController {
//    var newTitle: String?
//    var anime_list: Array<AniList> = []
//
//    var query_variables: [String: Any] = [
//        "page": 1,
//        "perPage": 50,
//        "type": "ANIME",
//        "sort": "TRENDING_DESC",
//        "isAdult": false
//    ]
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        apiQuery()
//        if newTitle != nil {
//            title = newTitle
//        }
//        print(query_variables)
//
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = cellSize
//        collectionView.collectionViewLayout = layout
//        collectionView.register(AnimeCollectionViewCell.nib(), forCellWithReuseIdentifier: reuseIdentifier)
//    }
//
//    func apiQuery() {
//        let parameterDic: [String : Any] = ["query" : post_query, "variables" : query_variables]
//
//        let url = URL(string: "https://graphql.anilist.co")
//        var request = URLRequest(url: url!)
//        request.httpMethod = "POST"
//        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try! JSONSerialization.data(withJSONObject: parameterDic, options: [])
//
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            if let data = data {
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: [String: Array<Any>]]]
//
//                    for show in json!["data"]!["Page"]!["media"]! {
////                        print(show)
////                        print("---------")
//                        let jsonData = try JSONSerialization.data(withJSONObject: show, options: .prettyPrinted)
//                        let anime_info: AniList = try! JSONDecoder().decode(AniList.self, from: jsonData)
//                        self.anime_list.append(anime_info)
//                    }
//                    DispatchQueue.main.async {
//                        self.collectionView.reloadData()
//                    }
//                } catch {
//                    print("54: \(error)")
//                }
//            }
//        }.resume()
//    }
//
//    // MARK: UICollectionViewDataSource
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return anime_list.count
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AnimeCollectionViewCell
//
//        // API CALL
//        var img_url = URL(string: "https://cdn4.iconfinder.com/data/icons/ionicons/512/icon-image-512.png")
//        if (!anime_list.isEmpty) {
//            let anime_info = anime_list[indexPath.row]
//
//            img_url = anime_info.coverImage["large"]
//            cell.tag = anime_info.id
//        }
//
//        let data = try! Data(contentsOf: img_url!)
//        let img = UIImage(data: data)
//        cell.configure(with: img!)
//
//        return cell
//    }
//
//    // MARK: UICollectionViewDelegate
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
//
//        let controller = storyboard!.instantiateViewController(withIdentifier: "AnimeInfoTableViewController") as! AnimeInfoTableViewController
//        controller.title = anime_list[indexPath.row].title.first?.value
//
//        let cell = collectionView.cellForItem(at: indexPath) as! AnimeCollectionViewCell
//        controller.tmpImg = cell.imageView.image
//
//
//        self.navigationController?.pushViewController(controller, animated: true)
////        let controller = storyboard!.instantiateViewController(withIdentifier: "AnimeInfoCollectionViewController") as! AnimeInfoCollectionViewController
////        controller.title = anime_list[indexPath.row].title.first?.value
////
////        let cell = collectionView.cellForItem(at: indexPath) as! AnimeCollectionViewCell
////        controller.tmpImg = cell.imageView.image
////
////        self.navigationController?.pushViewController(controller, animated: true)
//    }
//
//}
//
//extension ViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return cellSize
//    }
//}
