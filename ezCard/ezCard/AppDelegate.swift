//
//  AppDelegate.swift
//  ezCard
//
//  Created by Andrew Whitehead on 2/27/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import Firebase

extension UIViewController {
    func embeddedInNavigationController() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let homeViewController = HomeViewController(style: .grouped)
        homeViewController.tabBarItem = UITabBarItem(title: "Home", image: #imageLiteral(resourceName: "home"), tag: 0)
        
        let scanViewController = ScanViewController()
        scanViewController.tabBarItem = UITabBarItem(title: "Scan", image: #imageLiteral(resourceName: "qrCode"), tag: 1)
        
        let contactsViewController = ContactsViewController(style: .grouped)
        contactsViewController.tabBarItem = UITabBarItem(title: "Contacts", image: #imageLiteral(resourceName: "people"), tag: 2)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [homeViewController.embeddedInNavigationController(),
                                            scanViewController.embeddedInNavigationController(),
                                            contactsViewController.embeddedInNavigationController()]
        
        window!.rootViewController = tabBarController
    
        window!.makeKeyAndVisible()
        
        UITableView.appearance().backgroundColor = #colorLiteral(red: 0.9371625781, green: 0.9373195171, blue: 0.9371418357, alpha: 1)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

