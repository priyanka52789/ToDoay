//
//  AppDelegate.swift
//  ToDoay
//
//  Created by Priyanka Sen on 15/12/18.
//  Copyright © 2018 Priyanka Sen. All rights reserved.
//

import UIKit
import RealmSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
       
        do {
            _ = try Realm()
        } catch {
            print("Realm setup error : \(error)")
        }
        return true
    }
    
}

