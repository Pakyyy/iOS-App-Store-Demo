//
//  SceneDelegate.swift
//  AppStoreDemo
//
//  Created by Patrick Tang on 8/7/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // To keep thing simple, I just inject the model here instead of making a factory to handle them all.
        let dataManager = CoreDataManager()
        let networkManager = NetworkManager()

        let mainListViewModel = MainListViewModel(dataManager: dataManager, networkManager: networkManager)
        window?.rootViewController = MainListViewController(with: mainListViewModel)
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}

}

