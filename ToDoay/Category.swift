//
//  Category.swift
//  ToDoay
//
//  Created by Priyanka Sen on 19/12/18.
//  Copyright © 2018 Priyanka Sen. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = "";
    @objc dynamic var hexColor: String = "";
    @objc dynamic var priority: Int = 0;
    @objc dynamic var dateCreated: Date?
    let items = List<TaskModel>()
}
