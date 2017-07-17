//
//  AlertViewViewController.swift
//  HitList
//
//  Created by Karunakar Bandikatla on 13/07/17.
//  Copyright © 2017 Karunakar Bandikatla. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    class func showAlert(title: String, message: String, target: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result: UIAlertAction) -> Void in
        })
        target.present(alert, animated: true, completion: nil)
    }
    
    /*
     
     static let nameErrorDomain = "nameErrorDomain"
 
     class func entityName() -> String {
     return "Person"
     }
     
     class func activeUsers() -> NSPredicate {
     let predicate: NSPredicate = NSPredicate(format: "active == true")
     return predicate
     }
 
 */
    
}
