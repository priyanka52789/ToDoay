//
//  TaskModel.swift
//  ToDoay
//
//  Created by Priyanka Sen on 19/12/18.
//  Copyright © 2018 Priyanka Sen. All rights reserved.
//

import Foundation
import RealmSwift

class TaskModel: Object {
    @objc dynamic var title: String = "";
    @objc dynamic var done: Bool = false;
    @objc dynamic var priority: Int = 0;
    @objc dynamic var dateCreated: Date?
    @objc dynamic var dateCompleted: Date?
    @objc dynamic var dateReminder: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items") // imp
}
