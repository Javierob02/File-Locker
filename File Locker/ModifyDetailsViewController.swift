//
//  ModifyDetailsViewController.swift
//  File Locker
//
//  Created by Javier Ocón Barreiro on 6/2/23.
//

import UIKit
import FirebaseFirestore

class ModifyDetailsViewController: UIViewController {
    
    @IBOutlet weak var usernameTXT: UITextField!
    @IBOutlet weak var nameTXT: UITextField!
    
    @IBAction func modifyBTN(_ sender: Any) {
        //Update database
        let document = Firestore.firestore().collection("users").document(UserDefaults.standard.object(forKey: "username") as! String)
        document.updateData(["name": nameTXT.text,"username": usernameTXT.text]) { err in
            if let err = err {
                print("\n\nError writing document: \(err)")
            } else {
                //Copy user document --> originalData
                let documentRef = Firestore.firestore().collection("users").document(UserDefaults.standard.object(forKey: "username") as! String)
                documentRef.getDocument { (document, error) in
                   if let document = document, document.exists {
                      let originalData = document.data()
                       //Call function to delete old document and create new one
                       self.deleteAndCreate(originalData: originalData!)
                       //Update all UserDefaults
                       UserDefaults.standard.set(self.nameTXT.text, forKey: "name")
                       UserDefaults.standard.set(self.usernameTXT.text, forKey: "username")
                       //Show changed alert
                       self.showUpdateAlert(self)
                   } else {
                      print("Document does not exist")
                   }
                }
            }
        }
    }
    
    func deleteAndCreate(originalData: [String:Any]) {
        //Delete old document
        Firestore.firestore().collection("users").document(UserDefaults.standard.object(forKey: "username") as! String).delete()
        //Create new document
        let newDocumentRef = Firestore.firestore().collection("users").document(usernameTXT.text!)
        newDocumentRef.setData(originalData) { err in
           if let err = err {
              print("Error adding document: \(err)")
           } else {
              print("Document added with ID: \(newDocumentRef.documentID)")
           }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTXT.text = UserDefaults.standard.object(forKey: "username") as! String
        nameTXT.text = UserDefaults.standard.object(forKey: "name") as! String
        // Do any additional setup after loading the view.
    }
    
    //Alert to let know Download has been made
    func showUpdateAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Success", message: "Details have been updated", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
