//
//  FileDetailsViewController.swift
//  File Locker
//
//  Created by Javier Ocón Barreiro on 3/2/23.
//

import UIKit
import MobileCoreServices
import FirebaseStorage
import FirebaseFirestore
import WebKit

class FileDetailsViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet weak var fileNameLBL: UILabel!
    @IBOutlet weak var fileSizeLBL: UILabel!
    @IBOutlet weak var fileTypeLBL: UILabel!
    @IBOutlet weak var fileTimeLBL: UILabel!
    
    //Get uploads file
    var uploads: Array<String> = UserDefaults.standard.object(forKey: "uploads") as! Array<String>
    
    //Function to preview file
    @IBAction func previewFile(_ sender: Any) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let fileRef = storageRef.child(uploads[UserDefaults.standard.object(forKey: "index") as! Int])

        fileRef.downloadURL { (url, error) in
          guard let fileURL = url else {
            // handle error
            return
          }

          let webView = WKWebView(frame: self.view.frame)
          self.view.addSubview(webView)
          webView.load(URLRequest(url: fileURL))
        }
    }
    
    //Function to download & preview file
    @IBAction func downloadFile(_ sender: Any) {
        let storage = Storage.storage()
           let storageRef = storage.reference()
           let fileRef = storageRef.child(uploads[UserDefaults.standard.object(forKey: "index") as! Int])

           let alert = UIAlertController(title: "Download Progress", message: "Downloading file...", preferredStyle: .alert)
           present(alert, animated: true)

           fileRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
             if let error = error {
                 // Handle any errors
             } else {
                 alert.dismiss(animated: true)
                 //Show Downloaded alert
                 self.showDownloadAlert(self)
             }
           }
    }
    
    //Function to share file
    @IBAction func shareFileBTN(_ sender: Any) {
        let storage = Storage.storage()
            let storageRef = storage.reference()
            let fileRef = storageRef.child(uploads[UserDefaults.standard.object(forKey: "index") as! Int])

            fileRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
              if let error = error {
                // Handle any errors
              } else {
                // Use the data
                let text = String(data: data!, encoding: .utf8)
                let activityVC = UIActivityViewController(activityItems: [text as Any], applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
              }
            }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //--------------- Set all file info ---------------
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // Get a reference to the file in Firebase Storage
        let fileRef = storageRef.child(uploads[UserDefaults.standard.object(forKey: "index") as! Int])
        // Get the metadata for the file
        fileRef.getMetadata { (metadata, error) in
          guard let metadata = metadata else {
            // Handle the error
            return
          }
          //Set LBLs
            self.fileNameLBL.text = "Name: \(self.removeOptionalFromString(metadata.name!))"
            self.fileSizeLBL.text = "Size: \(round(self.bytesToMegabytes(Int(metadata.size)) * 10) / 10) MB"
            self.fileTypeLBL.text = "Type: \(self.removeOptionalFromString(metadata.contentType!))"
            var dateTime: String = self.fixTime(date: metadata.timeCreated!)
            self.fileTimeLBL.text = "Time: \(self.removeOptionalFromString(dateTime))"
        }

    }
    
    //Function to fix time in string
    func fixTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        // Set the date format to only display the date and time
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // Get the date and time as a string
        let dateTimeString = dateFormatter.string(from: date)
        // Output the date and time
        return dateTimeString
    }
    
    //Function to remove unecessary data from name
    func removeOptionalFromString(_ string: String) -> String {
        return string.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "")
    }
    
    //Function to turn Bytes into MegaBytes
    func bytesToMegabytes(_ bytes: Int) -> Double {
        return Double(bytes) * 0.00000095367431640625
    }
    
    //Alert to let know Download has been made
    func showDownloadAlert(_ sender: Any) {
        let alert = UIAlertController(title: "Success", message: "File downloaded successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
