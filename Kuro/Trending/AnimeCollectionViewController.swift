//
//  AnimeViewController.swift
//  Kuro
//
//  Created by Talha Rahman on 11/19/20.
//

import UIKit

private var pageNumber: Int = 1

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
    /// List of Anime to be displayed
    var animeList: [AniList] = []
    /// Set of IDs to insure no duplicate Anime displayed
    var animeSet: Set = Set<Int>()
    var isLoading: Bool = false
    /// false if apiQuery can return no more data
    var canLoadMore: Bool = true
    
    var queryVariables: [String: Any] = [
        "page": pageNumber,
        "perPage": 50,
        "type": "ANIME",
        "sort": "TRENDING_DESC",
        "isAdult": false,
        "popularity_greater": 10000
    ]
    
    let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
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
        // TODO: Fix Issue with Refresh Control & ScrollViewDidLoad
//        collectionView.addSubview(refreshControl)
        view.addSubview(collectionView)
        collectionView.stretchViewBoundsByAddingConstraints(ofParent: view)
        
        let editButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(self.edit))
        self.navigationItem.rightBarButtonItem = editButton

        AppStore.reviewIfApplicable()
    }
    
    // https://johncodeos.com/how-to-add-load-more-infinite-scrolling-in-ios-using-swift/
    // infinite scroll logic taken from here
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if (offsetY > contentHeight - scrollView.frame.height * 4) && !isLoading && canLoadMore {
            loadMoreAnime()
        }
    }
    
    func loadMoreAnime() {
        if !isLoading {
            isLoading = true
            pageNumber += 1
            queryVariables["page"] = pageNumber
            apiQuery()
        }
    }
    
    @objc private func refresh() {
        animeList.removeAll()
        resetPage()
        apiQuery()
    }
    
    @objc private func edit() {
        let editController = storyboard!.instantiateViewController(withIdentifier: "EditSearchTableViewController") as! EditSearchTableViewController
        editController.delegate = self
        present(editController, animated: true, completion: nil)
        
        let isAdult: Bool = queryVariables["isAdult"] as? Bool ?? true
        editController.matureContentButton.isSelected = !(isAdult)
        
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
    
    /// Requests from https://graphql.anilist.co to provide some list of anime matching the queryVariables criteria.
    /// Adds Anime to animeList & corresponding IDs to animeSet
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
                    
                    if json["data"]!["Page"]!["media"]!.count == 0 {
                        self.canLoadMore = false
                    }
                    
                    for show in json["data"]!["Page"]!["media"]! {
                        let jsonData = try JSONSerialization.data(withJSONObject: show, options: .prettyPrinted)
                        let anime_info: AniList = try! JSONDecoder().decode(AniList.self, from: jsonData)
                        // checks if show already exists in list
                        if (!self.animeSet.contains(anime_info.id)) {
                            self.animeList.append(anime_info)
                            self.animeSet.insert(anime_info.id)
                        }
                    }

                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.isLoading = false
//                        self.refreshControl.endRefreshing()
                    }
                } catch {
                    print("54: \(error)")
                }
            }
        }.resume()
    }

    /// resets variables to allow for new apiQuery
    public func resetPage() {
        pageNumber = 1
        queryVariables["page"] = pageNumber
        animeSet.removeAll()
        canLoadMore = true
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
            
            let data = try! Data(contentsOf: animeInfo.coverImage["large"]!)
            let img = UIImage(data: data)
            cell.imageView.image = img
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
        controller.queryVariables["id"] = animeList[indexPath.row].id
        
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 2 - 12.5
        return CGSize(width: width, height: 275)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 7.5, bottom: 7.5, right: 7.5)
    }
}

extension AnimeCollectionViewController: EditSearchTableViewControllerDelegate {
    /// Updates isAdult & sort keys in queryVariables with given parameters
    /// - Parameter isAdult: False to filter Mature Content else True
    /// - Parameter sort: "TRENDING_DESC", "POPULARITY_DESC" or "RATING_DESC"
    func editQuery(isAdult: Bool, sort: String) {
        if isAdult {
            queryVariables.removeValue(forKey: "isAdult")
        } else {
            queryVariables["isAdult"] = false
        }
        queryVariables["sort"] = sort
        resetPage()
        animeList.removeAll()
        apiQuery()
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}
