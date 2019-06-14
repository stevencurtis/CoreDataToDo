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
    var objectContext: NSManagedObjectContext! = nil
    var entity: NSEntityDescription! = nil
    
    // alert must be within the view to keep it in scope, when added to the Window
    var alert: AlertViewController?
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        alert = UIStoryboard(name: Constants.alertStoryBoard, bundle: nil).instantiateViewController(withIdentifier: Constants.alerts.mainAlert) as? AlertViewController
        alert?.title = "Enter your task"

        alert?.presentToWindow()
        alert?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.entityName)
        do {
            tasks = try objectContext.fetch(fetchRequest)
            if tasks.count == 0 {
                let entityOne = NSEntityDescription.insertNewObject(forEntityName: Constants.entityName, into: objectContext)
                entityOne.setValue(false, forKey: Constants.entityCompletedattribute)
                entityOne.setValue("Enter your task", forKey: Constants.entityNameAttribute)
                tasks.append(entityOne)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        objectContext = appDelegate.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: Constants.entityName, in: objectContext)!
    }
    
    func save(task: String) {
        let taskObject = NSManagedObject(entity: entity, insertInto: objectContext)
        taskObject.setValue(task, forKeyPath: Constants.entityNameAttribute)
        do {
            try objectContext.save()
            tasks.append(taskObject)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let task = tasks[indexPath.row]
            tasks.remove(at: indexPath.row)
            objectContext.delete(task)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension ViewController: AlertsDelegate {
    func textValue(textFieldValue: String) {
        save(task: textFieldValue)
        tableView.reloadData()
    }
    
    
}

