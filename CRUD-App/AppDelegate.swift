//
//  AppDelegate.swift
//  CRUD-App
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        let userListVC = UserListViewController()
        let navigationController = UINavigationController(rootViewController: userListVC)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}
