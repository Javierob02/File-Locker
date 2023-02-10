//
//  SettingsViewController.swift
//  File Locker
//
//  Created by Javier Ocón Barreiro on 1/2/23.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class SettingsViewController: UIViewController {

    @IBOutlet weak var usernameLBL: UILabel!
    @IBOutlet weak var nameLBL: UILabel!
    
    @IBAction func gotoModify(_ sender: Any) {
        self.performSegue(withIdentifier: "gotoModifyDetails", sender:nil);
    }
    
    @IBAction func gotoChangePassword(_ sender: Any) {
        self.performSegue(withIdentifier: "gotoChangePassword", sender:nil);
    }
    
    @IBAction func deletAllFiles(_ sender: Any) {
        //Get reference to Storage
        let storageRef = Storage.storage().reference()
        //Get List of uploads
        var uploads: Array<String> = UserDefaults.standard.object(forKey: "uploads") as! Array<String>
        //Delete from Storage
        for file in uploads {
            var fileRef = storageRef.child(file)
            fileRef.delete { error in
                if let error = error {
                    print("Error removing file: \(error)")
                } else {
                    //Deleted from Firebase Storage
                    print("\(file) DELETED FROM FIREBASE STORAGE")
                }
            }
        }
        //Update UserDefaults
        UserDefaults.standard.set([], forKey: "uploads")
        UserDefaults.standard.set([], forKey: "sizes")
        //Update Database
        let newDocument = Firestore.firestore().collection("users").document(UserDefaults.standard.object(forKey: "username") as! String)
        newDocument.updateData(["uploads":[], "sizes":[]]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                //Password Changed
                self.showDeletedAllAlert(self)
            }
        }
    }
    
    //Function to logout the user from current session
    @IBAction func logoutBTN(_ sender: Any) {
        //Clean UserDefaults
        UserDefaults.standard.set("", forKey: "username")
        UserDefaults.standard.set("", forKey: "name")
        UserDefaults.standard.set([], forKey: "uploads")
        UserDefaults.standard.set([], forKey: "sizes")
        //Go to LogIn VC
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInViewController") as! LogInViewController
        self.navigationController?.show(loginVC, sender: self)
    }
    
    @IBAction func deleteAccountBTN(_ sender: Any) {
        //Get uploads list
        var uploads: Array<String> = UserDefaults.standard.object(forKey: "uploads") as! Array<String>
        //If there are files, CAN`T delete
        if (uploads.count != 0) {
            showExistingFilesAlert(self)
            return
        } else {
            //Can delete
            //Delete
            Firestore.firestore().collection("users").document(UserDefaults.standard.object(forKey: "username") as! String).delete()
            //Clean UserDefaults
            UserDefaults.standard.set("", forKey: "username")
            UserDefaults.standard.set("", forKey: "name")
            UserDefaults.standard.set([], forKey: "uploads")
            UserDefaults.standard.set([], forKey: "sizes")
            //Exit the Settings VC
            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInViewController") as! LogInViewController
            self.navigationController?.show(loginVC, sender: self)
            //Show deletion alert
            showDeleteAlert(self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        usernameLBL.text = "@\(UserDefaults.standard.object(forKey: "username") as! String)"
        nameLBL.text = UserDefaults.standard.object(forKey: "name") as! String
        // Do any additional setup after loading the view.
    }
    
    //Alert to let know Username & Password are incorrect
    func showDeleteAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Account has been deleted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Alert to let know files exist
    func showExistingFilesAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Can`t delete Account. Files still exist", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Alert to let know files exist
    func showDeletedAllAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Success", message: "All files have been deleted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
