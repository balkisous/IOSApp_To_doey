//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Wangie on 07/02/2024.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
      
    let realm = try! Realm()

    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar  else {fatalError("Navigation controller does not exist")}
        if let navColor = UIColor(hexString: "1D9BF6") {
            navBar.backgroundColor = navColor
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(hexString: "1D9BF6")
            navBar.standardAppearance = appearance;
            navBar.scrollEdgeAppearance = navBar.standardAppearance
        }
        

    }
    
    
    // MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name // Exemple avec un nom, ajustez selon votre structure de données
            guard let color = UIColor(hexString: category.color) else { fatalError()}
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            
        } else {
            cell.textLabel?.text = "No Categories Added yet"// Exemple avec un nom, ajustez selon votre structure de donnée
            cell.backgroundColor = UIColor(hexString: "1D9BF6")
        }
        return cell
    }
    
    // MARK: - Table Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - Delete Data from swipe
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row]
        {
            do {
                    try self.realm.write {
                    self.realm.delete(category) // delete item with realm
                    }
                }
                catch {
                    print("Error delete category with realm, \(error)")
                }
            }
            //tableView.reloadData()
    }
    
    // MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        
        let action = UIAlertAction(title: "Add New Category", style: .default) { action in
            // what will happen once the user clicks the Add Item button on our UIAlert

            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            self.saveCategory(category: newCategory)
        }
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        alert.addTextField{ (alertTextField) in
            alertTextField.placeholder = "Create new Category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Data Manipulation Methods
    
    func saveCategory(category: Category)
    {
        do {
            try realm.write{
                realm.add(category)
            }
        }
        catch {
            print("Error add Category with Realm, \(error)")
        }
        tableView.reloadData()
    }

    func loadCategories()
    {
        categories = realm.objects(Category.self)
        tableView.reloadData()

    }

}
