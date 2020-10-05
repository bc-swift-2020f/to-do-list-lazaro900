//
//  LocalNotificationManager.swift
//  ToDo List
//
//  Created by Lazaro Alvelaez on 10/4/20.
//

import UIKit
import UserNotifications


struct LocalNotificationManager {
    static func authorizeLocalNotifications(viewController: UIViewController) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound]) { [self] (granted, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            
            if granted {
                print("Notification permission granted")
                
            } else {
                print("The user denied notifications")
                
                DispatchQueue.main.sync {
                    viewController.oneButtonAlert(title: "User Has Not Allowed Notifications", message: "To Turn On Notifications, Go to Settings > To Do List > Notifications > Allow Notifications")                                        
                }
            }
        }
    }
    
    static func isAuthorized(completed: @escaping (Bool) -> ()) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound]) { [self] (granted, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                completed(false)
                return
            }
            
            if granted {
                print("Notification permission granted")
                completed(true)
                
            } else {
                print("The user denied notifications")
                completed(false)
                
            }
        }
    }
    
    static func setCalendarNotifications(title: String, subtitle: String, body: String, badgeNumber: NSNumber?, sound: UNNotificationSound, date: Date) -> String {
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
    
}
