//
//  LogInViewController.swift
//  File Locker
//
//  Created by Javier Ocón Barreiro on 1/2/23.
//

import UIKit
import FirebaseFirestore

class LogInViewController: UIViewController {
    
    @IBOutlet weak var usernameTXT: UITextField!
    @IBOutlet weak var passwordTXT: UITextField!
    
    //Function in charge of Log In
    @IBAction func gotoHome(_ sender: Any) {
        if (usernameTXT.text!.isEmpty || passwordTXT.text!.isEmpty) {
            //Not all fields are complete
            showErrorAlert(self)
            //Clean VC
            usernameTXT.text! = ""
            passwordTXT.text! = ""
        } else {
            //Database initialization
            let docRef = Firestore.firestore().collection("users").document(usernameTXT.text!)
            //ADD TO CHECK EXISTANCE OF USERNAME
            //Find username, password, name & uploads
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let username = document.get("username") as? String
                    let password = document.get("password") as? String
                    let name = document.get("name") as? String
                    let uploads = document.get("uploads") as? Array<String>
                    let sizes = document.get("sizes") as? Array<Int>
                    //Test Username and Password
                    if (username == self.usernameTXT.text && password == self.passwordTXT.text) {
                        //Save 'name' and 'username' to UserDefaults
                        UserDefaults.standard.set(self.usernameTXT.text!, forKey: "username")
                        UserDefaults.standard.set(name, forKey: "name")
                        UserDefaults.standard.set(uploads, forKey: "uploads")
                        UserDefaults.standard.set(sizes, forKey: "sizes")
                        //COGER NOMBRE
                        //Go To Home
                        self.performSegue(withIdentifier: "LogInToHome", sender:nil);
                    } else {
                        //Send Alert error in login
                        self.showLogInErrorAlert(self)
                        //Clean VC
                        self.usernameTXT.text! = ""
                        self.passwordTXT.text! = ""
                    }
                    
                } else {
                    //Shows alert that username doesn`t exist
                    self.showErrorUsernameAlert(self)
                    //Clean VC
                    self.usernameTXT.text! = ""
                    self.passwordTXT.text! = ""
                }
            }
        }
    }
    
    @IBAction func gotoSignUp(_ sender: Any) {
        self.performSegue(withIdentifier: "LogInToSignUp", sender:nil);
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        //Set placholder colours
        usernameTXT.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray3])
        passwordTXT.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray3])
        // Do any additional setup after loading the view.
    }
    
    //Alert to let know Username & Password are incorrect
    func showLogInErrorAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "LogIn details are erroneous", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Alert to let know Username & Password are incorrect
    func showErrorAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "All fields must be complete", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Alert to let know Username & Password are incorrect
    func showErrorUsernameAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "This username doesn`t exist", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
