//
//  BrowseTableViewController.swift
//  Kuro
//
//  Created by Talha Rahman on 10/31/20.
//

import UIKit

class BrowseTableViewController: UITableViewController {
    let options = ["Genre", "Most Popular", "Highest Rated", "Season", "Year"]

    override func viewDidLoad() {
        super.viewDidLoad()
//        overrideUserInterfaceStyle = .dark
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        let width = tableView.bounds.width * -1
        
        for cell in tableView.visibleCells {
            cell.transform = CGAffineTransform(translationX: width, y: 0)
        }
        
        var delayCounter = 0.0
        for cell in tableView.visibleCells {
            UIView.animate(withDuration: 0.5, delay: delayCounter * 0.04, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { cell.transform = CGAffineTransform.identity }, completion: nil)
            delayCounter += 1.0
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(54.0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel!.text = options[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var controller: UIViewController
        
        switch indexPath.row {
        case 0, 3, 4: // Genres, Season, Year
            controller = storyboard!.instantiateViewController(withIdentifier: "CategoryTableViewController")
        case 1, 2: // Popularity or Highest Rated
            let tmpController = storyboard!.instantiateViewController(withIdentifier: "AnimeViewController") as! AnimeViewController
            if indexPath.row == 1 {
                tmpController.queryVariables.updateValue("POPULARITY_DESC", forKey: "sort")
            } else {
                tmpController.queryVariables.updateValue("SCORE_DESC", forKey: "sort")
            }
            controller = tmpController
        default:
            print("Error: Unexpected Cell selected")
            controller = UIViewController()
        }
        controller.title = options[indexPath.row]
        self.navigationController!.pushViewController(controller, animated: true)
    }
}
