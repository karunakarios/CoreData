//
//  Address+CoreDataProperties.swift
//  HitList
//
//  Created by Karunakar Bandikatla on 17/07/17.
//  Copyright © 2017 Karunakar Bandikatla. All rights reserved.
//

import Foundation
import CoreData


extension Address {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: "Address");
    }

    @NSManaged public var city: String?

}
