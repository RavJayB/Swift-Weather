import SwiftUI

struct DailyWeatherView: View {
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    @State var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading) {
            if isLoading {
                ProgressView("Loading weather Data...")
                    .padding()
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else if let dailyWeather = weatherMapPlaceViewModel.weatherDataModel?.daily {
                VStack(alignment: .leading) {
                    // Title
                    
                    HStack{
                        Image(systemName: "calendar").foregroundColor(.white)
                        Text("10-DAY FORECAST")
                            .font(.headline)
                            .foregroundColor(Color.white.opacity(0.6))
                    }

                    Divider()
                        .foregroundColor(Color.white.opacity(0.6))


                    // Forecast list
                    ScrollView {
                        ForEach(dailyWeather.indices, id: \.self) { index in
                            let daily = dailyWeather[index]
                            HStack {
                                // Day (Today or Weekday)
                                if index == 0 {
                                    Text("Today")
                                        .font(.custom("HelveticaNeueUltraThin", size: 16))
                                        .foregroundColor(.white)
                                        .frame(width: 70, alignment: .leading)
                                } else {
                                    Text(formatDate(dt: daily.dt))
                                        .font(.custom("HelveticaNeueUltraThin", size: 16))
                                        .foregroundColor(.white)
                                        .frame(width: 70, alignment: .leading)
                                }

                                // Weather Icon
                                Image(systemName: getWeatherIcon(icon: daily.weather.first?.icon ?? "questionmark.circle"))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.yellow)
                                    .padding(.horizontal, 8)

                                Spacer()

                                // Min Temp
                                Text("\(daily.temp.min, specifier: "%.f")°")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.white.opacity(0.6))

                                // Progress View
                                ProgressView(value: 0.5, total: 1)

                                // Max Temp
                                Text("\(daily.temp.max, specifier: "%.f")°")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                            }
                            .padding(5)
                            Divider()
                                .foregroundColor(Color.white.opacity(0.6))

                        }
                    }
                }
                .padding(.horizontal)
            } else {
                Text("No daily weather data available")
                    .foregroundStyle(.gray)
                    .padding()
            }
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(15)
        
//        .background(.ultraThinMaterial, in : RoundedRectangle(cornerRadius: 16.0))
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

    private func formatDate(dt: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(dt))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Full weekday name
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

#Preview {
    DailyWeatherView().environmentObject(WeatherMapPlaceViewModel())
}
