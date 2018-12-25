//
//  CategoryTableViewController.swift
//  ToDoay
//
//  Created by Priyanka Sen on 17/12/18.
//  Copyright © 2018 Priyanka Sen. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.backgroundColor = HexColor("1D9BF6")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Add category
    @IBAction func buttonPressed(_ sender: Any) {
        var textField =  UITextField()
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if let text = textField.text {
                let category = Category()
                category.name = text
                category.hexColor = UIColor.randomFlat.hexValue()
                self.save(category)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {(action) in ()}
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func save(_ category: Category){
        do {
            try realm.write {
                 realm.add(category)
            }
        } catch {
            print("Realm data saving error \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategories(){
        categories = realm.objects(Category.self)
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            guard let color = HexColor(category.hexColor) else { fatalError() }
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        } else {
            cell.textLabel?.text = "No Categories added yet"
            cell.backgroundColor = HexColor("1D9BF6")
        }
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 24.0)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let toDoVc = segue.destination as! ToDoViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            toDoVc.itemCategory = categories?[indexPath.row]
        }
    }
    
    override func updateModel(at indexPath: IndexPath){
        if let item = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("realm data saving error \(error)")
            }
        }
    }

}


