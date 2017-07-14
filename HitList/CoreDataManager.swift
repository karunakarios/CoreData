//
//  CoreDataManager.swift
//  HitList
//
//  Created by Karunakar Bandikatla on 13/07/17.
//  Copyright © 2017 Karunakar Bandikatla. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataManager:NSObject {
    
    private override init() {
        super.init()
    }
    
    //MARK: Shared Instance
    static let sharedInstance: CoreDataManager = CoreDataManager.init()
    static let storeName = "HitList"
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: storeName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }

    }
//    
//        func fetchAvailableSlotsBetween(startDate : String, endDate : String, success:@escaping (_ model:CWBAvailableSlots) -> Void, failure:@escaping (_ error:(Error?)) -> Void)  -> Void {
    
    func fetchEntity(name: String, by predicate: NSPredicate, onSuccess: @escaping (_ fetchResults:[NSManagedObject]) -> Void) {
        
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: name)
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            onSuccess(results)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func savePerson(id: Int, name: String, lastUpdated: Date, grade: String?, onCompletion: @escaping (_ person:NSManagedObject) -> Void, onFailure: @escaping (_ error: NSError) -> Void) {
        
        let managedContext = CoreDataManager.sharedInstance.persistentContainer.viewContext
        let isvip = (grade != nil) ? true : false
        let entityName = isvip ? VIP.entityName() : Person.entityName()
   
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!  //entity description
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        (person as! Person).id = Int64(id)
        (person as! Person).name = name
        (person as! Person).lastUpdated = lastUpdated as NSDate?
        
        if isvip {
            (person as! VIP).grade = grade!
        }
        
        do {
            try managedContext.save()
            onCompletion(person)
        } catch let error as NSError {
            managedContext.delete(person)
            onFailure(error as NSError)
        }
    }
    
    func edit(person: NSManagedObject, with name: String, onCompletion: @escaping (_ person:NSManagedObject) -> Void, onFailure: @escaping (_ error: NSError) -> Void) {
    
        let managedContext = self.persistentContainer.viewContext
        
        (person as! Person).name = name
        (person as! Person).lastUpdated = Date() as NSDate?
        
        do {
        try managedContext.save()
            onCompletion(person)
        } catch let error as NSError {
            onFailure(error as NSError)
        }
    }
    
    func delete(person: NSManagedObject, onCompletion: @escaping (_ status:Bool) -> Void) {
        let managedContext = CoreDataManager.sharedInstance.persistentContainer.viewContext
        (person as! Person).active = false
        (person as! Person).lastUpdated = Date() as NSDate?
        do {
            try managedContext.save()
            onCompletion(true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteAllObjects(inEntity name: String) {
        let managedContext = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: name)
        do {
            let results = try managedContext.fetch(fetchRequest)
            for result in results {
                managedContext.delete(result)
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(urls)
        return urls[urls.count - 1] as NSURL
    }()
    
}
