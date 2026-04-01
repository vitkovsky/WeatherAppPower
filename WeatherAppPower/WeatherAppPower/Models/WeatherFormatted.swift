//
//  WeatherFormatted.swift
//  WeatherAppPower
//
//  Created by Vitkovsky on 31.03.2026.
//

import Foundation

struct CurrentWeather: Hashable {
    let location: String
    let currentTemperature: String
    let conditionDescription: String
    let currentConditionImageUrl: String
    let feelsLikeTemperature: String
    let precipitationMm: String
    let windSpeed: String
    let windDirection: String
    let humidity: String
}

struct HourlyWeather: Hashable {
    let time: String
    let conditionImageUrl: String
    let temperature: Double
}

struct DailyWeather: Hashable {
    var date: String
    let conditionImageUrl: String
    let conditionDescription: String
    let avgTemp: String
    let maxWind: String
    let avgHumidity: String
}

struct WeatherFormatted {
    let currentWeather: CurrentWeather
    let hourlyWeather: [HourlyWeather]
    let dailyWeather: [DailyWeather]
}
