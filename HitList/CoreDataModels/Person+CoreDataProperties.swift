//
//  Person+CoreDataProperties.swift
//  HitList
//
//  Created by Karunakar Bandikatla on 14/07/17.
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
    
    func isValidGrade() -> Bool {
        return false
    }
    
    public override func validateForInsert() throws {
        if let personName = self.name {
            if personName.isEmpty {
                throw NSError(domain: Person.PersonNameErrorDomain, code: Person.errorCodes.minLimitNotReached.rawValue, userInfo: ["message" : Person.PersonNameMinLimit])
            }
            else if personName.characters.count > 10 {
                throw NSError(domain: Person.PersonNameErrorDomain, code: Person.errorCodes.maxLimitExceeded.rawValue, userInfo: ["message" : Person.PersonNameMaxLimit])
            }
        }
        
        if !self.isValidGrade() {
            throw NSError(domain: Person.PersonGradeErrorDomain, code: 100, userInfo: ["message" : "Grade should be one of [A, SA, M]"])
        }
    }
    
    public override func validateForUpdate() throws {
        if let personName = self.name {
            if personName.isEmpty {
                throw NSError(domain: Person.PersonNameErrorDomain, code: Person.errorCodes.minLimitNotReached.rawValue, userInfo: ["message" : Person.PersonNameMinLimit])
            }
            else if personName.characters.count > 10 {
                throw NSError(domain: Person.PersonNameErrorDomain, code: Person.errorCodes.maxLimitExceeded.rawValue, userInfo: ["message" : Person.PersonNameMaxLimit])
            }
        }
    }
    
}
