//
//  Api.swift
//  WeatherAppPower
//
//  Created by Vitkovsky on 31.03.2026.
//

import Foundation
import Combine
import UIKit

protocol ApiProtocol {
    func getWeatherInfoForLocation(lat: Double, long: Double) -> AnyPublisher<Weather, Error>
    func fetchImage(from urlString: String) async throws -> UIImage?
}

struct APIConfig {
    private static let obfuscatedKey: [UInt8] = [80, 4, 9, 0, 5, 2, 94, 84, 3, 0, 1, 81, 0, 87, 81, 95, 83, 3, 6, 80, 3, 81, 8, 82, 12, 87, 2, 84, 5, 81, 1]
    private static let salt = "6e1b6f8c7d5a4e3f2b1a0d9c8e7f6a5b4c3d2e1f0a9b8c7d6e5f4a3b2c1d0e9f"
    static let baseURL = "https://api.weatherapi.com/v1/"
    
    static var apiKey: String {
        let decoded = zip(obfuscatedKey, salt.utf8).map { $0 ^ $1 }
        return String(bytes: decoded, encoding: .utf8) ?? ""
    }
}

final class Api: ApiProtocol {
    private let networker: NetworkerProtocol
    
    private let weatherBaseUrl = APIConfig.baseURL
    private let apiKey = APIConfig.apiKey
    
    init(networker: NetworkerProtocol) {
        self.networker = networker
    }
    
    func getWeatherInfoForLocation(lat: Double, long: Double) -> AnyPublisher<Weather, Error> {
        guard let request = prepareRequest(.weatherInfo(lat, long)) else {
            return Fail(error: AppError.networkError(.badUrl)).eraseToAnyPublisher()
        }
        
        return networker.processRequest(request)
    }
    
    func fetchImage(from endpoint: String) async throws -> UIImage? {
        guard let prepareRequest = prepareRequest(.image(endpoint)) else { return nil }
        let (data, _) = try await URLSession.shared.data(for: prepareRequest)
        return UIImage(data: data)
    }
}

private extension Api {
    enum Request {
        case weatherInfo(Double, Double)
        case image(String)
        
        var httpMethod: String {
            switch self {
                default: "GET"
            }
        }
        
        var httpBody: Data? {
            switch self {
                default: nil
            }
        }
        
        var allHTTPHeaderFields: [String : String]? {
            switch self {
                default: nil
            }
        }
    }
    
    func prepareRequest(_ apiRequest: Api.Request) -> URLRequest? {
        let url: URL?
        
        switch apiRequest {
            
        case .weatherInfo(let lat, let long):
            url = URL(string: prepareUrlForLocation(lat: lat, long: long))
            
        case .image(let endpoint):
            url = URL(string: "https:" + endpoint)
        }
        
        guard let url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = apiRequest.httpMethod
        request.httpBody = apiRequest.httpBody
        request.allHTTPHeaderFields = apiRequest.allHTTPHeaderFields
        
        return request
    }
    
    func prepareUrlForLocation(lat: Double, long: Double) -> String {
        return weatherBaseUrl + "forecast.json?key=\(apiKey)" + "&q=\(lat),\(long)&days=7"
    }
}
