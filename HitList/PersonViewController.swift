//
//  PersonViewController.swift
//  HitList
//
//  Created by Karunakar Bandikatla on 17/07/17.
//  Copyright © 2017 Karunakar Bandikatla. All rights reserved.
//

import UIKit
import CoreData

class PersonViewController: UIViewController {
    
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var addSpouseBarButton: UIBarButtonItem!
    
    var totalRows = 3
    var person: Person?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailCell")
        detailsTableView.separatorStyle = .none
        
        if let me = self.person {
            if let name = me.name {
                self.title = name
            }
            checkForSpouse()
        }
        
    }
    
    func checkForSpouse() {
        if let me = self.person {
            if let _ = me.spouse {
                addSpouseBarButton.isEnabled = false
                totalRows = 4
                self.detailsTableView.reloadData()
            }
        }
    }
   
    //MARK:- IBActions

    @IBAction func deleteMe(_ sender: Any) {
        CoreDataManager.sharedInstance.delete(person: self.person!) { (status: Bool
            ) in
           _ =  self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func addSpouse(_ sender: Any) {
        
        if let me:Person = self.person,
            let _ = me.spouse {
            return
        }
        
        let alert = UIAlertController(title: "Add Spouse",
                                      message: "",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else { 
                    return
            }
            
            if nameToSave.isEmpty {
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
            
            CoreDataManager.sharedInstance.fetchEntity(name: Person.entityName(), by: Person.activeUsers()) { (fetchResults: [NSManagedObject]) in
                    CoreDataManager.sharedInstance.savePerson(id: fetchResults.count+1, name: nameToSave, lastUpdated: Date(), grade: personGrade, address: personAddress, spouse: self.person, onCompletion: { (person: NSManagedObject) in
                         self.checkForSpouse()
                    }, onFailure: { (err: NSError) in
                        weak var weakself = self
                        if err.domain == Person.nameErrorDomain {
                            UIAlertController.showAlert(title: "Name", message: err.userInfo["message"] as! String, target: weakself!)
                        }
                    })
            }
            
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
    
    
    func spouseName() -> String {
        guard let me = self.person,
            let spouse = me.spouse,
            let name = spouse.name else {
                return "NA"
        }
        return name
    }
    
}

// MARK: - UITableViewDataSource

extension PersonViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        cell.textLabel?.textColor = UIColor.darkGray
        
        var personName = "NA"
        var personGrade = "NA"
        var personAddress = "NA"
        
        if let me = self.person {
            if let name = me.name {
                personName = name
            }
            if let meVIP = me as? VIP {
                if let grade = meVIP.grade {
                    personGrade = grade
                }
            }
            if let address = me.address,
                let city = address.city {
                personAddress = city
            }
        }
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Name : \(personName)"
        case 1:
            cell.textLabel?.text = "Grade : \(personGrade)"
        case 2:
            cell.textLabel?.text = "Address : \(personAddress)"
        case 3:
            cell.textLabel?.text = "Spouse : \(self.spouseName())"
        default:
            break
        }
        return cell
    }
}
