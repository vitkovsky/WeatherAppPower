//
//  Coordinator.swift
//  WeatherAppPower
//
//  Created by Vitkovsky on 31.03.2026.
//

import UIKit

protocol CoordinatorProtocol {
    func start()
}

final class Coordinator: CoordinatorProtocol {
    
    private let window: UIWindow?
    private let navController: UINavigationController
    private let dependencies: Dependencies
    
    init(window: UIWindow?, dependencies: Dependencies, navController: UINavigationController) {
        self.window = window
        self.dependencies = dependencies
        self.navController = navController
    }
    
    func start() {
        
        let mainViewController = MainBuilder.build(
            dependencies: dependencies,
            onGoToSettingsButtonTap: goToAppSettings
        )
        
        navController.pushViewController(mainViewController, animated: false)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
    }
    
    func goToAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}


