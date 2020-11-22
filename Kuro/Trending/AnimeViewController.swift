//
//  AnimeViewController.swift
//  Kuro
//
//  Created by Talha Rahman on 11/19/20.
//

import UIKit

private let cellSize = CGSize(width: 202, height: 295)

private var post_query = """
        query ($id: Int, $page: Int, $perPage: Int, $sort: [MediaSort], $genre: String, $type: MediaType, $season: MediaSeason, $seasonYear: Int, $isAdult: Boolean, $popularity_greater: Int) {
            Page (page: $page, perPage: $perPage) {
                  media (id: $id, sort: $sort, genre: $genre, type: $type, season: $season, seasonYear: $seasonYear, isAdult: $isAdult, popularity_greater: $popularity_greater) {
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

class AnimeViewController: UIViewController {
    var anime_list: [AniList] = []
    
    var query_variables: [String: Any] = [
        "page": 1,
        "perPage": 50,
        "type": "ANIME",
        "sort": "TRENDING_DESC",
        "isAdult": false,
        "popularity_greater": 10000
    ]
    
    let collectionView: UICollectionView = {
        // Setup CollectionView layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = cellSize
        
        // Initialize CollectionView
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .darkGray
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        apiQuery()
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.stretchViewBoundsByAddingConstraints(ofParent: view)
        // for debugging
//        print(query_variables)
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
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: [String: [String: Array<Any>]]]
                    
                    for show in json["data"]!["Page"]!["media"]! {
                        let jsonData = try JSONSerialization.data(withJSONObject: show, options: .prettyPrinted)
                        let anime_info: AniList = try! JSONDecoder().decode(AniList.self, from: jsonData)
                        self.anime_list.append(anime_info)
                    }

                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                } catch {
                    print("54: \(error)")
                }
            }
        }.resume()
    }

}

// MARK: - CollectionView Delegate
extension AnimeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return anime_list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as! ImageCollectionViewCell
        
        if (!anime_list.isEmpty) {
            let anime_info = anime_list[indexPath.row]
            cell.tag = anime_info.id
            
            let data = try! Data(contentsOf: anime_info.coverImage["large"]!)
            let img = UIImage(data: data)
            cell.imageView.image = img
        } else {
            cell.imageView.image = UIImage(named: "image_icon")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "AnimeInfoTableViewController") as! AnimeInfoTableViewController
        
        if let title = anime_list[indexPath.row].title["english"]! {
            controller.title = title
        } else {
            controller.title = anime_list[indexPath.row].title["romaji"]!
        }

        let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
        controller.tmpImg = cell.imageView.image
        controller.query_variables.updateValue(cell.tag, forKey: "id")
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}
