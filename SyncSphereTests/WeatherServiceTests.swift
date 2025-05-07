//
//  WeatherServiceTests.swift
//  SyncSphereTests
//
//  Created by W.N.R.Fernando on 2025-05-07.
//

import XCTest
@testable import SyncSphere

final class WeatherServiceTests: XCTestCase {
    
    
    func testFetchCurrentWeatherSuccess() async throws {
        // Given
        let city = "London"
        
        // When
        let weatherData = try await WeatherService.fetchCurrentWeather(city: city)
        
        // Then
        XCTAssertNotNil(weatherData)
        XCTAssertEqual(weatherData.name, city)
        XCTAssertNotNil(weatherData.weather)
        XCTAssertNotNil(weatherData.main)
        XCTAssertNotNil(weatherData.wind)
        XCTAssertNotNil(weatherData.clouds)
        XCTAssertNotNil(weatherData.sys)
    }
    
    func testFetchCurrentWeatherInvalidCity() async {
        // Given
        let invalidCity = "NonExistentCity123"
        
        // When/Then
        do {
            _ = try await WeatherService.fetchCurrentWeather(city: invalidCity)
            XCTFail("Expected error for invalid city")
        } catch {
            XCTAssertTrue(error is URLError || error is DecodingError)
        }
    }
    
    func testFetchCurrentWeatherEmptyCity() async {
        // Given
        let emptyCity = ""
        
        // When/Then
        do {
            _ = try await WeatherService.fetchCurrentWeather(city: emptyCity)
            XCTFail("Expected error for empty city")
        } catch {
            XCTAssertTrue(error is URLError || error is DecodingError)
        }
    }
    
    func testFetchCurrentWeatherSpecialCharacters() async throws {
        // Given
        let cityWithSpecialChars = "New York"
        
        // When
        let weatherData = try await WeatherService.fetchCurrentWeather(city: cityWithSpecialChars)
        
        // Then
        XCTAssertNotNil(weatherData)
        XCTAssertEqual(weatherData.name, "New York")
    }
}


