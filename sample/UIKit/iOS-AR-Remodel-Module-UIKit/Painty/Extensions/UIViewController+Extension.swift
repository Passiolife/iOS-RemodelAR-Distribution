//
//  UITabBarItem+Extension.swift
//  iOS-AR-Remodel-Module-UIKit
//
//  Created by Nikunj on 03/12/21.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}
