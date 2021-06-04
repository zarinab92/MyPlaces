//
//  SceneDelegate.swift
//  MyPlaces
//
//  Created by Zarina Bekova on 10/17/20.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // Code Core Data -> Persistent Container -> 1. NSManagedObjectModel 2. NSPersistentStoreCoordinator (SQLite)   3. NSManagedObjectContext (creating object (NSManagedObject) and save or fetch data ) -> Core Data Stack
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Could not load data store: \(error.localizedDescription)")
            }
        }

        return container
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = persistentContainer.viewContext
    
    // Child -> Parent = false
    // Parent -> Child = ok

    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let tabController = window!.rootViewController as! UITabBarController
        
        // first Tab
        if let navigationController = tabController.viewControllers?[0] as? UINavigationController {
            let currentLocationVC = navigationController.viewControllers.first as! CurrentLocationVC
            currentLocationVC.managedObjectContext = managedObjectContext
        }
        
        // second Tab
        
        if let navigationController = tabController.viewControllers?[1] as? UINavigationController {
            let savedLocationsTVC = navigationController.viewControllers.first as! SavedLocationsTVController
            savedLocationsTVC.managedObjectContext = managedObjectContext
        }
        
        // third Tab
        
        if let navigationController = tabController.viewControllers?[2] as? UINavigationController {
            let mapVC = navigationController.viewControllers.first as! MapViewController
            mapVC.managedObjectContext = managedObjectContext
        }
        
        print(appDocumentsDirectory())
        
        listenForCoreDataErrors()
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
    // MARK: - Helping Methods
    
    func listenForCoreDataErrors() {
        NotificationCenter.default.addObserver(forName: CoreDataErrorNotification, object: nil, queue: OperationQueue.main) { (notifiaction) in
            
            let message = "There was a fatal error in the app and cannot continue. Press OK to terminate the app. Sorry for the inconvenience :("
            
            let alert = UIAlertController(title: "Internal Error", message: message, preferredStyle: .alert)
            
            let okButton = UIAlertAction(title: "OK", style: .default) { (_) in
                // fatalError() // or
                let exception = NSException(name: NSExceptionName.internalInconsistencyException, reason: "Fatal Core Data Error", userInfo: nil)
                
                exception.raise()
            }
            
            alert.addAction(okButton)
            
            let tabBarController = self.window!.rootViewController!
            
            tabBarController.present(alert, animated: true, completion: nil)
        }
    }


}

