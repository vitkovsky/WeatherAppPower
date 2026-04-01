//
//  Error.swift
//  WeatherAppPower
//
//  Created by Vitkovsky on 31.03.2026.
//

import Foundation

enum AppError: Error {
    case networkError(NetworkError)
    case locationError
    case unknownError(Error)
    
    var title: String {
        switch self {
        case .networkError:
            return "Network error"
        case .locationError:
            return "Location error"
        case .unknownError:
            return "Unknown error"
        }
    }
    
    var userDescription: String {
        switch self {
        case .networkError(let error):
            return "\(error.userDescription)"
        case .locationError:
            return "Check whether location services are enabled and access to location is granted. Try again later. It could take a while to get location."
        case .unknownError(let error):
            return error.localizedDescription
        }
    }
}

enum NetworkError: Error {
    case badUrl
    case badResponse
    case decodingFailed
    
    var userDescription: String {
        switch self {
        case .badUrl:
            return "Bad URL"
        case .badResponse:
            return "Bad response"
        case .decodingFailed:
            return "Decoding failed"
        }
    }
}
