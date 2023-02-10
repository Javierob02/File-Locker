//
//  ChangePasswordViewController.swift
//  File Locker
//
//  Created by Javier Ocón Barreiro on 6/2/23.
//

import UIKit
import FirebaseFirestore

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var currentPaswdTXT: UITextField!
    @IBOutlet weak var newPaswd: UITextField!
    @IBOutlet weak var repeatNewPaswd: UITextField!
    
    @IBAction func changePassword(_ sender: Any) {
        if (currentPaswdTXT.text! == "" || newPaswd.text! == "" || repeatNewPaswd.text! == "") {
            //All left blank
            //Show alert
            showIncompleteFieldsAlert(self)
            //Clean VC
            self.currentPaswdTXT.text! = ""
            self.newPaswd.text! = ""
            self.repeatNewPaswd.text! = ""
        } else {
            //Get users information
            let docRef = Firestore.firestore().collection("users").document(UserDefaults.standard.object(forKey: "username") as! String)
            //Find password
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let password = document.get("password") as? String
                    //Test current password
                    if (password == self.currentPaswdTXT.text) {
                        //Test both new passwords
                        if (self.newPaswd.text! == self.repeatNewPaswd.text!) {
                            //Change Password
                            self.change()
                            //---- Password Changed Alert ----
                            self.showPaswdChangedAlert(self)
                            //Clean VC
                            self.currentPaswdTXT.text! = ""
                            self.newPaswd.text! = ""
                            self.repeatNewPaswd.text! = ""
                            
                        } else {
                            //Both passwords are not the same
                            //Send Alert error in login
                            self.showWrongNewPaswdAlert(self)
                            //Clean VC
                            self.currentPaswdTXT.text! = ""
                            self.newPaswd.text! = ""
                            self.repeatNewPaswd.text! = ""
                        }
                    } else {
                        //Current password is not corrwct
                        //Send Alert error in login
                        self.showWrongCurrentPaswdAlert(self)
                        //Clean VC
                        self.currentPaswdTXT.text! = ""
                        self.newPaswd.text! = ""
                        self.repeatNewPaswd.text! = ""
                    }
                    
                } else {
                }
            }
        }
    }
    
    func change() {
        let newDocument = Firestore.firestore().collection("users").document(UserDefaults.standard.object(forKey: "username") as! String)
        newDocument.updateData(["password":newPaswd.text!]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                //Password Changed
                return
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //Alert to let know current password doesn`t match
    func showWrongCurrentPaswdAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Current Passwords Don´t match", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Alert to let know both new passwords aren´t the same
    func showWrongNewPaswdAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Both New Passwords aren´t the same", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Alert to let know password was changed
    func showPaswdChangedAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Success", message: "Password has been changed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Alert to let know password was changed
    func showIncompleteFieldsAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Please fill in all fields", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
