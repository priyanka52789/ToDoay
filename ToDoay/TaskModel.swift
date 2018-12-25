//
//  TaskModel.swift
//  ToDoay
//
//  Created by Priyanka Sen on 19/12/18.
//  Copyright © 2018 Priyanka Sen. All rights reserved.
//

import Foundation
import RealmSwift

class TaskModel: Object{
    @objc dynamic var title: String = "";
    @objc dynamic var done: Bool = false;
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
