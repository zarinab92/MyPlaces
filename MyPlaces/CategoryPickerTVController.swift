//
//  CategoryPickerTVController.swift
//  MyPlaces
//
//  Created by Zarina Bekova on 10/31/20.
//

import UIKit



class CategoryPickerTVController: UITableViewController {

    let categories = ["No Category", "Store", "Bar", "Bookstore", "Restaurant", "Club", "Gym", "Grocery", "Gas Station", "School", "House", "Building", "Park", "Historic Building", "Museum"]
    
    var selectedCategoryName = "No Category"
    var selectedIndexPath = IndexPath() // address cell -> checkmark
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for (index, category) in categories.enumerated() {
            if category == selectedCategoryName {
                selectedIndexPath = IndexPath(row: index, section: 0)
                break
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) {
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }
    
    deinit {
        print("-----deinit \(self)-----")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        cell.textLabel!.text = categories[indexPath.row]
        
        if selectedCategoryName == categories[indexPath.row] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != selectedIndexPath.row {
            if let newCell = tableView.cellForRow(at: indexPath) {
                newCell.accessoryType = .checkmark
            }
            
            if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
                oldCell.accessoryType = .none
            }
            
            selectedIndexPath = indexPath
        }
    }

}
