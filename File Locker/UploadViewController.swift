//
//  UploadViewController.swift
//  File Locker
//
//  Created by Javier Ocón Barreiro on 1/2/23.
//

import UIKit
import MobileCoreServices
import Firebase
import FirebaseStorage
import FirebaseFirestore

class UploadViewController: UIViewController, UIDocumentPickerDelegate {
    
    let storage = Storage.storage()

    @IBAction func uploadFileBTTN(_ sender: Any){
        print("\n-------------------------------------")
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF), String(kUTTypeImage)], in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        //Show Uploading alert in progress
        let alert = UIAlertController(title: "Upload In Progress", message: "Uploading file...", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        //Start
        guard let fileURL = urls.first else { return }
        
        let fileName = fileURL.lastPathComponent
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child(fileName)
        let uploadTask = fileRef.putFile(from: fileURL, metadata: nil) { [self] (metadata, error) in
            guard error == nil else {
                print("Error uploading file: \(error!.localizedDescription)")
                return
            }
            //GET 'uploads' & 'sizes'
            var uploads = UserDefaults.standard.object(forKey: "uploads") as! Array<String>
            var sizes = UserDefaults.standard.object(forKey: "sizes") as! Array<Int>
            //Add Upload to 'uploads' & Size to 'sizes'
            uploads.append("\(removeOptionalFromString(metadata!.name!))")
            sizes.append(Int(metadata!.size))
            //Save new lists to UserDefaults
            UserDefaults.standard.set(uploads, forKey: "uploads")
            UserDefaults.standard.set(sizes, forKey: "sizes")
            //Update database
            let document = Firestore.firestore().collection("users").document(UserDefaults.standard.object(forKey: "username") as! String)
            document.updateData(["uploads": uploads,"sizes": sizes]) { err in
                if let err = err {
                    print("\n\nError writing document: \(err)")
                } else {
                    //DISMISS ALERT
                    alert.dismiss(animated: true)
                    //Show Uploaded alert
                    showUploadedAlert(self)
                }
            }
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Upload is \(percentComplete)% complete")
        }
        
        uploadTask.observe(.success) { (snapshot) in
            print("Upload task completed successfully")
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("Upload task failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    //Function to remove unecessary data from name
    func removeOptionalFromString(_ string: String) -> String {
        return string.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    //Alert to let know Upload has been made
    func showUploadedAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Success", message: "File uploaded successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
