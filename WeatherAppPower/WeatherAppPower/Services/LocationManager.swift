//
//  LocationManager.swift
//  WeatherAppPower
//
//  Created by Vitkovsky on 31.03.2026.
//

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject {
    
    private let coreLocationManager: CLLocationManager
    
    private lazy var cancellables: Set<AnyCancellable> = []
    private lazy var statePublisher = PassthroughSubject<State, Error>()
    
    init(coreLocationManager: CLLocationManager) {
        self.coreLocationManager = coreLocationManager
    }
    
    func bind(_ input: Input) -> Output {
        coreLocationManager.delegate = self
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        handleLocationRequestPublisher(input.locationRequestPublisher)
        
        return Output(
            statePublisher: statePublisher.eraseToAnyPublisher()
        )
    }
}

private extension LocationManager {
    func handleLocationRequestPublisher(_ publisher: AnyPublisher<Void, Never>) {
        publisher
            .sink { [weak self] _ in
                guard let self else { return }
                
                let status = coreLocationManager.authorizationStatus
                
                handleAuthStatus(status)
            }
            .store(in: &cancellables)
    }
    
    func handleAuthStatus(_ status: CLAuthorizationStatus) {
        
        switch status {
            
        case .notDetermined:
            coreLocationManager.requestWhenInUseAuthorization()
            
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            coreLocationManager.requestLocation()
            
        default:
            statePublisher.send(.accessDenied)

        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        statePublisher.send(completion: .failure(AppError.locationError))
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        statePublisher.send(.location(location))
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        handleAuthStatus(status)
    }
}

extension LocationManager {
    struct Input {
        let locationRequestPublisher: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let statePublisher: AnyPublisher<State, Error>
    }
    
    enum State {
        case location(CLLocation)
        case accessDenied
    }
}
