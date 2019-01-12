//
//  ToDoViewController.swift
//  ToDoay
//
//  Created by Priyanka Sen on 15/12/18.
//  Copyright © 2018 Priyanka Sen. All rights reserved.
//

import UIKit
import UserNotifications
import RealmSwift
import ChameleonFramework
import ProgressHUD

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
    var reorder: Bool = false
    var mode: String = "Add"
    var rowEdit: Int = 0
    
    var defaults = UserDefaults.standard
    
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
        //tableView.backgroundColor = navBarColor
        setNavBarColor(withColor: navBarColor)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let originalColor = HexColor("1D9BF6") else { fatalError() }
        setNavBarColor(withColor: originalColor)
    }
    
    func setNavBarColor(withColor navBarColor: UIColor) {
        guard let navBar = navigationController?.navigationBar else {
            //fatalError("Nav controller does not exist")
            return
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
        
        let alert = UIAlertController(title: "Options", message: "", preferredStyle: .actionSheet)
        let addAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
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
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {(action) in ()}
        
        alert.addAction(addAction)
        alert.addAction(reorderAction)
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        toDoItems = itemCategory?.items.sorted(byKeyPath: "priority", ascending: true)
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd,yyyy"
            cell.textLabel?.text = item.title
            cell.textLabel?.numberOfLines = 5
            cell.detailTextLabel?.text = "\(item.done ? "Completed" : "Created") on : \(dateFormatter.string(from: item.done ? item.dateCompleted! : item.dateCreated!))"
            cell.accessoryType = item.done ? .checkmark : .none
            if let color = HexColor(itemColor ?? "1D9BF6")?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(toDoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                cell.detailTextLabel?.textColor = ContrastColorOf(color, returnFlat: true)
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
                        item.dateCompleted = Date()
                        //realm.delete(item)
                    }
                } catch {
                    ProgressHUD.showError("realm data saving error \(error)")
                }
            }
        tableView.reloadData()
        
    }
    
    override func updateModel(at indexPath: IndexPath){
        if let item = self.toDoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }                }
            } catch {
                ProgressHUD.showError("realm data saving error \(error)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addValue" {
            let addVc = segue.destination as! AddViewController
            addVc.titleLabel = itemCategory?.name
            addVc.headerLabel = mode + " Item"
            addVc.itemColor = itemColor
            addVc.mode = mode
            addVc.delegate = self
            addVc.preVal = mode == "Update" ? toDoItems?[rowEdit].title : ""
        }
    }
    
    override func updateModelOnEdit(at indexPath: IndexPath){
        print("update Model OnEdit from child")
        mode = "Update"
        rowEdit = indexPath.row
        performSegue(withIdentifier: "addValue", sender: self)
    }
    
    override func updateModelOnReorder(at : Int, withObjectAt: Int){
        print("update Model OnReorder  from child")
        if let itemAt = toDoItems?[at], let itemWith = toDoItems?[withObjectAt] {
            do {
                try realm.write {
                    itemAt.priority = withObjectAt + 1
                    itemWith.priority = at + 1
                }
            } catch {
                ProgressHUD.showError("realm data saving error \(error)")
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
        if searchBar.text?.count != 0 {
            toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
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

extension ToDoViewController: addDelegate {
    func addOnClick(text: String) {
        if mode == "Add" {
            if let currentCategory = self.itemCategory {
                do {
                    try self.realm.write {
                        let item = TaskModel()
                        item.title = text
                        item.priority = currentCategory.items.count + 1
                        item.dateCreated = Date()
                        currentCategory.items.append(item)
                        self.setNotification(for: text)
                    }
                } catch {
                    ProgressHUD.showError("Realm data saving error \(error)")
                }
            }
        } else {
            if let item = toDoItems?[rowEdit] {
                do {
                    try self.realm.write {
                        item.title = text
                    }
                } catch {
                    ProgressHUD.showError("realm data saving error \(error)")
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    //MARK: - Button functions
    func setNotification(for item: String) {
        guard let savedName = defaults.object(forKey: "name") as? String else {
            return
        }
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Hi \(savedName)", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "If you have done item \"\(item)\", then you can update your ToDo List!", arguments: nil)
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "notify-test"
        content.badge = 5
        content.categoryIdentifier = "Message"
        content.subtitle = "Is \"\(item)\" done?"
        content.userInfo = ["item":"\(item)"];
        
        var dateComponent = DateComponents()
        dateComponent.hour = 21
        dateComponent.minute = 00
        print(dateComponent)
        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        //let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 15, repeats: false)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponent, repeats: false)
        let request = UNNotificationRequest.init(identifier: "notify-test", content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request)
        
    }
}

