//
//  Person+CoreDataClass.swift
//  HitList
//
//  Created by Karunakar Bandikatla on 14/07/17.
//  Copyright © 2017 Karunakar Bandikatla. All rights reserved.
//

import Foundation
import CoreData

@objc(Person)
public class Person: NSManagedObject {
    
    static let PersonNameErrorDomain = "PersonNameErrorDomain"
    static let PersonGradeErrorDomain = "PersonGradeErrorDomain"
    static let PersonNameMinLimit = "Name should not be empty!"
    static let PersonNameMaxLimit = "Name should not be more than 10 charcaters!"
    
    enum errorCodes: Int {
        case maxLimitExceeded = 0
        case minLimitNotReached = 1
    }
    
}
