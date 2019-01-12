//
//  LoginViewController.swift
//  ToDoay
//
//  Created by Priyanka Sen on 05/01/19.
//  Copyright © 2019 Priyanka Sen. All rights reserved.
//

import UIKit
import ChameleonFramework
import ProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var pwdLabel: UILabel!
    
    @IBOutlet weak var pwdTF: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var passwordBtn: UIButton!
    
    var defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameTF.delegate = self
        pwdTF.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let navBarColor = HexColor("1D9BF6") else { fatalError() }
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Nav controller does not exist")
        }
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        //pwdTF.text = ""
        if let savedName = defaults.object(forKey: "name") as? String {
            nameTF.text = savedName
            passwordBtn.setTitle("Change Password", for: .normal)
        } else {
            passwordBtn.setTitle("Register", for: .normal)
        }
        nameTF.layer.borderWidth = 1
        pwdTF.layer.borderWidth = 1
        nameTF.layer.cornerRadius = 5
        pwdTF.layer.cornerRadius = 5
        loginBtn.layer.cornerRadius = 5
        passwordBtn.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func loginOnClick(_ sender: Any) {
        guard let name = nameTF.text, name.count > 0 else {
            ProgressHUD.showError("Enter user name")
            return
        }
        guard let pwd = pwdTF.text, pwd.count > 0 else {
            ProgressHUD.showError("Enter password")
            return
        }
        guard let savedName = defaults.object(forKey: "name") as? String else {
            ProgressHUD.showError("Register you name")
            return
        }
        guard let savedPwd = defaults.object(forKey: "password") as? String else {
            ProgressHUD.showError("Register you name")
            return
        }
        if savedName == name && savedPwd == pwd {
            performSegue(withIdentifier: "goToHome", sender: self)
        } else {
            ProgressHUD.showError("User name or password does not match")
        }
    }
    
    @IBAction func passwordOnClick(_ sender: Any) {
        performSegue(withIdentifier: "goToRegister", sender: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goToRegister" {
            let vc = segue.destination as! PasswordViewController
            if let savedName = defaults.object(forKey: "name") as? String {
                vc.userName = savedName
            }
        }
    }
    

}
