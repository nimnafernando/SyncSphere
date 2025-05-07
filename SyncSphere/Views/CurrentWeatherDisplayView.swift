//
//  DailyWeatherDisplayView.swift
//  SyncSphere
//
//  Created by W.N.R.Fernando on 2025-05-07.
//

import SwiftUI

struct CurrentWeatherDisplayView: View {
    let data: CurrentWeatherData

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(data.name), \(data.sys.country)")
                        .font(.title2).bold()
                    Text(data.weather.first?.main ?? "-")
                        .font(.headline)
                    Text(data.weather.first?.description.capitalized ?? "-")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if let icon = data.weather.first?.icon {
                    AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")) { image in
                        image.resizable().frame(width: 70, height: 70)
                    } placeholder: {
                        ProgressView()
                    }
                }
            }
            .padding(.bottom, 8)

            HStack(spacing: 24) {
                VStack {
                    Image(systemName: "thermometer")
                    Text("\(Int(data.main.temp))°C")
                        .font(.title2)
                    Text("Feels like \(Int(data.main.feels_like))°C")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                VStack {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.blue)
                    Text("Humidity")
                        .font(.caption)
                    Text("\(data.main.humidity)%")
                        .font(.headline)
                }
                VStack {
                    Image(systemName: "wind")
                        .foregroundColor(.gray)
                    Text("Wind")
                        .font(.caption)
                    Text("\(data.wind.speed) m/s")
                        .font(.headline)
                }
            }
            .padding(.vertical, 8)

            HStack(spacing: 24) {
                VStack {
                    Image(systemName: "cloud.fill")
                        .foregroundColor(.gray)
                    Text("Clouds")
                        .font(.caption)
                    Text("\(data.clouds.all)%")
                        .font(.headline)
                }
                VStack {
                    Image(systemName: "gauge")
                        .foregroundColor(.orange)
                    Text("Pressure")
                        .font(.caption)
                    Text("\(data.main.pressure) hPa")
                        .font(.headline)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.08)]),
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.vertical)
    }
} 
