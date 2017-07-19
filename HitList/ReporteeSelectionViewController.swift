//
//  ReporteeSelectionViewController.swift
//  HitList
//
//  Created by Karunakar Bandikatla on 19/07/17.
//  Copyright © 2017 Karunakar Bandikatla. All rights reserved.
//

import UIKit
import CoreData

class ReporteeSelectionViewController: UIViewController {

    @IBOutlet weak var employeesListTableView: UITableView!
    
    var people: [NSManagedObject] = []
    var selectedPerson: Person?
    var manager: Person?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        employeesListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "employeesListCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CoreDataManager.sharedInstance.fetchEntity(name: Person.entityName(), by: Person.exceptManagers()) { (fetchResults: [NSManagedObject]) in
            
            let results: [NSManagedObject] = fetchResults
            self.people = results
            self.employeesListTableView.reloadData()
        }
    }
    
    func addSelectedReporteeToManager() {
        guard let managerObj = self.manager,
            let reportee = self.selectedPerson else {
                return
        }
        managerObj.addToReportees(reportee)
        CoreDataManager.sharedInstance.saveContext()
        _ =  self.navigationController?.popViewController(animated: true)
        
    }
    
    //MARK:- IBActions
    
    @IBAction func addReportee(_ sender: Any) {
        addSelectedReporteeToManager()
    }

}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ReporteeSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person: Person = people[indexPath.row] as! Person
        let cell = tableView.dequeueReusableCell(withIdentifier: "employeesListCell", for: indexPath)
        //name
        if let personName = person.name {
            cell.textLabel?.text = "\(indexPath.row+1). \(personName)"
        }
        else {
            cell.textLabel?.text = "NA"
        }
        //grade
        if person.isVIP() {
            cell.textLabel?.text = (cell.textLabel?.text)! + " "  + "(\((person as! VIP).grade!))"
        }
        
        if let managerObj = person.manager,
            let manager = self.manager {
            if managerObj == manager {
                cell.isUserInteractionEnabled = false
                cell.textLabel?.textColor = UIColor.lightGray
            }
        }
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedPerson = people[indexPath.row] as? Person
    }
    
}
