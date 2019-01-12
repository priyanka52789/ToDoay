//
//  PasswordViewController.swift
//  ToDoay
//
//  Created by Priyanka Sen on 05/01/19.
//  Copyright © 2019 Priyanka Sen. All rights reserved.
//

import UIKit
import ProgressHUD

class PasswordViewController: UIViewController, UITextFieldDelegate {
    
    var userName: String = ""

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var pwd1Label: UILabel!
    
    @IBOutlet weak var pwd1TF: UITextField!
    
    @IBOutlet weak var pwd2Label: UILabel!
    
    @IBOutlet weak var pwd2TF: UITextField!
    
    @IBOutlet weak var setPasswordBtn: UIButton!
    
    @IBOutlet weak var forgotPwdBtn: UIButton!
    
    var defaults = UserDefaults.standard

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameTF.delegate = self
        pwd1TF.delegate = self
        pwd2TF.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (userName.count > 0){
            pwd1Label.text = "Old password"
            pwd1TF.placeholder = "Enter old password"
            pwd2Label.text = "New password"
            pwd2TF.placeholder = "Enter new password"
            setPasswordBtn.setTitle("Change Password", for: .normal)
            forgotPwdBtn.isHidden = false
        } else {
            pwd1Label.text = "Password"
            pwd1TF.placeholder = "Enter password"
            pwd2Label.text = "Confirm password"
            pwd2TF.placeholder = "Enter confirm password"
            setPasswordBtn.setTitle("Register", for: .normal)
            forgotPwdBtn.isHidden = true
        }
        nameTF.layer.borderWidth = 1
        pwd1TF.layer.borderWidth = 1
        pwd2TF.layer.borderWidth = 1
        nameTF.layer.cornerRadius = 5
        pwd1TF.layer.cornerRadius = 5
        pwd2TF.layer.cornerRadius = 5
        setPasswordBtn.layer.cornerRadius = 5
        forgotPwdBtn.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func setPwdOnClick(_ sender: Any) {
        guard let name = nameTF.text, name.count > 0 else {
            ProgressHUD.showError("Enter user name")
            return
        }
        guard let pwd1 = pwd1TF.text, pwd1.count > 0 else {
            ProgressHUD.showError((userName.count > 0) ? "Enter old password":"Enter password")
            return
        }
        guard let pwd2 = pwd2TF.text, pwd2.count > 0 else {
            ProgressHUD.showError((userName.count > 0) ? "Enter new password":"Enter confirm password")
            return
        }
        if (userName.count > 0){ // change Password
            guard let savedPwd = defaults.object(forKey: "password") as? String else {
                ProgressHUD.showError("Register you name")
                return
            }
            if userName == name && savedPwd == pwd1 {
                defaults.setValue(pwd2, forKey: "password")
                ProgressHUD.showSuccess("Password updated successfully")
                navigationController?.popViewController(animated: true)
            } else {
                ProgressHUD.showError("User name or password does not match")
            }
        } else {
            if pwd1 == pwd2 {
                defaults.setValue(name, forKey: "name")
                defaults.setValue(pwd2, forKey: "password")
                ProgressHUD.showSuccess("Registered successfully")
                performSegue(withIdentifier: "goToHome", sender: self)
            } else {
                ProgressHUD.showError("Confirm password does not match")
            }
        }
        
    }
    
    @IBAction func forgotPwdOnClick(_ sender: Any) {
        if (userName.count > 0){
            guard let savedPwd = defaults.object(forKey: "password") as? String else {
                return
            }
            ProgressHUD.showSuccess("\(userName), your password is \(savedPwd)")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
