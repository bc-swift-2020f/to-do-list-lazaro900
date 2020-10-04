//
//  ToDoItems.swift
//  ToDo List
//
//  Created by Lazaro Alvelaez on 10/4/20.
//

import Foundation

class ToDoItems {
    var itemArray: [ToDoItem] = []
    
    func saveData() {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentURL = directoryURL.appendingPathComponent("todos").appendingPathExtension("jsons")
         
        let jsonEncoder = JSONEncoder()
        let data = try? jsonEncoder.encode(itemArray)
        
        do {
            try data?.write(to: documentURL, options: .noFileProtection)
        } catch {
            print("Could not save data")
        }
    }
    
    func loadData(completed: @escaping () -> () ) {
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let documentURL = directoryURL.appendingPathComponent("todos").appendingPathExtension("jsons")
    
            guard let data = try? Data(contentsOf: documentURL) else {return}
            let jsonDecoder = JSONDecoder()
            do {
                itemArray = try jsonDecoder.decode(Array<ToDoItem>.self, from: data)
            } catch {
                print("Could not load data")
    
            }
        
            completed()
        }
    
    
}
