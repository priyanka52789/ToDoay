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
import ProgressHUD

class CategoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories : Results<Category>?
    
    var reorder: Bool = false
    
    var mode: String = "Add"
    
    var rowEdit: Int = -1
    
    let colorArray: [String] = ["#f21deb", "#9328ff", "#3b1df9", "#16c8f9", "#0affd6", "#1bfc80", "#e8ff1c", "#ff8b07", "#f91f02", "#f74747"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated:true);
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Add category
    @IBAction func buttonPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Options", message: "", preferredStyle: .actionSheet)
        let addAction = UIAlertAction(title: "Add Category", style: .default) { (action) in
            self.mode = "Add"
            self.performSegue(withIdentifier: "addValue", sender: self)
        }
        let reorderAction = UIAlertAction(title: self.reorder ? "Reorder done" : "Reorder", style: .default) {(action) in
            self.reorder = !self.reorder
            self.tableView.setEditing(self.reorder, animated: false)
        }
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) {(action) in
            self.navigationController?.popToRootViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {(action) in
            self.tableView.reloadData()
        }
        
        alert.addAction(addAction)
        alert.addAction(reorderAction)
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func save(_ category: Category){
        do {
            try realm.write {
                 realm.add(category)
            }
        } catch {
            ProgressHUD.showError("Realm data saving error \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategories(){
        categories = realm.objects(Category.self).sorted(byKeyPath: "priority", ascending: true)
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
            let doneItems = category.items.filter("done = %d", true)
            cell.textLabel?.text = category.name
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd,yyyy"
            cell.detailTextLabel?.text = "Created on : \(dateFormatter.string(from: category.dateCreated!))       Progress : \(doneItems.count) / \(category.items.count)"
            guard let color = HexColor(category.hexColor) else { fatalError() }
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            cell.detailTextLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            cell.accessoryType = .disclosureIndicator
            cell.tintColor = ContrastColorOf(color, returnFlat: true)
        } else {
            cell.textLabel?.text = "No Categories added yet"
            cell.backgroundColor = HexColor("1D9BF6")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItem" {
            let toDoVc = segue.destination as! ToDoViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                toDoVc.itemCategory = categories?[indexPath.row]
                tableView.deselectRow(at: indexPath, animated: true)
            }
        } else if segue.identifier == "addValue" {
            let addVc = segue.destination as! AddViewController
            addVc.titleLabel = mode + " Category"
            addVc.headerLabel = mode + " Category"
            addVc.itemColor = "1D9BF6"
            addVc.delegate = self
            addVc.mode = mode
            addVc.preVal = mode == "Update" ? categories?[rowEdit].name : ""
        }
    }
    
    override func updateModel(at indexPath: IndexPath){
        print("update Model child")
        if let item = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } catch {
                ProgressHUD.showError("realm data saving error \(error)")
            }
        }
    }
    
    override func updateModelOnEdit(at indexPath: IndexPath){
        print("update Model OnEdit from child")
        mode = "Update"
        rowEdit = indexPath.row
        performSegue(withIdentifier: "addValue", sender: self)
    }
    
    override func updateModelOnReorder(at : Int, withObjectAt: Int){
        print("update Model OnReorder  from child at \(at) with at \(withObjectAt)")
        if let categoryAt = categories?[at], let categoryWith = categories?[withObjectAt] {
            do {
                try realm.write {
                    categoryAt.priority = withObjectAt + 1
                    categoryWith.priority = at + 1
                }
            } catch {
                ProgressHUD.showError("realm data saving error \(error)")
            }
            tableView.reloadData()
        }
    }

}

extension CategoryTableViewController: addDelegate {
    func addOnClick(text: String) {
        if mode == "Add" {
            let category = Category()
            category.name = text
            category.hexColor = colorArray[(categories?.count)! % colorArray.count]//UIColor.randomFlat.hexValue()
            category.priority = (self.categories?.count ?? 0) + 1
            category.dateCreated = Date()
            self.save(category)
        } else {
            if let category = categories?[rowEdit] {
                do {
                    try self.realm.write {
                        category.name = text
                    }
                } catch {
                    ProgressHUD.showError("realm data saving error \(error)")
                }
                tableView.reloadData()
            }
        }
    }
}


