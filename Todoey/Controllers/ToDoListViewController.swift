//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    var selectedCategory : Category? {
        didSet{
           loadItems()
        }
    }
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    //    let fileDataPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathExtension("Items.plist")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color {
            title = self.selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar  else {fatalError("Navigation controller does not exist")}
            if let navColor = UIColor(hexString: colorHex) {
                navBar.backgroundColor = navColor
                navBar.tintColor = ContrastColorOf(navColor, returnFlat: true)
                
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navColor, returnFlat: true)]
                searchBar.barTintColor = navColor
                
                
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = navColor
                navBar.standardAppearance = appearance;
                navBar.scrollEdgeAppearance = navBar.standardAppearance
                
            }

        }
    }
    
    // MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row]
        {// Récupérez l'élément du tableau correspondant à l'index de la cellule
            // Configurer la cellule avec l'élément
            cell.textLabel?.text = item.title // Exemple avec un nom, ajustez selon votre structure de données
            //cell.backgroundColor = UIColor(hexString: String(item.color.lightenByPercentage))
            if let color = UIColor(hexString: item.color)!.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            cell.accessoryType = item.done ? .checkmark : .none
            //                                  true   or  false
        }
        else {
            cell.textLabel?.text = "No Items added"
            cell.backgroundColor = UIColor(hexString: "1D9BF6") 
        }
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row]
        {
            do {
                try realm.write {
                    //realm.delete(item) // delete item with realm
                    item.done = !item.done
                }
            }
            catch {
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            // what will happen once the user clicks the Add Item button on our UIAlert

            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        if let newText = textField.text {
                            newItem.title = newText }
                        newItem.done = false
                        newItem.dateCreated = Date()
                        newItem.color = currentCategory.color
                        currentCategory.items.append(newItem)
                        self.realm.add(newItem)
                    }
                }
                catch {
                    print("Error add todoItems with Realm, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        alert.addTextField{ (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    // MARK: - Delete Data from swipe
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row]
        {
            do {
                    try self.realm.write {
                    self.realm.delete(item) // delete item with realm
                    }
                }
                catch {
                    print("Error delete category with realm, \(error)")
                }
            }
            //tableView.reloadData()
    }
    // MARK: - Model Manipulation Methods

    
    func loadItems()
    {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }

    
}

// MARK: - Search bar methods

extension ToDoListViewController :  UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //todoItems = todoItems?.filter("dateCreated >= %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        //todoItems = todoItems?.filter("dateCreated CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}

