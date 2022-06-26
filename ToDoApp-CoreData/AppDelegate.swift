//
//  AppDelegate.swift
//  ToDoApp-CoreData
//
//  Created by admin on 17.06.2022.
//

import UIKit
import CoreData
import ChameleonFramework

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 13.0, *) {
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = UIColor.white
                    appearance.titleTextAttributes = [                     //Edits the title
                        NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont(name: "Verdana", size: 25)!
                    ]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont(name: "Verdana", size: 25)!]

                    let buttonAppearance = UIBarButtonItemAppearance()
                    buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
                    appearance.buttonAppearance = buttonAppearance

                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                    UINavigationBar.appearance().compactAppearance = appearance

                    UIBarButtonItem.appearance().tintColor = UIColor.white
                } else {
                    UINavigationBar.appearance().barTintColor = UIColor.systemCyan
                    UINavigationBar.appearance().titleTextAttributes = [
                        NSAttributedString.Key.foregroundColor: UIColor.white
                    ]
                    UINavigationBar.appearance().tintColor = UIColor.white

                    UIBarButtonItem.appearance().tintColor = UIColor.white
                }
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {

        self.saveContext()
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
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

