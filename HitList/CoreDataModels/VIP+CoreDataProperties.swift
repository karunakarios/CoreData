//
//  VIP+CoreDataProperties.swift
//  HitList
//
//  Created by Karunakar Bandikatla on 14/07/17.
//  Copyright © 2017 Karunakar Bandikatla. All rights reserved.
//

import Foundation
import CoreData

extension VIP {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<VIP> {
        return NSFetchRequest<VIP>(entityName: "VIP");
    }
    
    @NSManaged public var grade: String?
    
    override class func entityName() -> String {
        return "VIP"
    }
    
    override public func isValidGrade() -> Bool {
        var isValid = super.isValidGrade()
        if let gradeObj = self.grade {
            if gradeObj.lowercased() == "m" || gradeObj.lowercased() == "a" || gradeObj.lowercased() == "sa" {
                isValid = true
            }
            else {
                isValid = false
            }
        }
        return isValid
    }
    
}
