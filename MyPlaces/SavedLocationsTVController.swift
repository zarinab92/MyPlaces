//
//  SavedLocationsTVController.swift
//  MyPlaces
//
//  Created by Zarina Bekova on 11/11/20.
//

import UIKit
import CoreLocation
import CoreData

class SavedLocationsTVController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext!
    
    // NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = Location.entity()
        
        let sortByCategory = NSSortDescriptor(key: "category", ascending: true)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortByCategory, sortDescriptor]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResltsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: "category",
            cacheName: "Locations")
        
        fetchedResltsController.delegate = self
        
        return fetchedResltsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        loadLocations()
    }
    
    // MARK: - Helper methods
    
    func loadLocations() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editLocation" {
            let destinationVC = segue.destination as! LocationDetailsTableViewController
            destinationVC.managedObjectContext = self.managedObjectContext
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                destinationVC.locationToEdit = fetchedResultsController.object(at: indexPath)
            }
        }
    }
    
    // MARK: - Table View DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections![section].name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
    
        cell.configure(for: fetchedResultsController.object(at: indexPath))
        
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let location = fetchedResultsController.object(at: indexPath)
            
            location.deletePhotoFile()
            managedObjectContext.delete(location)
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
            
        }
    }

}


extension SavedLocationsTVController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("----- WillChangeContent ----")
        tableView.beginUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("--- insert ----")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            print("--- delete ----")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            print("--- update ----")
            if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
                cell.configure(for: controller.object(at: indexPath!) as! Location)
            }
        case .move:
            print("--- move ----")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        @unknown default:
            fatalError()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("---- insert section ----")
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            print("---- delete section ----")
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            print("---- update section ----")
        case .move:
            print("---- move section ----")
        @unknown default:
            fatalError()
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("----- DidChangeContent -----")
        tableView.endUpdates()
    }
    
}
