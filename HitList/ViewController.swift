//
//  ViewController.swift
//  HitList
//
//  Created by Karunakar Bandikatla on 12/07/17.
//  Copyright © 2017 Karunakar Bandikatla. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var people: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Persons List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        _ = CoreDataManager.sharedInstance.applicationDocumentsDirectory
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CoreDataManager.sharedInstance.fetchEntity(name: Person.entityName(), by: Person.activeUsers()) { (fetchResults: [NSManagedObject]) in
            self.people = fetchResults
        }        
    }
    
    // MARK:- IBActions
    
    @IBAction func addName(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "New Name",
                                      message: "Add a new name",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
            
            var personGrade: String?
            
            if let textField2 = alert.textFields?[1] {
                if !(textField2.text?.isEmpty)! {
                    personGrade = textField2.text!
                }
            }
            
            CoreDataManager.sharedInstance.savePerson(id: self.people.count + 1, name: nameToSave, lastUpdated: Date(), grade: personGrade, onCompletion: { (person: NSManagedObject) in
                self.people.append(person)
                self.tableView.reloadData()
            }, onFailure: { (err: NSError) in
                weak var weakself = self
                if err.domain == Person.nameErrorDomain {
                    UIAlertController.showAlert(title: "Name", message: err.userInfo["message"] as! String, target: weakself!)
                }
            })
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addTextField()
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        CoreDataManager.sharedInstance.deleteAllObjects(inEntity: Person.entityName())
        CoreDataManager.sharedInstance.fetchEntity(name: Person.entityName(), by: Person.activeUsers()) { (fetchResults: [NSManagedObject]) in
            self.people = fetchResults
            self.tableView.reloadData()
        }
    }

    //MARK:- Coredata Methods
    
    func editData(for person: NSManagedObject) {
        guard let oldName: String = person.value(forKeyPath: "name") as? String else {
            return
        }
        let alert = UIAlertController(title: "Edit Name",
                                      message: oldName,
                                      preferredStyle: .alert)
        if let textField = alert.textFields?.first {
            textField.text = oldName
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            guard let textField = alert.textFields?.first,
                let changedName = textField.text else {
                    return
            }
            
            CoreDataManager.sharedInstance.edit(person: person, with: changedName, onCompletion: { (person: NSManagedObject) in
                self.tableView.reloadData()
            }, onFailure: { (err: NSError) in
                self.tableView.reloadData()
                weak var weakself = self
                if err.domain == Person.nameErrorDomain {
                    UIAlertController.showAlert(title: "Name", message: err.userInfo["message"] as! String, target: weakself!)
                }
            })
            
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func deleteData(for person: NSManagedObject) {
        CoreDataManager.sharedInstance.delete(person: person) { (status: Bool
            ) in
            CoreDataManager.sharedInstance.fetchEntity(name: Person.entityName(), by: Person.activeUsers()) { (fetchResults: [NSManagedObject]) in
                self.people = fetchResults
                self.tableView.reloadData()
            }
        }
    }
    
    func isVIP(person: NSManagedObject) -> Bool {
        return person.isKind(of: VIP.self) ? true : false
    }
    
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let person: Person = people[indexPath.row] as! Person
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let personName = person.name {
            cell.textLabel?.text = "\(person.id). \(personName)"
        }
        else {
            cell.textLabel?.text = "NA"
        }
        
        if self.isVIP(person: people[indexPath.row]) {
            cell.textLabel?.text = (cell.textLabel?.text)! + "  "  + "(\((person as! VIP).grade))"
        }        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let person = people[indexPath.row]
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.editData(for: person)
        }
        let delete = UITableViewRowAction(style: .default, title: "Delete") { action, index in
            self.deleteData(for: person)
        }
        return [edit,delete]
    }
    
}
