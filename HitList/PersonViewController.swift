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
    
    var totalRows = 5
    var person: Person?
    var totalReportees = 0
    var reportees: [Person]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailCell")
        detailsTableView.separatorStyle = .none
        if let me = self.person {
            if let name = me.name {
                self.title = name
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    //MARK:- Private API
    
    private func reload() {
        if let me = self.person,
            let reportees = me.reportees {
            totalReportees = reportees.count
            self.reportees = reportees.allObjects as? [Person]
        }
        if self.person != nil {
            self.detailsTableView.reloadData()
        }
        
    }
    
    private func showActions() {
        
        guard let me = self.person else {
            return
        }
        
        let alert = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .actionSheet)
        
        let addSpouse = UIAlertAction(title: "Add Spouse", style: .default) {
            [unowned self] action in
            self.addSpouse()
        }
        addSpouse.isEnabled = !me.isHavingSpouse()
        alert.addAction(addSpouse)
        
        let addReportee = UIAlertAction(title: "Add Reportee (For M level)", style: .default) {
            [unowned self] action in
            self.addReportee()
        }
        addReportee.isEnabled = me.isManager()
        alert.addAction(addReportee)

        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func addSpouse() {
        
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
                    self.reload()
                }, onFailure: { (err: NSError) in
                    weak var weakself = self
                    if err.domain == Person.PersonNameErrorDomain {
                        UIAlertController.showAlert(title: "Name", message: err.userInfo["message"] as! String, target: weakself!)
                    }
                    else if err.domain == Person.PersonGradeErrorDomain {
                        UIAlertController.showAlert(title: "Grade", message: err.userInfo["message"] as! String, target: weakself!)
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
    
    func managerName() -> String {
        guard let me = self.person,
            let manager = me.manager,
            let name = manager.name else {
                return "NA"
        }
        return name
    }
    
    
    private func addReportee() {
        weak var weakself = self
        self.performSegue(withIdentifier: "ReporteeSelection", sender: weakself)
    }
    
   
    //MARK:- IBActions

    @IBAction func deleteMe(_ sender: Any) {
        CoreDataManager.sharedInstance.delete(person: self.person!) { (status: Bool
            ) in
           _ =  self.navigationController?.popViewController(animated: true)
        }
    }
   
    @IBAction func addSpouse(_ sender: Any) {
        showActions()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "ReporteeSelection" {
                let reporteeVC = segue.destination as! ReporteeSelectionViewController
                if let me = self.person {
                    reporteeVC.manager = me
                }
            }
        }
    }
    
    
}

// MARK: - UITableViewDataSource

extension PersonViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let me = self.person {
            if me.isManager() {
                return 2
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Personal Info"
        }
        if section == 1 {
            return "Reportees"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return totalRows
        }
        if section == 1 {
            return totalReportees
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        cell.textLabel?.textColor = UIColor.darkGray
        
        if indexPath.section == 0 {
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
            case 4:
                cell.textLabel?.text = "Manager : \(self.managerName())"
            default:
                break
            }
        }
        
        if indexPath.section == 1 {
            cell.textLabel?.text = self.reportees?[indexPath.row].name!
        }

        return cell
    }
}
