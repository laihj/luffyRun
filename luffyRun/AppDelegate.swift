//
//  AppDelegate.swift
//  luffyRun
//
//  Created by laihj on 2022/9/22.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var persistentContainer: NSPersistentContainer!
    let appCele = "appCele"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        createLuffyContainer { container in
//            self.persistentContainer = container
//
//            let storyboard = self.window?.rootViewController?.storyboard
//            guard let vc = storyboard?.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController
//            else {
//                fatalError("Cannot instantiate root view controller")
//            }
//            self.window?.rootViewController = vc
//        }
        createLuffyContainer { containers in
            self.persistentContainer = containers
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            PAriSandbox.shared.enableSwipe()
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

