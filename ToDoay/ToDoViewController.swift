//
//  ToDoViewController.swift
//  ToDoay
//
//  Created by Priyanka Sen on 15/12/18.
//  Copyright © 2018 Priyanka Sen. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoViewController: SwipeTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    let realm = try! Realm()
    var toDoItems: Results<TaskModel>?
    var itemColor: String?
    
    var itemCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = self.itemCategory?.name
        guard let navBarColor = HexColor(itemColor ?? "1D9BF6") else { fatalError() }
        searchBar.barTintColor = navBarColor
        addButton.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        tableView.backgroundColor = navBarColor
        setNavBarColor(withColor: navBarColor)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let originalColor = HexColor("1D9BF6") else { fatalError() }
        setNavBarColor(withColor: originalColor)
    }
    
    func setNavBarColor(withColor navBarColor: UIColor) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Nav controller does not exist")
        }
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Add new item to list
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            print(textField.text ?? "")
            if let currentCategory = self.itemCategory {
                do {
                    try self.realm.write {
                        let item = TaskModel()
                        item.title = textField.text!
                        item.dateCreated = Date()
                        currentCategory.items.append(item)
                    }
                } catch {
                    print("Realm data saving error \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        toDoItems = itemCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        itemColor = itemCategory?.hexColor
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        // Configure the cell...
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            if let color = HexColor(itemColor ?? "1D9BF6")?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(toDoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        } else {
            cell.textLabel?.text = "No items added yet"
        }
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

            if let item = toDoItems?[indexPath.row] {
                do {
                    try self.realm.write {
                        item.done = !item.done
                        //realm.delete(item)
                    }
                } catch {
                    print("realm data saving error \(error)")
                }
            }
        tableView.reloadData()
        
    }
    
    override func updateModel(at indexPath: IndexPath){
        if let item = self.toDoItems?[indexPath.row] {
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

//MARK: - Searchbar methods
extension ToDoViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

