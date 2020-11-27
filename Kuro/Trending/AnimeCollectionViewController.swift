//
//  AnimeViewController.swift
//  Kuro
//
//  Created by Talha Rahman on 11/19/20.
//

import UIKit

private let cellSize = CGSize(width: 190, height: 285)

private var postQuery = """
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

class AnimeCollectionViewController: UIViewController {
    var animeList: [AniList] = []
    
    var queryVariables: [String: Any] = [
        "page": 1,
        "perPage": 50,
        "type": "ANIME",
        "sort": "TRENDING_DESC",
        "isAdult": false,
        "popularity_greater": 10000
    ]
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = cellSize
        
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
        print(queryVariables)
        
        let editButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(self.edit))
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    @objc func edit() { 
        let editController = storyboard!.instantiateViewController(withIdentifier: "EditSearchTableViewController") as! EditSearchTableViewController
        editController.delegate = self
        present(editController, animated: true, completion: nil)
        editController.matureContentButton.isSelected = !(queryVariables["isAdult"] as! Bool)
        
        switch queryVariables["sort"] as! String {
        case "TRENDING_DESC":
            editController.trendingRadioButton.isSelected = true
        case "POPULARITY_DESC":
            editController.popularityRadioButton.isSelected = true
        case "SCORE_DESC":
            editController.ratingRadioButton.isSelected = true
        default:
            print("Error: Invalid sort")
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
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: [String: [String: Array<Any>]]]
                    
                    for show in json["data"]!["Page"]!["media"]! {
                        let jsonData = try JSONSerialization.data(withJSONObject: show, options: .prettyPrinted)
                        let anime_info: AniList = try! JSONDecoder().decode(AniList.self, from: jsonData)
                        self.animeList.append(anime_info)
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
extension AnimeCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as! ImageCollectionViewCell
        
        if (!animeList.isEmpty) {
            let animeInfo = animeList[indexPath.row]
            cell.tag = animeInfo.id
            
            let data = try! Data(contentsOf: animeInfo.coverImage["large"]!)
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
        
        if let title = animeList[indexPath.row].title["english"]! {
            controller.title = title
        } else {
            controller.title = animeList[indexPath.row].title["romaji"]!
        }

        let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
        controller.tmpImg = cell.imageView.image
        controller.queryVariables.updateValue(cell.tag, forKey: "id")
        
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}

extension AnimeCollectionViewController: EditSearchTableViewControllerDelegate {
    func editQuery(isAdult: Bool, sort: String) {
        queryVariables["isAdult"] = isAdult
        queryVariables["sort"] = sort
        animeList.removeAll()
        apiQuery()
        print(queryVariables)
    }
}
