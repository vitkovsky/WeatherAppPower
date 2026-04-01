//
//  MainViewModel.swift
//  WeatherAppPower
//
//  Created by Vitkovsky on 31.03.2026.
//

import Foundation
import Combine
import CoreLocation

final class MainViewModel: NSObject {
    
    // MARK: - private properties
    
    private let api: ApiProtocol
    private let locationManger: LocationManager
    private let onGoToSettingsButtonTap: () -> Void
    private let defaultCorrdinate = CLLocationCoordinate2D(latitude: 55.752222, longitude: 37.615556)
    
    // MARK: - publishers
    
    private var cancellables: Set<AnyCancellable> = []
    private var statePublisher = PassthroughSubject<MainViewController.State, Never>()
    private var locationRequestPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: -  initilizers
    
    init(dependencies: Dependencies, onGoToSettingsButtonTap: @escaping () -> Void) {
        self.api = dependencies.resolve()
        self.locationManger = dependencies.resolve()
        self.onGoToSettingsButtonTap = onGoToSettingsButtonTap
    }
    
    // MARK: - public methods
    
    func bind(_ input: Input) -> Output {
        
        handleLocationMager()
        handleReloadButtonPublisher(input.errorReloadButtonPublisher)
        handleReloadButtonPublisher(input.reloadButtonPublisher)
        handleGoToSettingsButtonPublisher(input.goToSettingsButtonPublisher)
        
        return Output(
            statePublisher: statePublisher.eraseToAnyPublisher()
        )
    }
}

// MARK: - private methods

private extension MainViewModel {
    
    func handleLocationMager() {
        
        let input = LocationManager.Input(
            locationRequestPublisher: locationRequestPublisher.eraseToAnyPublisher()
        )
        
        let output = locationManger.bind(input)
        
        handleLocationManagerStatePublisher(output.statePublisher)
        locationRequestPublisher.send()
    }
    
    func handleLocationManagerStatePublisher(_ publisher: AnyPublisher<LocationManager.State, Error>) {
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                print(status)
                switch status {
                    
                case .finished:
                    print("Received response from loaction manger")
                    
                case .failure(let error):
                    self?.statePublisher.send(.error(error))
                    
                }
                
            } receiveValue: { [weak self] state in
                
                switch state {
                    
                case .location(let location):
                    self?.statePublisher.send(.loading)
                    self?.getWeatherForLocation(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                    
                case .accessDenied:
                    self?.statePublisher.send(.error(AppError.locationError))
                    self?.statePublisher.send(.locationAuthRequiredAlert)
                    
                }
            }
            .store(in: &cancellables)
    }
    
    func getWeatherForLocation(latitude: Double, longitude: Double) {
        
        statePublisher.send(.loading)
        
        api.getWeatherInfoForLocation(lat: latitude, long: longitude)
            .sink { [weak self] result in
                
                switch result {
                    
                case .finished:
                    print("Finished fetching weather")
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.statePublisher.send(.error(error))
                }
                
            } receiveValue: { [weak self] weather in
                let weatherFormatted = WeatherFormatter.formatWeather(weather)
                self?.statePublisher.send(.loaded(weatherFormatted))
            }
            .store(in: &cancellables)
    }
    
    func handleReloadButtonPublisher(_ publisher: AnyPublisher<Void, Never>) {
        publisher
            .sink { [weak self] _ in
                self?.statePublisher.send(.loading)
                self?.locationRequestPublisher.send()
            }
            .store(in: &cancellables)
    }
    
    func handleGoToSettingsButtonPublisher(_ publisher: AnyPublisher<Void, Never>) {
        publisher
            .sink { [weak self] _ in
                self?.onGoToSettingsButtonTap()
            }
            .store(in: &cancellables)
    }
}

// MARK: - entities

extension MainViewModel {
    
    struct Input {
        let errorReloadButtonPublisher: AnyPublisher<Void, Never>
        let reloadButtonPublisher: AnyPublisher<Void, Never>
        let goToSettingsButtonPublisher: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let statePublisher: AnyPublisher<MainViewController.State, Never>
    }
}
