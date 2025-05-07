//
//  WeatherForecastViewModelTests.swift
//  SyncSphereTests
//
//  Created by W.N.R.Fernando on 2025-05-07.
//

import XCTest
@testable import SyncSphere

@MainActor
final class WeatherForecastViewModelTests: XCTestCase {
    
    var viewModel: WeatherForecastViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = WeatherForecastViewModel()
    }
    
    override func tearDown() async throws {
        viewModel = nil
        try await super.tearDown()
    }
    
    func testFetchWeatherSuccess() async {
        // Given
        viewModel.location = "London"
        
        // When
        await viewModel.fetchWeather()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNotNil(viewModel.currentWeather)
        XCTAssertEqual(viewModel.currentWeather?.name, "London")
    }
    
    func testFetchWeatherFailure() async {
        // Given
        viewModel.location = "NonExistentCity123"
        
        // When
        await viewModel.fetchWeather()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.currentWeather)
    }
    
    func testFetchWeatherEmptyLocation() async {
        // Given
        viewModel.location = ""
        
        // When
        await viewModel.fetchWeather()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.currentWeather)
    }
}

