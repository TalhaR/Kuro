//
//  FavoritesTableViewController.swift
//  Kuro
//
//  Created by Talha Rahman on 11/2/20.
//

import UIKit
import CoreData

// Most Logic modelled after / taken from iOS Apprentice Chapter 32
class FavoritesTableViewController: UITableViewController {
    
    lazy var fetchedResultsController: NSFetchedResultsController<Anime> = {
        let fetchRequest = NSFetchRequest<Anime>(entityName: "Anime")
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController<Anime>(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAnime()
        tableView.register(FavoriteAnimeTableViewCell.nib(), forCellReuseIdentifier: FavoriteAnimeTableViewCell.identifier)
    }
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    func fetchAnime() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("error")
        }
    }
}

extension FavoritesTableViewController {
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteAnimeTableViewCell.identifier, for: indexPath) as! FavoriteAnimeTableViewCell

        let anime = fetchedResultsController.object(at: indexPath)
        cell.animeName.text = anime.name
        cell.animeImage.image = UIImage(data: anime.image!)
        cell.animeScore.text = String(anime.score)
        
        switch anime.type {
        case "TV_SHORT":
            cell.animeType.text = "TV Short"
        case "MOVIE":
            cell.animeType.text = "Movie"
        default:
            cell.animeType.text = anime.type
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let controller = storyboard!.instantiateViewController(withIdentifier: "AnimeInfoTableViewController") as! AnimeInfoTableViewController

        let anime = fetchedResultsController.object(at: indexPath)
        
        controller.title = anime.name
        controller.tmpImg = UIImage(data: anime.image!)
        controller.queryVariables.updateValue(Int(anime.id), forKey: "id")

        self.navigationController!.pushViewController(controller, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let animeToDelete = fetchedResultsController.object(at: indexPath)
            context.delete(animeToDelete)
            
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension FavoritesTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
        @unknown default:
            fatalError("Unhandled switch case of NSFetchedResultsChangeType")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
        @unknown default:
            fatalError("Unhandled switch case of NSFetchedResultsChangeType")
        }
    }
}
