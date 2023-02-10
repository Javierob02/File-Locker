//
//  SignUpViewController.swift
//  File Locker
//
//  Created by Javier Ocón Barreiro on 1/2/23.
//

import UIKit
import FirebaseFirestore

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTXT: UITextField!
    @IBOutlet weak var usernameTXT: UITextField!
    @IBOutlet weak var passwordTXT: UITextField!
    @IBOutlet weak var REpasswordTXT: UITextField!
    
    
    @IBAction func gotoHome(_ sender: Any) {
        if (nameTXT.text!.isEmpty || usernameTXT.text!.isEmpty || passwordTXT.text!.isEmpty || REpasswordTXT.text!.isEmpty) {   //Check complete fields
            //Fields are incomplete
            showErrorAlert(self)
            //Clean VC
            nameTXT.text! = ""
            usernameTXT.text! = ""
            passwordTXT.text! = ""
            REpasswordTXT.text! = ""
        } else {
            if (passwordTXT.text! != REpasswordTXT.text!) {
                //NOT same password
                showErrorPassword(self)
                //Clean passwords
                passwordTXT.text! = ""
                REpasswordTXT.text! = ""
            } else {
                //If Passwords are the same & all fields are complete
                let newDocument = Firestore.firestore().collection("users").document(usernameTXT.text!)
                newDocument.setData(["username": usernameTXT.text!,"password": passwordTXT.text!, "name": nameTXT.text!, "uploads": [], "sizes": []]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        //Save 'name' and 'username' to UserDefaults
                        UserDefaults.standard.set(self.nameTXT.text!, forKey: "name")
                        UserDefaults.standard.set(self.usernameTXT.text!, forKey: "username")
                        UserDefaults.standard.set([], forKey: "uploads")
                        UserDefaults.standard.set([], forKey: "sizes")
                        //Go To Home
                        self.performSegue(withIdentifier: "SignUpToHome", sender:nil);
                    }
                }
            }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set placholder colours
        usernameTXT.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray3])
        nameTXT.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray3])
        passwordTXT.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray3])
        REpasswordTXT.attributedPlaceholder = NSAttributedString(string: "RepeatPassword", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray3])
        // Do any additional setup after loading the view.
    }
    
    
    //Alert to let know Username & Password are incorrect
    func showErrorAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "All fields must be complete", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Alert to let know Username & Password are incorrect
    func showErrorPassword(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Passwords should be the same for both fields!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
