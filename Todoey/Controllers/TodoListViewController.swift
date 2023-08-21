//
//  ViewController.swift
//  Todoey
//
//  Created by Burak Emre Toker on 6.08.2023.
//

import UIKit
import RealmSwift
import ChameleonFramework


class TodoListViewController: SwipeTableViewController {
    
    //    var defaults = UserDefaults.standard
    let realm = try! Realm()
    var todoItems: Results<Item>?
    
    
    // this is optional because otherwise u will get an error. init error
    var selectedCategory: Category? {
        // works if only selectedCategory has set with value.
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        // Do any additional setup after loading the view.
        //        searchBar.delegate = self
        self.title = "Todoey"
        //        loadItems()
        
    }
    
    // The reason why we use WillAppear method is view's loading is not enough for navigationController set up.
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color {
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist")}
            // in iOS 13 this is new
            navBar.backgroundColor = UIColor(hexString: colorHex)
            title = selectedCategory!.name
        }
    }
    
    
    //MARK: - Table View Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            //        if item.done == true {
            //            cell.accessoryType = .checkmark
            //        } else {
            //            cell.accessoryType = .none
            //        }
            
            // There is even further easy implementation of this as "Ternary":
            cell.accessoryType = item.done == true ? .checkmark: .none
            
        } else {
            cell.textLabel?.text = "No Items In It"
        }
        
        if let currentCategoryColor = selectedCategory?.color {
            if let color = UIColor(hexString: currentCategoryColor)?.lighten(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                
            }
        }
        
        
        cell.layer.borderWidth = cell.frame.width * 0.005
        cell.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.layer.cornerRadius = cell.frame.height / 5
        
        return cell
        
    }
    
    //MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write{
                    item.done = !item.done
                }
            } catch {
                print("Encountered with an error when updating item.done: \(error)")
            }
        }

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
                    // and actually we saving the items as this.b
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        
                        // don't confuse it with in CategoryVC. we append newItem to the relationship.
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items: \(error)")
                }
            }
            
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
        // notice that we do not need to saveItems method in order to save items in textField.
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
    
    
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try self.realm.write{
                    self.realm.delete(item)
                }
            } catch {
                print("Error While Deleting Item \(error).")
            }
            
            
        }
        
    }
}

//MARK: - Search Bar Delegate
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!)
            .sorted(byKeyPath:"dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    // This method triggered only if searchBar changes.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
//
            // Search Bar pass its first status
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
    
}
