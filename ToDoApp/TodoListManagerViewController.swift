//
//  ViewController.swift
//  ToDoApp
//
//  Created by Naomi Schettini on 6/22/18.
//  Copyright © 2018 Naomi Schettini. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class ViewController: UIViewController {
    
    //MARK:-
    //MARK:- Properties
    // IBOutlets
    @IBOutlet weak var todoListTableView: UITableView!
    
    
    // Class Vars
    var todos = [NSManagedObject]()
    var isGrantedNotificationAccess: Bool = false

    
    
    //MARK:-
    //MARK:- View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                self.isGrantedNotificationAccess = granted
        })
                
        title = "Things To Do"
        todoListTableView.register(UITableViewCell.self,
                                   forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "ToDo")
        
        //3
        do {
            todos = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    //MARK:-
    //MARK:- IBActions
    @IBAction func send2SecNotification(_ sender: UIButton) {
        if isGrantedNotificationAccess {
            let content = UNMutableNotificationContent()
            content.title = "New thing to do"
            content.subtitle = ""
            content.body = "Notification after 2 seconds - Your pizza is Ready!!"
            content.categoryIdentifier = "message"
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 02.0,
                repeats: false)
            let request = UNNotificationRequest(
                identifier: "02.second.message",
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(
                request, withCompletionHandler: nil)
        }
    }
    
    @IBAction func addATodo(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Todo",
                                      message: "Enter info about your new todo",
                                      preferredStyle: .alert)
        
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            
            guard let titleTextField = alert.textFields?.first,
                let todoString = titleTextField.text else {
                    return
            }
            guard let detailsTextField = alert.textFields?[1],
                let todoDetails = detailsTextField.text else {
                    return
            }
            guard let priorityTextField = alert.textFields?[2],
                let todoPriority = Int(priorityTextField.text!) else {
                    return
            }
            let newTodo = TodoItem(title: todoString, details: todoDetails, priority: todoPriority)
            
            self.save(todo: newTodo)
            self.todoListTableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter a title"
        }
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter details about your todo"
        }
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter a priority for your todo 1-5"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "By when would you like "
            textField.keyboardType = .numberPad
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
    
    //MARK:-
    //MARK:- Helper Methods
    func save(todo: TodoItem) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "ToDo",
                                       in: managedContext)!
        
        let newTodo = NSManagedObject(entity: entity,
                                      insertInto: managedContext)
        
        // 3
        newTodo.setValue(todo.title, forKeyPath: "title")
        newTodo.setValue(todo.details, forKeyPath: "detail")
        newTodo.setValue(todo.priority, forKeyPath: "priority")
        
        
        // 4
        do {
            try managedContext.save()
            todos.append(newTodo)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

//MARK:-
// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            let todo = todos[indexPath.row]
            let cell =
                tableView.dequeueReusableCell(withIdentifier: "Cell",
                                              for: indexPath)
            
            cell.textLabel?.text = todo.value(forKeyPath: "title") as? String
            
            return cell
    }
}

