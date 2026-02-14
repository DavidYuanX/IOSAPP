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
        showRootViewController()
        window?.makeKeyAndVisible()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLogout),
            name: .didLogout,
            object: nil
        )
    }

    func showRootViewController() {
        if APIService.shared.isLoggedIn {
            let userListVC = UserListViewController()
            window?.rootViewController = UINavigationController(rootViewController: userListVC)
        } else {
            let loginVC = LoginViewController()
            loginVC.onLoginSuccess = { [weak self] in
                self?.showRootViewController()
            }
            window?.rootViewController = loginVC
        }
    }

    @objc private func handleLogout() {
        showRootViewController()
    }
}
