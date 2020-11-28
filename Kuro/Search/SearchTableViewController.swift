//
//  SearchTableViewController.swift
//  Kuro
//
//  Created by Talha Rahman on 11/2/20.
//

import UIKit

private var postQuery = """
        query ($search: String, $page: Int, $perPage: Int, $type: MediaType, $isAdult: Boolean) {
            Page (page: $page, perPage: $perPage) {
                  media (search: $search, type: $type, isAdult: $isAdult) {
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

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    var animeList: [AniList] = []
    
    var queryVariables: [String: Any] = [
        "search" : "",
        "isAdult" : false,
        "page" : 1,
        "perPage" : 50,
        "type" : "ANIME"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        queryVariables["search"] = searchText
        animeList.removeAll()
        apiQuery()
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
                        self.tableView.reloadData()
                    }
                } catch {
                    print("54: \(error)")
                }
            }
        }.resume()
    }

}

extension SearchTableViewController {
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as UITableViewCell
        
        if indexPath.row >= animeList.count {
            return cell
        }
        
        if let title = animeList[indexPath.row].title["english"]! {
            cell.textLabel?.text = title
        } else {
            cell.textLabel?.text = animeList[indexPath.row].title["romaji"]!
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "AnimeInfoTableViewController") as! AnimeInfoTableViewController
        controller.title = tableView.cellForRow(at: indexPath)?.textLabel?.text
        
        let data = try! Data(contentsOf: animeList[indexPath.row].coverImage["large"]!)
        controller.tmpImg = UIImage(data: data)
        controller.queryVariables["id"] = animeList[indexPath.row].id
        
        self.navigationController?.pushViewController(controller, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animeList.count
    }
}
