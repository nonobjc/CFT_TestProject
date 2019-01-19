//
//  CoreDataStack.swift
//  CFT_TestProject
//
//  Created by Alexander on 25/12/2018.
//  Copyright © 2018 Alexander. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataStack {
    
    // MARK: - Core Data stack (iOS 9 compatible)
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        return urls[urls.count - 1] as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "CFT_TestProject", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = applicationDocumentsDirectory.appendingPathComponent("CFT_TestProject.sqlite")
        var error: NSError? = nil
        let failureText = "There was an error creating or loading the application's saved data."
        do {
            guard let _ = try coordinator?.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: url,
                                                              options: nil) else {
                                                                coordinator = nil
                                                                fatalError(failureText)
            }
        } catch {
            print(error)
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if let context = managedObjectContext {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
}
