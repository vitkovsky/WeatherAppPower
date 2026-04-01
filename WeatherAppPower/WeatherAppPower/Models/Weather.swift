//
//  Weather.swift
//  WeatherAppPower
//
//  Created by Vitkovsky on 31.03.2026.
//

import Foundation

// MARK: - Weather
struct Weather: Codable {
    let location: Location
    let current: Current
    let forecast: Forecast
}

// MARK: - Current
struct Current: Codable {
    let tempC: Double
    let condition: Condition
    let windKph: Double
    let windDir: String
    let time: String?
    let precipMm: Double
    let humidity: Int
    let feelslikeC: Double
    
    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case condition
        case windKph = "wind_kph"
        case windDir = "wind_dir"
        case precipMm = "precip_mm"
        case humidity
        case feelslikeC = "feelslike_c"
        case time
    }
}

// MARK: - Condition
struct Condition: Codable {
    let text, icon: String
}

// MARK: - Forecast
struct Forecast: Codable {
    let forecastday: [Forecastday]
}

// MARK: - Forecastday
struct Forecastday: Codable {
    let date: String
    let day: Day
    let hour: [Current]
}

// MARK: - Day
struct Day: Codable {
    let totalprecipMm: Double
    let avgtempC: Double
    let maxwindKph: Double
    let avghumidity: Int
    let condition: Condition
    
    enum CodingKeys: String, CodingKey {
        case avgtempC = "avgtemp_c"
        case maxwindKph = "maxwind_kph"
        case totalprecipMm = "totalprecip_mm"
        case avghumidity
        case condition
    }
}

// MARK: - Location
struct Location: Codable {
    let name, region: String
    let lat, lon: Double
    let localtime: String
}
