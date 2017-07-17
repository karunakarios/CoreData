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
    var selectedPerson: Person?
    let screenTitle = "Employees"
    let addTitle = "Add Employee"
    let editTitle = "Edit Name"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = screenTitle
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        _ = CoreDataManager.sharedInstance.applicationDocumentsDirectory
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CoreDataManager.sharedInstance.fetchEntity(name: Person.entityName(), by: Person.activeUsers()) { (fetchResults: [NSManagedObject]) in
            self.people = fetchResults
            self.tableView.reloadData()
        }        
    }
    
    // MARK:- IBActions
    
    @IBAction func addName(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: addTitle,
                                      message: "",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
            
            var personGrade: String?
            var personAddress: String?
            
            if let gradeField = alert.textFields?[1] {
                if !(gradeField.text?.isEmpty)! {
                    personGrade = gradeField.text!
                }
            }
            if let addressField = alert.textFields?[2] {
                if !(addressField.text?.isEmpty)! {
                    personAddress = addressField.text!
                }
            }
            
            CoreDataManager.sharedInstance.savePerson(id: self.people.count + 1, name: nameToSave, lastUpdated: Date(), grade: personGrade, address: personAddress, onCompletion: { (person: NSManagedObject) in
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
        alert.addTextField()
        
        if let nameField = alert.textFields?[0],
            let gradeField = alert.textFields?[1],
            let addressField = alert.textFields?[2] {
            nameField.placeholder = "Name"
            gradeField.placeholder = "Grade"
            addressField.placeholder = "Address"
        }
        
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
        let alert = UIAlertController(title: editTitle,
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
    

     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "persondetail" {
                let personVC = segue.destination as! PersonViewController
                if let person = self.selectedPerson {
                    personVC.person = person
                }
            }
        }
     }
    
    func displayDetail(for person: Person) {
        weak var weakself = self
        self.selectedPerson = person
        self.performSegue(withIdentifier: "persondetail", sender: weakself)
    }
    
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let person: Person = people[indexPath.row] as! Person
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //name
        if let personName = person.name {
            cell.textLabel?.text = "\(person.id). \(personName)"
        }
        else {
            cell.textLabel?.text = "NA"
        }
        
        //grade
        if self.isVIP(person: people[indexPath.row]) {
            cell.textLabel?.text = (cell.textLabel?.text)! + " "  + "(\((person as! VIP).grade!))"
        }
        
        //address
        if let address = person.address,
            let city = address.city {
            cell.textLabel?.text = (cell.textLabel?.text)! + " from "  + "'\(city)'"
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = people[indexPath.row]
        self.displayDetail(for: person as! Person)
    }
    
}
