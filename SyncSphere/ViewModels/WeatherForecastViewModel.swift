//
//  WeatherForecastViewModel.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-05-07.
//

import Foundation

@MainActor
class WeatherForecastViewModel: ObservableObject {
    @Published var location: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentWeather: CurrentWeatherData?

    func fetchWeather() async {
        isLoading = true
        errorMessage = nil
        currentWeather = nil
        do {
            let data = try await WeatherService.fetchCurrentWeather(city: location)
            self.currentWeather = data
        } catch {
            print("Weather fetch error: \(error)")
            self.errorMessage = "Something went wrong. Unable to load weather data."
        }
        isLoading = false
    }
} 
