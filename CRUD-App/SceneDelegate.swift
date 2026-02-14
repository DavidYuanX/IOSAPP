//
//  SceneDelegate.swift
//  CRUD-App
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let userListVC = UserListViewController()
        let navigationController = UINavigationController(rootViewController: userListVC)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
