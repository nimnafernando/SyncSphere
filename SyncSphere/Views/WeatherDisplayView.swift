////
////  WeatherDisplayView.swift
////  SyncSphere
////
////  Created by W.N.R.Fernando on 2025-05-07.
////
//
//import SwiftUI
//
//struct WeatherDisplayView: View {
//    let data: WeatherData
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            // Current Weather Card
//            HStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Today")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
////                    Text(data.daily)
////                        .font(.subheadline)
////                        .foregroundColor(.secondary)
//                    Text(data.current.weather.first?.main ?? "-")
//                        .font(.title2).bold()
//                    HStack(spacing: 16) {
//                        Text("\(Int(data.current.temp))°")
//                            .font(.largeTitle).bold()
//                        HStack(spacing: 4) {
//                            Image(systemName: "drop.fill")
//                                .foregroundColor(.blue)
//                            Text("\(data.current.humidity)%")
//                        }
//                        HStack(spacing: 4) {
//                            Image(systemName: "wind")
//                                .foregroundColor(.gray)
//                            Text(String(format: "%.1f m/s", data.current.windSpeed))
//                        }
//                    }
//                }
//                Spacer()
//                VStack {
//                    if let icon = data.current.weather.first?.icon {
//                        AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")) { image in
//                            image.resizable().frame(width: 60, height: 60)
//                        } placeholder: {
//                            ProgressView()
//                        }
//                    }
//                }
//            }
//            .padding()
//            .background(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom))
//            .cornerRadius(16)
//
//            Text("Next 7 Days")
//                .font(.headline)
//                .padding(.top)
//
//            ForEach(data.daily.prefix(7), id: \ .dt) { day in
//                HStack {
//                    if let icon = day.weather.first?.icon {
//                        AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")) { image in
//                            image.resizable().frame(width: 32, height: 32)
//                        } placeholder: {
//                            ProgressView()
//                        }
//                    }
//                    Text(dayOfWeek(from: day.dt))
//                        .frame(width: 90, alignment: .leading)
//                    Spacer()
//                    Text("\(day.weather.first?.main ?? "-")")
//                    Spacer()
//                    Text("\(day.humidity)%")
//                        .frame(width: 40, alignment: .trailing)
//                    Image(systemName: "thermometer")
//                    Text("\(Int(day.temp.min))°/\(Int(day.temp.max))°")
//                        .frame(width: 60, alignment: .trailing)
//                }
//                .padding(8)
//                .background(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.7), Color.yellow.opacity(0.1)]), startPoint: .top, endPoint: .bottom))
//                .cornerRadius(12)
//            }
//            Spacer()
//        }
//        .padding()
//    }
//    
//    func dayOfWeek(from time: TimeInterval) -> String {
//        let date = Date(timeIntervalSince1970: time)
//        let formatter = DateFormatter()
//        formatter.dateFormat = "EEEE"
//        return formatter.string(from: date)
//    }
//} 
