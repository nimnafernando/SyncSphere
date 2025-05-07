//
//  WeatherForcastView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-09.
//

import SwiftUI

struct WeatherForcastView: View {
    @StateObject private var viewModel = WeatherForecastViewModel()

    var body: some View {
        ZStack {
            GradientBackground()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Custom header
                HStack {
                    Image(systemName: "cloud.sun.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                    Text("Weather")
                        .font(.largeTitle).bold()
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.horizontal)

                // Note section
                noteSection

                if viewModel.isLoading {
                    ProgressView("Loading weather data...")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    inputSection
                } else if let data = viewModel.currentWeather {
                    CurrentWeatherDisplayView(data: data)
                    inputSection // Optionally allow new search below the card
                } else {
                    inputSection
                }
                Spacer()
            }
            .padding(.top, 24)
        }
    }

    var noteSection: some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.orange)
            Text("You are only able to view weather data for the current date.")
                .font(.footnote)
                .foregroundColor(.orange)
                .multilineTextAlignment(.leading)
        }
        .padding(10)
        .background(Color.white.opacity(0.7))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    var inputSection: some View {
        VStack(spacing: 16) {
            TextField("Enter location", text: $viewModel.location)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            Button(action: {
                Task { await viewModel.fetchWeather() }
            }) {
                Label("View Weather", systemImage: "magnifyingglass")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(viewModel.location.isEmpty)
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
    }
}

#Preview {
    WeatherForcastView()
}

