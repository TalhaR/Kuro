//
//  SearchTableViewController.swift
//  Kuro
//
//  Created by Talha Rahman on 11/2/20.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!

    let data = ["Test", "test1", "Test1", "Ta", "Word"]

    var filteredData: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        filteredData = data
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = filteredData[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? data : data.filter { (item: String) -> Bool in
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        tableView.reloadData()
    }

}
