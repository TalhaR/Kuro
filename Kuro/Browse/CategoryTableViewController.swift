//
//  GenreTableViewController.swift
//  Kuro
//
//  Created by Talha Rahman on 10/31/20.
//

import Foundation
import UIKit

class CategoryTableViewController: UITableViewController {
    var categories: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch title {
        case "Genre":
            categories = ["Action","Adventure","Comedy","Drama","Fantasy","Horror","Mecha","Music","Mystery","Psychological","Romance","Sci-Fi","Slice of Life","Sports","Supernatural","Thriller"]
        case "Season":
            for year in (1960...Calendar.current.component(.year, from: Date())).reversed() {
                for season in ["Fall", "Summer", "Spring", "Winter"]{
                    categories.append("\(season) \(year)")
                }
            }
        case "Year":
            for year in (1960...(Calendar.current.component(.year, from: Date()))+1).reversed() {
                categories.append("\(year)")
            }
        default:
            print("Error: Unexpected value for Title")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        let height = tableView.bounds.height
        
        for cell in tableView.visibleCells {
            cell.transform = CGAffineTransform(translationX: 0, y: height)
        }
        
        var delayCounter = 0.0
        for cell in tableView.visibleCells {
            UIView.animate(withDuration: 0.5, delay: delayCounter * 0.04, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { cell.transform = CGAffineTransform.identity }, completion: nil)
            delayCounter += 1.0
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(54.0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel!.text = categories[indexPath.row]

        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BrowseCategory" {
            let controller = segue.destination as! AnimeViewController
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.title = categories[indexPath.row]
                controller.query_variables.updateValue("POPULARITY_DESC", forKey: "sort")
                
                switch title {
                case "Genre":
                    controller.query_variables.updateValue(categories[indexPath.row], forKey: "genre")
                case "Season":
                    let seasonArr = categories[indexPath.row].components(separatedBy: " ")
                    controller.query_variables.updateValue(seasonArr[0].uppercased(), forKey: "season")
                    controller.query_variables.updateValue(seasonArr[1], forKey: "seasonYear")
                case "Year":
                    controller.query_variables.updateValue(categories[indexPath.row], forKey: "seasonYear")
                default:
                    print("Error: Unexpected issue with segue")
                }
            }
        }
    }

}
