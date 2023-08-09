//
//  ViewController.swift
//  Todoey
//
//  Created by Burak Emre Toker on 6.08.2023.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemsArray = [Item]()
    //    var defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathExtension("Items.plist")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("The Data File Path: \(dataFilePath!)")
        
        let newItem1 = Item()
        newItem1.title = "Find Mike"
        itemsArray.append(newItem1)
        
        let newItem2 = Item()
        newItem2.title = "Buy Eggos"
        itemsArray.append(newItem2)
        
        let newItem3 = Item()
        newItem3.title = "Destroy Demogorgon"
        itemsArray.append(newItem3)
        
        loadItems()
        
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
        itemsArray[indexPath.row].done = !itemsArray[indexPath.row].done
        
        // We call it whenever we want to save file, also in here.
        self.saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            // What will happen when user clicks the action button.
            print(textField.text!)
            
            //            self.defaults.set(self.itemsArray, forKey: "TodoListArray")
            
            // Adding data to our system and reloading data.
            let newItem = Item()
            newItem.title = textField.text!
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
        present(alert, animated: true)
    }
    
    // This is the method to we able to save our data into the .plist file.
    func saveItems() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(self.itemsArray)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("Error encoding itemArray: \(error)")
        }
    }
    
    func loadItems() {
        let decoder = PropertyListDecoder()
        
        do {
            let data = try Data(contentsOf: dataFilePath!)
            itemsArray = try decoder.decode([Item].self, from: data)
        } catch {
            print("Error decodind itemArray: \(error)")
        }
    }
    
    
}

