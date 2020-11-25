//
//  FavoritesTableViewController.swift
//  Kuro
//
//  Created by Talha Rahman on 11/2/20.
//

import UIKit

class FavoritesTableViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var animeList: [Anime]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAnime()
        tableView.register(FavoriteAnimeTableViewCell.nib(), forCellReuseIdentifier: FavoriteAnimeTableViewCell.identifier)
    }
    
    func fetchAnime() {
        do {
            self.animeList = try context.fetch(Anime.fetchRequest())
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("error")
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animeList?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteAnimeTableViewCell.identifier, for: indexPath) as! FavoriteAnimeTableViewCell

        if let animeList = animeList {
            let anime = animeList[indexPath.row]
            cell.animeName.text = anime.name
            cell.animeImage.image = UIImage(data: anime.image!)
            cell.animeScore.text = String(anime.score)
            cell.animeType.text = anime.type
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "AnimeInfoTableViewController") as! AnimeInfoTableViewController
        
        let anime = animeList![indexPath.row]
        
        controller.title = anime.name
        controller.tmpImg = UIImage(data: anime.image!)
        controller.queryVariables.updateValue(Int(anime.id), forKey: "id")
        
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") {(action, view, completionHandler) in
            let animeToRemove = self.animeList![indexPath.row]
            
            self.context.delete(animeToRemove)
            
            do {
                try self.context.save()
            } catch {
                print(error.localizedDescription)
            }
            
            self.fetchAnime()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
