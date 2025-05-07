//
//  WeatherModels.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-05-07.
//

import Foundation

struct CurrentWeatherData: Codable {
    let name: String
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let clouds: Clouds
    let dt: TimeInterval
    let sys: Sys
}

struct Weather: Codable {
    let main: String
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
}

struct Wind: Codable {
    let speed: Double
}

struct Clouds: Codable {
    let all: Int
}

struct Sys: Codable {
    let country: String
    let sunrise: TimeInterval
    let sunset: TimeInterval
} 
