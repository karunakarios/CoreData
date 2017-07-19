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
            self.people = fetchResults
            self.employeesListTableView.reloadData()
        }
    }
    
    func addSelectedReporteeToManager() {
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
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         self.selectedPerson = people[indexPath.row] as? Person
        self.addSelectedReporteeToManager()
    }
    
}
