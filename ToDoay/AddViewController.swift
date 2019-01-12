//
//  AddViewController.swift
//  ToDoay
//
//  Created by Priyanka Sen on 05/01/19.
//  Copyright © 2019 Priyanka Sen. All rights reserved.
//

import UIKit
import ChameleonFramework
import ProgressHUD

protocol addDelegate {
    func addOnClick(text: String)
}

class AddViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var addNavBar: UINavigationBar!
    
    @IBOutlet weak var labelOne: UILabel!
    
    @IBOutlet weak var firstTF: UITextField!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var bgScrollView: UIView!
    
    var delegate: addDelegate?
    var titleLabel: String?
    var headerLabel: String?
    var itemColor: String?
    var mode: String?
    var preVal: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        firstTF.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let navBarColor = HexColor(itemColor ?? "1D9BF6") else { fatalError() }
        addNavBar.barTintColor = navBarColor
        addNavBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        addNavBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        //bgScrollView.backgroundColor = navBarColor.darken(byPercentage: 0.1)
        addNavBar.topItem?.title = titleLabel
        labelOne.text = "\(headerLabel ?? "Value")"
        firstTF.placeholder = "Enter \(headerLabel ?? "Value")"
        addButton.setTitle("\(mode ?? "Add")", for: .normal)
        firstTF.layer.borderWidth = 1
        firstTF.layer.cornerRadius = 5
        addButton.layer.cornerRadius = 5
        cancelButton.layer.cornerRadius = 5
        firstTF.becomeFirstResponder()
        firstTF.text = preVal ?? ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func addOnClick(_ sender: Any) {
        guard let text = firstTF.text, text.count > 0 else {
            ProgressHUD.showError("Add data")
            return
        }
        delegate?.addOnClick(text: text)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelOnClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
