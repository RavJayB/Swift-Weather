//
//  HourlyWeatherView.swift
//  AppleWeather
//
//  Created by ravindu bandara on 23/10/2024.
//

import SwiftUI

struct HourlyWeatherView: View {
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Hourly Weather")
                .font(.custom("HelveticaNeueUltraThin", size: 16))
                .foregroundColor(.white)
            Divider()
                .foregroundColor(Color.white.opacity(0.6))

            if isLoading {
                ProgressView("Loading weather data...")
                    .padding()
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else if let hourlyData = weatherMapPlaceViewModel.weatherDataModel?.hourly, !hourlyData.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(hourlyData.indices, id: \.self) { index in
                            let hour = hourlyData[index]
                            VStack {
                                if index == 0 {
                                    Text("Now")
                                        .font(.custom("HelveticaNeueUltraThin", size: 16))
                                        .foregroundColor(.white)
                                } else {
                                    Text(formatDate(dt: hour.dt))
                                        .font(.custom("HelveticaNeueUltraThin", size: 16))
                                        .foregroundColor(.white)
                                }
                               
                                Image(systemName: getWeatherIcon(icon: hour.weather.first?.icon ?? "questionmark.circle"))
                                    .resizable()
                                    .frame(width: 40, height: 30)
                                    .foregroundColor(.yellow)
                                    .padding(5)
                                Text("\(hour.temp, specifier: "%.f")°")
                                    .font(.custom("HelveticaNeueUltraThin", size: 25))
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .cornerRadius(8)
                        }
                    }
                }
            } else {
                Text("No hourly data available.")
                    .foregroundColor(Color.red.opacity(0.6))
                    .padding()
            }
        }
        .padding()
//        .background(.ultraThinMaterial, in : RoundedRectangle(cornerRadius: 16.0))
        .background(Color.white.opacity(0.2))
        .cornerRadius(15)
        .onAppear {
            Task {
                do {
                    let coordinates = try await weatherMapPlaceViewModel.getCoordinatesForCity()
                    try await weatherMapPlaceViewModel.fetchWeatherData(lat: coordinates.latitude, lon: coordinates.longitude)
                    isLoading = false
                } catch {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    // MARK: - Helper Methods
    private func formatDate(dt: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(dt))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH" // Hour AM/PM format
        return formatter.string(from: date)
    }

    private func getWeatherIcon(icon: String) -> String {
        switch icon {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.fill"
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        case "03d", "03n": return "cloud.fill"
        case "04d", "04n": return "smoke.fill"
        case "09d", "09n": return "cloud.rain.fill"
        case "10d": return "cloud.sun.rain.fill"
        case "10n": return "cloud.moon.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "wind"
        default: return "questionmark.circle"
        }
    }
}

// MARK: - Preview
#Preview {
    // Ensure fetchWeatherData is not directly called in the preview
    HourlyWeatherView()
        .environmentObject(WeatherMapPlaceViewModel())
}




