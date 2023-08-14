//
//  ViewController.swift
//  Todoey
//
//  Created by Burak Emre Toker on 6.08.2023.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    
    //    var defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathExtension("Items.plist")
    let realm = try! Realm()
    var todoItems: Results<Item>?
    
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
        
        
    }
    
    
    //MARK: - Table View Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            //        if item.done == true {
            //            cell.accessoryType = .checkmark
            //        } else {
            //            cell.accessoryType = .none
            //        }
            
            // There is even further easy implementation of this as "Ternary":
            cell.accessoryType = item.done == true ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items In It"
        }
        
        
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
        
        //        todoItems?[indexPath.row].done = !todoItems[indexPath.row].done
        //        self.saveItems()
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        
    }
    
    
    //MARK: - Button Bar Pressed
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            // What will happen when user clicks the action button.
            print(textField.text!)
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        print("herreeee\(newItem.title)")
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items: \(error)")
                }
                print("hi thereee2")
            }
            print("hi thereee3")
            print(self.selectedCategory?.items)
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
    
    func saveItems(item: Item) {
        
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("Error saving item: \(error)")
        }
    }
    
        //load with CoreData
        
        func loadItems() {
            todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
            
            tableView.reloadData()
        }
        
    }


//MARK: - Search Bar Delegate
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//        request.predicate = predicate
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request, predicate: predicate)
        
    
    }
    
    // This method triggered only if searchBar changes.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
//            loadItems()
//
            // Search Bar pass its first status
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
    
}
