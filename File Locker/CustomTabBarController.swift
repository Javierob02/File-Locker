//
//  CustomTabBarController.swift
//  File Locker
//
//  Created by Javier Ocón Barreiro on 1/2/23.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    @IBInspectable var initialIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedIndex = initialIndex
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
}
