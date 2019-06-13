//
//  ViewController.swift
//  CoreDataToDo
//
//  Created by Steven Curtis on 13/06/2019.
//  Copyright © 2019 Steven Curtis. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tasks = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let objectContext = appDelegate.persistentContainer.viewContext
        let entityOne = NSEntityDescription.insertNewObject(forEntityName: Constants.entityName, into: objectContext)
        entityOne.setValue(false, forKey: Constants.entityCompletedattribute)
        entityOne.setValue("Enter your task", forKey: Constants.entityNameAttribute)

        tasks.append(entityOne)
        
        print (tasks)
    }


}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row].value(forKeyPath: Constants.entityNameAttribute) as? String
        return cell
    }
    
    
}

