//
//  ViewController.swift
//  Todoey
//
//  Created by Burak Emre Toker on 6.08.2023.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemsArray: [Item] = []
    //    var defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathExtension("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory: Category? {
        // works if only selectedCategory has set with value.
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("The Data File Path: \(dataFilePath!)")
//        searchBar.delegate = self
        self.title = "Todoey"
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
//        loadItems()
        
        //        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
        //            itemsArray = items
        //        }
        
        // write the code that above' NSCoder version (above was NSUserDefault).
        
    }
    
    
    //MARK: - Table View Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        let item = itemsArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        //        if item.done == true {
        //            cell.accessoryType = .checkmark
        //        } else {
        //            cell.accessoryType = .none
        //        }
        
        // There is even further easy implementation of this as "Ternary":
        cell.accessoryType = item.done == true ? .checkmark : .none
        
        return cell
        
    }
    
    //MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //        if itemsArray[indexPath.row].done == false {
        //            itemsArray[indexPath.row].done = true
        //        } else {
        //            itemsArray[indexPath.row].done = false
        //        }
        
        // instead :
//        itemsArray[indexPath.row].done = !itemsArray[indexPath.row].done
        
        
        // This line for delete from coreData --> for context (temprorary area. )
//        context.delete(itemsArray[indexPath.row])
        
        // This line for remove from itemsArray, nothing to do with CoreData
//        itemsArray.remove(at: indexPath.row)

        // Notice the order "context.delete" and "itemsArray.remove"
        
        
        // We call it whenever we want to save file, also in here.
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        self.saveItems()
        
    }
    
    
    //MARK: - Button Bar Pressed
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            // What will happen when user clicks the action button.
            print(textField.text!)
            
            //            self.defaults.set(self.itemsArray, forKey: "TodoListArray")
            
            // Adding data to our system and reloading data.
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemsArray.append(newItem)
            
            // We call it whenever to save file.
            self.saveItems()
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
        
    }
    
    // This is the method to we able to save our data into the .plist file.
    
    //MARK: - Data Manipulation Methods (CRUD)
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        /* itemsArray[indexPath.row].setValue() diye bir method var ancak bunla update ettiğinde bile
         
        */
        
        // we don't use the code above anymore becaue, we don't need encoder or decoder
//        let encoder = PropertyListEncoder()
//
//        do {
//            let data = try encoder.encode(self.itemsArray)
//            try data.write(to: self.dataFilePath!)
//        } catch {
//            print("Error encoding itemArray: \(error)")
//        }
    }
    
    
    // load with Decoder and
//    func loadItems() {
//        let decoder = PropertyListDecoder()
//
//        do {
//            let data = try Data(contentsOf: dataFilePath!)
//            itemsArray = try decoder.decode([Item].self, from: data)
//        } catch {
//            print("Error decodind itemArray: \(error)")
//        }
//    }
    
    
    //load with CoreData
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        // Normally Swift is clever enought to specify the datatype but now we should specify, espacially for the entitiy name (Item).
        // we don't reinitalize request because we initilazed it as parameter.
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        // remember we did create additional predicates to code won't conflict with each other because in search bar we have also NSPredicate.
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate])
        }

        do {
            itemsArray = try context.fetch(request)
        } catch {
            print("Encountered Error trying to fetch data: \(error) ")
        }
        tableView.reloadData()
    }
    
}

//MARK: - Search Bar Delegate
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
    
    }
    
    // This method triggered only if searchBar changes.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            // Search Bar pass its first status
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
    
}
