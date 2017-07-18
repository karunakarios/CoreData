//
//  Person+CoreDataProperties.swift
//  HitList
//
//  Created by Karunakar Bandikatla on 17/07/17.
//  Copyright © 2017 Karunakar Bandikatla. All rights reserved.
//

import Foundation
import CoreData

extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person");
    }

    @NSManaged public var active: Bool
    @NSManaged public var id: Int64
    @NSManaged public var lastUpdated: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var address: Address?
    @NSManaged public var spouse: Person?
    
    class func entityName() -> String {
        return "Person"
    }
    
    class func activeUsers() -> NSPredicate {
        let predicate: NSPredicate = NSPredicate(format: "active == true")
        return predicate
    }

}
