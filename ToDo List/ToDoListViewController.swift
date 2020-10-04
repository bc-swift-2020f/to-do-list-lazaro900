//
//  ViewController.swift
//  ToDo List
//
//  Created by Lazaro Alvelaez on 9/25/20.
//

import UIKit
import UserNotifications

class ToDoListViewController: UIViewController {
    
    var ToDoItems: [ToDoItem] = []
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadData()
        authorizeLocalNotifications()

    }
    
    
    func setNotification() {
        guard ToDoItems.count > 0 else {
            return
        }
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        for index in 0..<ToDoItems.count {
            if ToDoItems[index].reminderSet {
                let item = ToDoItems[index]
                ToDoItems[index].notificationID = setCalendarNotifications(title: item.name, subtitle: "", body: item.notes, badgeNumber: nil, sound: .default, date: item.date)
            }
        }
    }
    
    func authorizeLocalNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound]) { [self] (granted, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            
            if granted {
                print("Notification permission granted")
                
            } else {
                print("The user denied notifications")
            }
        
        }
    }
    
    func setCalendarNotifications(title: String, subtitle: String, body: String, badgeNumber: NSNumber?, sound: UNNotificationSound, date: Date) -> String {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = sound
        content.badge = badgeNumber
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        dateComponents.second = 00
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let notificationID = UUID().uuidString
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error! \(error.localizedDescription)")
            } else {
                print("Notification scheduled \(notificationID), title: \(content.title)")
            }
        }
        return notificationID
    }
    
    
    func loadData() {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentURL = directoryURL.appendingPathComponent("todos").appendingPathExtension("jsons")
        
        guard let data = try? Data(contentsOf: documentURL) else {return}
        let jsonDecoder = JSONDecoder()
        do {
            ToDoItems = try jsonDecoder.decode(Array<ToDoItem>.self, from: data)
            tableView.reloadData()
        } catch {
            print("Could not load data")

        }
    }
    
    func saveData() {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentURL = directoryURL.appendingPathComponent("todos").appendingPathExtension("jsons")
        
        let jsonEncoder = JSONEncoder()
        let data = try? jsonEncoder.encode(ToDoItems)
        
        do {
            try data?.write(to: documentURL, options: .noFileProtection)
        } catch {
            print("Could not save data")
        }
        
        setNotification()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let destination = segue.destination as! ToDoDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.toDoItem = ToDoItems[selectedIndexPath.row]
        } else {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
    }
    
    @IBAction func unwindFromDetail(segue: UIStoryboardSegue) {
        let source = segue.source as! ToDoDetailViewController
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            ToDoItems[selectedIndexPath.row] = source.toDoItem
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        } else {
            let newIndexPath = IndexPath(row: ToDoItems.count, section: 0)
            ToDoItems.append(source.toDoItem)
            tableView.insertRows(at: [newIndexPath], with: .bottom)
            tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
            
        }
        saveData()

    }


    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
            addBarButton.isEnabled = true
        } else {
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
            addBarButton.isEnabled = false
        }
    
    }
}

extension ToDoListViewController: UITableViewDelegate, UITableViewDataSource, listTableViewCellDelegate {
    
    func checkBoxToggle(sender: ListTableViewCell) {
        if let selectedIndexPath = tableView.indexPath(for: sender) {
            ToDoItems[selectedIndexPath.row].completed = !ToDoItems[selectedIndexPath.row].completed
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic )
            saveData() 
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection was just called. Returning \(ToDoItems.count)")
        return ToDoItems.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt was just called for indexPath.row = \(indexPath.row) which is cell containing \(ToDoItems[indexPath.row])")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListTableViewCell
        cell.delegate = self
        cell.toDoItem = ToDoItems[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ToDoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            saveData()

        }
        
    }
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = ToDoItems[sourceIndexPath.row]
            ToDoItems.remove(at: sourceIndexPath.row)
            ToDoItems.insert(itemToMove, at: destinationIndexPath.row)
        saveData()

    }
   
}

