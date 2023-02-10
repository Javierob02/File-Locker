//
//  MyFilesViewController.swift
//  File Locker
//
//  Created by Javier Ocón Barreiro on 1/2/23.
//

import UIKit
import MobileCoreServices
import FirebaseStorage
import FirebaseFirestore

class MyFilesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    //Get list of 'uploads'
    var uploads: Array<String> = UserDefaults.standard.object(forKey: "uploads") as! Array<String>
    var sizes: Array<Int> = UserDefaults.standard.object(forKey: "sizes") as! Array<Int>
    
    //Set number of rows in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uploads.count
    }
    
    //Set cells in tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //Set title of cell
        cell.textLabel?.text = "\(uploads[indexPath.row])"
        
        return cell
    }
    
    //------------------ Used to make slide to delete animation ------------------
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        //Delete from Firebase Storage
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child(uploads[indexPath.row])
        fileRef.delete { error in
            if let error = error {
                print("Error removing file: \(error)")
            } else {
                //Deleted from Firebase Storage
            }
        }
        //Remove files from file lists
        uploads.remove(at: indexPath.row)
        sizes.remove(at: indexPath.row)
        //Delete row of the deleted task
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
        //Update Task Lists
        UserDefaults.standard.set(uploads, forKey: "uploads")
        UserDefaults.standard.set(sizes, forKey: "sizes")
        //Update Firebase
        let document = Firestore.firestore().collection("users").document(UserDefaults.standard.object(forKey: "username") as! String)
        document.updateData(["uploads": uploads,"sizes": sizes]) { err in
            if let err = err {
                print("\n\nError writing document: \(err)")
            } else {
                //Change made
                self.showDeletionAlert(self)
            }
        }
    }
    // ---------------------------------------------------------------------------
    
    //Function to deselect selected row in tableView
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    
    //Function to segue in FileDetails Scene on accessory click
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // Perform some action when the detail accessory is tapped
        UserDefaults.standard.set(indexPath.row, forKey: "index")
        //Push to ModifyTaskViewController
        self.performSegue(withIdentifier: "showFileDetails", sender:nil);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Update list
        uploads = UserDefaults.standard.object(forKey: "uploads") as! Array<String>
        sizes = UserDefaults.standard.object(forKey: "sizes") as! Array<Int>
        //Update tableView
        tableView.reloadData()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    //Alert to let know file was deleted
    func showDeletionAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Success", message: "File was deleted successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
