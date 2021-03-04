//
//  AppDelegate.swift
//  MyPortfolio
//
//  Created by Tamási Móni on 2021. 03. 01..
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow? = nil
    var rootViewController: CompanyListViewController? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.rootViewController = CompanyListViewController(nibName: "CompanyListViewController", bundle: nil)
        self.window?.rootViewController = UINavigationController(rootViewController: self.rootViewController!)
        self.window?.makeKeyAndVisible()
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 24.0/255.0, green: 45.0/255.0, blue: 72.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().isTranslucent = false
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = textAttributes
            
        SocketManager.shared.delegate = self
        SocketManager.shared.connectToSocket(url: String(format: Constants.ServerUrl, Constants.APIToken))
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if SocketManager.shared.isConnected() {
            SocketManager.shared.disconnect()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if !SocketManager.shared.isConnected() {
            SocketManager.shared.delegate = self
            SocketManager.shared.connectToSocket(url: String(format: Constants.ServerUrl, Constants.APIToken))
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        SocketManager.shared.disconnect()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MyPortfolio")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate: SocketManagerDelegate {
    func connectionError(reason: String, code: UInt16) {
        if let navigationController = self.window?.rootViewController as? UINavigationController {
            DataManager.shared.hasConnection = false
            if navigationController.visibleViewController == self.rootViewController {
                self.rootViewController!.displayConnectionError(error: reason)
            }
        }
    }
    
    func connectionWasSuccessful() {
        DataManager.shared.hasConnection = true
        if let navigationController = self.window?.rootViewController as? UINavigationController {
            if navigationController.visibleViewController == self.rootViewController {
                self.rootViewController!.displayNoConnection(display: false)
            }
        }
        DataManager.shared.subscribeToCompanies()
    }
    
    func receivedString(message: String) {
        DataManager.shared.evaluateMessage(message: message)
        if let navigationController = self.window?.rootViewController as? UINavigationController {
            if navigationController.visibleViewController == self.rootViewController {
                self.rootViewController!.refreshList()
            }
        }
    }
    
    func receivedData(data: Data) { }
    
    func connectionWasClosed() {
        if let navigationController = self.window?.rootViewController as? UINavigationController {
            DataManager.shared.hasConnection = false
            if navigationController.visibleViewController == self.rootViewController {
                self.rootViewController!.displayNoConnection(display: true)
            }
        }
    }
}

