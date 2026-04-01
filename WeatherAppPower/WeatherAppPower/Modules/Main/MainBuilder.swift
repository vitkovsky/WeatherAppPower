
//
//  MainBuilder.swift
//  WeatherAppPower
//
//  Created by Vitkovsky on 31.03.2026.
//

import Foundation

enum MainBuilder {
    static func build(dependencies: Dependencies, onGoToSettingsButtonTap: @escaping () -> Void) -> MainViewController {
        
        let vm = MainViewModel(dependencies: dependencies, onGoToSettingsButtonTap: onGoToSettingsButtonTap)
        
        return MainViewController(viewModel: vm)
    }
}
