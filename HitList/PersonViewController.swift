//
//  PersonViewController.swift
//  HitList
//
//  Created by Karunakar Bandikatla on 17/07/17.
//  Copyright © 2017 Karunakar Bandikatla. All rights reserved.
//

import UIKit

class PersonViewController: UIViewController {
    
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var addSpouseBarButton: UIBarButtonItem!
    
    let totalRows = 3
    var person: Person?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailCell")
        detailsTableView.separatorStyle = .none
        
        if let me = self.person,
            let name = me.name {
            self.title = name
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
        default:
            break
        }
        return cell
    }
    
}
