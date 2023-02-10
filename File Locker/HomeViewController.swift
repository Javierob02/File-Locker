//
//  HomeViewController.swift
//  File Locker
//
//  Created by Javier Ocón Barreiro on 1/2/23.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var pieChart: JPieChart!
    @IBOutlet weak var occuppiedLBL: UILabel!
    @IBOutlet weak var freeLBL: UILabel!
    
    let maximumEspace = 524288000   //500MB
    var sizes: Array<Int> = UserDefaults.standard.object(forKey: "sizes") as! Array<Int>
    
    @IBAction func gotoSettings(_ sender: Any) {
        self.performSegue(withIdentifier: "HomeToSettings", sender:nil);
    }
    
    //Function to get sum of bytes
    func getBytes() -> Int {
        if (sizes.count == 0) {
            return 0
        } else {
            var result = 0
            for i in sizes {
                result += i
            }
            return result
        }
    }
    
    //Function to turn Bytes into MegaBytes
    func bytesToMegabytes(_ bytes: Int) -> Double {
        return Double(bytes) * 0.00000095367431640625
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Update sizes value
        sizes = UserDefaults.standard.object(forKey: "sizes") as! Array<Int>
        //Display PieChart
        pieChart.addChartData(data: [
            JPieChartDataSet(percent: (Double(getBytes())/Double(maximumEspace)), colors: [UIColor.systemRed,UIColor.systemRed]), //OCCUPPIED
            JPieChartDataSet(percent: (1.0-Double((getBytes()))/Double(maximumEspace)), colors: [UIColor.systemGreen,UIColor.systemGreen])  //FREE
         ])
         pieChart.lineWidth = 0.85
        //Set LBLsround(bytesToMegabytes(maximumEspace - getBytes())) * 10) / 10
        occuppiedLBL.text = "\(round(bytesToMegabytes(getBytes()) * 10) / 10) MB / 500 MB"
        freeLBL.text = "FREE: \(round((bytesToMegabytes(maximumEspace - getBytes())) * 10) / 10) MB"
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
