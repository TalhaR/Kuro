//
//  GenreTableViewController.swift
//  Kuro
//
//  Created by Talha Rahman on 10/31/20.
//

import UIKit

class CategoryTableViewController: UITableViewController {
    let genres = ["Action","Adventure","Comedy","Drama","Fantasy","Horror","Mecha","Music","Mystery","Psychological","Romance","Sci-Fi","Slice of Life","Sports","Supernatural","Thriller"]
    var seasons = ["Upcoming"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return genres.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel!.text = genres[indexPath.row]

        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BrowseGenre" {
            let controller = segue.destination as! AnimeCollectionViewController
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.newTitle = genres[indexPath.row]
                
                controller.query_variables.updateValue("POPULARITY_DESC", forKey: "sort")
                controller.query_variables.updateValue(genres[indexPath.row], forKey: "genre")
                
            }
        }
    }

}
