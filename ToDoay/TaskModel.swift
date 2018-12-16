//
//  TaskModel.swift
//  ToDoay
//
//  Created by Priyanka Sen on 16/12/18.
//  Copyright © 2018 Priyanka Sen. All rights reserved.
//

import UIKit

class TaskModel: Codable { // Encodable, Decodable can be replaced by Codable i Swift 4
    var title: String = ""
    var type: String = ""
    var done: Bool = false
}
