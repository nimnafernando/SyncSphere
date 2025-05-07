//
//  WeatherService.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-05-07.
//

import Foundation

struct WeatherService {
    static let apiKey = "df2e59b76cf944334215859806216fd2"
    
    static func fetchCurrentWeather(city: String) async throws -> CurrentWeatherData {
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(query)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        // Print the raw JSON for debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw API response: \(jsonString)")
        }
        return try JSONDecoder().decode(CurrentWeatherData.self, from: data)
    }
}
