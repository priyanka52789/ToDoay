//
//  SwipeTableViewController.swift
//  ToDoay
//
//  Created by Priyanka Sen on 23/12/18.
//  Copyright © 2018 Priyanka Sen. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        tableView.allowsSelectionDuringEditing = true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SwipeTableViewCell
        cell.delegate = self as SwipeTableViewCellDelegate
        //cell.layer.cornerRadius = 38
        cell.layer.borderWidth = 1
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("Delete Cell")
            self.updateModel(at: indexPath)
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-Icon")
        
        let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
            // handle action by updating model with deletion
            print("Edit Cell")
            self.updateModelOnEdit(at: indexPath)
        }
        
        // customize the action appearance
        editAction.image = UIImage(named: "edit-icon")
        
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        print("update Model moveRowAt")
        updateModelOnReorder(at: fromIndexPath.row, withObjectAt: to.row)
        //dataArray.exchangeObject(at: fromIndexPath.row, withObjectAt: to.row)
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    func updateModel(at indexPath: IndexPath){
        print("update Model")
    }
    
    func updateModelOnEdit(at indexPath: IndexPath){
        print("update Model OnEdit")
    }
    
    func updateModelOnReorder(at : Int, withObjectAt: Int){
        print("update Model OnReorder")
    }

}

