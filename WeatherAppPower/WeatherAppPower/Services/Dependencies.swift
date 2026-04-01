//
//  Dependencies.swift
//  WeatherAppPower
//
//  Created by Vitkovsky on 31.03.2026.
//

import Foundation
import CoreLocation

final class Dependencies {
    static var shared = Dependencies()
    
    private lazy var session = URLSession.shared
    private lazy var decoder = JSONDecoder()
    private lazy var networker = Networker(session: resolve(), decoder: resolve())
    private lazy var api = Api(networker: resolve())
    private lazy var coreLocationManager = CLLocationManager()
    private lazy var locationManager = LocationManager(coreLocationManager: resolve())
    
    private init() {}
    
    func resolve() -> URLSession {
        return session
    }
    
    func resolve() -> JSONDecoder {
        return decoder
    }
    
    func resolve() -> NetworkerProtocol {
        return networker
    }
    
    func resolve() ->  ApiProtocol {
        return api
    }
    
    func resolve() -> CLLocationManager {
        return CLLocationManager()
    }
    
    func resolve() -> LocationManager {
        return locationManager
    }
}
