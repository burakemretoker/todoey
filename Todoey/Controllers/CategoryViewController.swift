//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Burak Emre Toker on 11.08.2023.
//

// Tidy version of TodoListViewController for 11 August 2023


import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {
    // We're implementing this second time, so it's secure to forcly try.
     let realm = try! Realm()
    var selectedIndexPath = IndexPath()
    //
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        loadCategories()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        if let navBar = navigationController?.navigationBar {
            navBar.backgroundColor = FlatSkyBlue()
            
        }
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let currentColor = categoryArray?[indexPath.row].color ?? "FFFFFF"
        cell.backgroundColor = UIColor(hexString: currentColor)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories Added Yet."
        cell.layer.borderWidth = cell.frame.width * 0.005
        cell.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.layer.cornerRadius = cell.frame.height / 5
        cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: currentColor)!, returnFlat: true)
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        selectedIndexPath = indexPath
        performSegue(withIdentifier: "goToItemsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
//        print(tableView.indexPathForSelectedRow)
//        if let indexPath = tableView.indexPathForSelectedRow {
//            print("tableView.indexPathForSelectedRow \(indexPath.row)")
//            destinationVC.selectedCategory = categoryArray?[indexPath.row]
////            if categoryArray != nil {
////                destinationVC.selectedCategory = categoryArray![indexPath.row]
////            }
//        }
        destinationVC.selectedCategory = categoryArray?[selectedIndexPath.row]
    }
    
    //MARK: - Data Manipulation Methods (CRUD)
    
    func loadCategories() {

        categoryArray = realm.objects(Category.self)
    }
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Encountered with an error on saving categories: \(error)")
        }
    }
    
    
    //MARK: - Add New Categories (button)
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Todoey Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            print("Action Button Trigerred.")
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            // we don't need to append newCategory to the array.
            self.save(category: newCategory)
            
            self.tableView.reloadData()
            
        }
        
        alert.addAction(action)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Type a Category."
            textField = alertTextField
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        do {
            try self.realm.write {
                guard let categoryItem = self.categoryArray?[indexPath.row] else {
                    print("Item could not be deleted since it's nil.")
                    return
                }
                self.realm.delete(self.categoryArray![indexPath.row])
                print("Item is Deleted.")
            }
        } catch {
            print("Error when SwipeTableViewCellDelegate \(error)")
        }
    }
    
    
}



//
//extension CategoryViewController: SwipeTableViewCellDelegate {
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        guard orientation == .right else { return nil }
//
//        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
//            do {
//                try self.realm.write {
//                    guard let categoryItem = self.categoryArray?[indexPath.row] else {
//                        print("Item could not be deleted since it's nil.")
//                        return
//                    }
//                    self.realm.delete(self.categoryArray![indexPath.row])
//                    print("Item is Deleted.")
//                }
//            } catch {
//                print("Error when SwipeTableViewCellDelegate \(error)")
//            }
//        }
//
//        // customize the action appearance
//        deleteAction.image = UIImage(named: "delete-icon")
//
//        return [deleteAction]
//    }
//
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//        var options = SwipeOptions()
//        options.expansionStyle = .destructive
////        options.transitionStyle = .border
//        return options
//    }
//
//}
