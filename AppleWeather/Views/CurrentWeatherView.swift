//
//  CurrentWeatherView.swift
//  AppleWeather
//
//  Created by ravindu bandara on 23/10/2024.
//

import SwiftUI
import _SwiftData_SwiftUI

struct CurrentWeatherView: View {
    @StateObject var viewModel = WeatherMapPlaceViewModel()
    @State private var isLoading : Bool = true
    @State private var collapsed = false
    @Query var favorites: [FavouriteLocation]
    @State private var isFavorite = false
    @Environment(\.modelContext) private var context

    var locationName: String

    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel

    var body: some View {
        
        VStack(){
            VStack(alignment: .center){
                Text(locationName)
                    .font(collapsed ? Font.custom("HelveticaNeueUltraThin", size: 34) : Font.custom("HelveticaNeueUltraThin", size:44))
                    .foregroundColor(.white)
                    .animation(.easeInOut(duration: 0.2), value: collapsed)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("\(weatherMapPlaceViewModel.weatherDataModel?.current.temp ?? 0, specifier: "%.f")°")
                    .font(collapsed ? Font.custom("HelveticaNeueUltraThin", size: 34) : Font.custom("HelveticaNeueUltraThin", size:95))
                    .foregroundColor(.white)
                    .animation(.easeInOut(duration: 0.2), value: collapsed)

                if !collapsed {
                    Text(weatherMapPlaceViewModel.weatherDataModel?.current.weather.first?.weatherDescription.rawValue.capitalized ?? "No Description")
                        .font(.custom("HelveticaNeueUltraThin", size: 22))
                        .foregroundColor(.white)
                        .animation(.easeInOut(duration: 0.2), value: collapsed)

                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .zIndex(1) // Ensure header stays above content
            
            
            
            ScrollView{
                GeometryReader { geometry in
                    Color.clear
                        .onChange(of: geometry.frame(in: .global).minY) { value in
                            collapsed = value < -50 // Collapse header when scrolled up
                        }
                }
                .frame(height: 0) // Use GeometryReader without taking space
                
                VStack(){
                    if isLoading{
                        ProgressView()
                        .padding()

                    } else if let weatherData = weatherMapPlaceViewModel.weatherDataModel {
                        
                        ForecastWeatherView()
                     
//                        VStack{
//                            Text("precipitation")
//                                .font(.custom("HelveticaNeueUltraThin", size: 18))
//                                .foregroundColor(.white)
//                        }
//                        .background(.green)
                        
                        HStack(alignment: .top) {
                            VStack {
                                Text("FEELS LIKE")
                                    .font(.custom("HelveticaNeueUltraThin", size: 18))
                                    .foregroundColor(.white)
                                    .padding(.top)

                                Text("\(weatherData.current.feelsLike, specifier: "%.f")°")
                                    .font(.custom("HelveticaNeueUltraThin", size: 34))
                                    .foregroundColor(.white)
                                Text("Similar to the actual temperature")
                                    .font(.custom("HelveticaNeueUltraThin", size: 14))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 4)

                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)

                            VStack {
                                Text("UV INDEX")
                                    .font(.custom("HelveticaNeueUltraThin", size: 18))
                                    .foregroundColor(.white)
                                    .padding(.top)

                                Text("\(weatherData.current.uvi, specifier: "%.f")")
                                    .font(.custom("HelveticaNeueUltraThin", size: 34))
                                    .foregroundColor(.white)
//                                Text("Use sun protection")
//                                    .font(.custom("HelveticaNeueUltraThin", size: 14))
//                                    .foregroundColor(.white)
//                                    .multilineTextAlignment(.center)
//                                    .padding(.top, 4)

                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                        }
                        .padding()
                        
                        HStack {
                            Text("WIND")
                                .font(.custom("HelveticaNeueUltraThin", size: 18))
                                .foregroundColor(.white)
                                .padding(.trailing, 16)

                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Wind:")
                                        .bold()
                                        .font(.custom("HelveticaNeueUltraThin", size: 16))
                                        .foregroundColor(.white)
                                    Text("\(weatherData.current.windSpeed, specifier: "%.1f") km/h")
                                        .font(.custom("HelveticaNeueUltraThin", size: 16))
                                        .foregroundColor(.white)
                                }
                                
                                HStack {
                                    Text("Gusts:")
                                        .bold()
                                        .font(.custom("HelveticaNeueUltraThin", size: 16))
                                        .foregroundColor(.white)
                                    Text("\(weatherData.current.windGust ?? 0.0, specifier: "%.1f") km/h")
                                        .font(.custom("HelveticaNeueUltraThin", size: 16))
                                        .foregroundColor(.white)
                                }
                                
                                HStack {
                                    Text("Direction:")
                                        .bold()
                                        .font(.custom("HelveticaNeueUltraThin", size: 16))
                                        .foregroundColor(.white)
                                    Text("\(weatherData.current.windDeg, specifier: "%.1f")° \(windDirectionToCardinal(Double(weatherData.current.windDeg)))")
                                        .font(.custom("HelveticaNeueUltraThin", size: 16))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack {
                                ZStack {
                                    Image(systemName: "circle")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(Color.white.opacity(0.3))
                                    
                                    Image(systemName: "arrow.up")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(Color.white.opacity(0.3))
                                        .rotationEffect(Angle(degrees: Double(weatherData.current.windDeg)))
                                }
                                Text(windDirectionToCardinal(Double(weatherData.current.windDeg)))
                                    .font(.custom("HelveticaNeueUltraThin", size: 14))
                                    .foregroundColor(.white)
                                    .bold()
                                    .padding(.top, 8)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        
                        HStack(alignment: .top) {
                            VStack {
                                Text("SUNRISE")
                                    .font(.custom("HelveticaNeueUltraThin", size: 18))
                                    .foregroundColor(.white)
                                    .padding(.top)

                                Text(formatDate(dt: weatherData.current.sunrise!))
                                    .font(.custom("HelveticaNeueUltraThin", size: 34))
                                    .foregroundColor(.white)
                                HStack{
                                    Text("Sunset")
                                        .font(.custom("HelveticaNeueUltraThin", size: 14))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 4)
                                    
                                    Text(formatDate(dt: weatherData.current.sunset!))
                                        .font(.custom("HelveticaNeueUltraThin", size: 14))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 4)
                                }
                                Spacer()
                            }

                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)

                            VStack {
                                Text("PRECIPITATION")
                                    .font(.custom("HelveticaNeueUltraThin", size: 18))
                                    .foregroundColor(.white)
                                    .padding(.top)
                                Text("\(weatherData.current.uvi, specifier: "%.2f")")
                                    .font(.custom("HelveticaNeueUltraThin", size: 34))
                                    .foregroundColor(.white)
//                                Text("Use sun protection")
//                                    .font(.custom("HelveticaNeueUltraThin", size: 14))
//                                    .foregroundColor(.white)
//                                    .multilineTextAlignment(.center)
//                                    .padding(.top, 4)

                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                        }
                        .padding()
                        
                        HStack(alignment: .top) {
                            VStack {
                                Text("SUNSET")
                                    .font(.custom("HelveticaNeueUltraThin", size: 18))
                                    .foregroundColor(.white)
                                    .padding(.top)

                                Text(formatDate(dt: weatherData.current.sunset!))
                                    .font(.custom("HelveticaNeueUltraThin", size: 34))
                                    .foregroundColor(.white)
                                
                                HStack{
                                    Text("Sunrise")
                                        .font(.custom("HelveticaNeueUltraThin", size: 14))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 4)
                                    
                                    Text(formatDate(dt: weatherData.current.sunrise!))
                                        .font(.custom("HelveticaNeueUltraThin", size: 14))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 4)
                                }

                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)

                            VStack {
                                Text("HUMIDITY")
                                    .font(.custom("HelveticaNeueUltraThin", size: 18))
                                    .foregroundColor(.white)
                                    .padding(.top)
                                Text("\(weatherData.current.humidity) %")
                                    .font(.custom("HelveticaNeueUltraThin", size: 34))
                                    .foregroundColor(.white)
//                                Text("Use sun protection")
//                                    .font(.custom("HelveticaNeueUltraThin", size: 14))
//                                    .foregroundColor(.white)
//                                    .multilineTextAlignment(.center)
//                                    .padding(.top, 4)

                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                        }
                        .padding()
                    }
                }
                .padding()
            }
        }
        
        .onAppear {
                    fetchWeatherData(for: locationName)
                    isFavorite = favorites.contains(where: { $0.name == locationName })
//                    print("Favorites: \(favorites)")
//                    print("Is favorite: \(isFavorite)")

                }
        .onChange(of: locationName) { oldValue, newValue in
            fetchWeatherData(for: newValue)
        }
        .background(
            Image(getBackgroundImage())
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    toggleFavorite()
                }) {
                    Image(systemName: isFavorite ? "pin.fill" : "pin")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(isFavorite ? .yellow : .yellow)
                }
            }
        }
    }
    
    
    private func toggleFavorite() {
        if isFavorite {
            if let favorite = favorites.first(where: { $0.name == locationName }) {
                context.delete(favorite)
            }
        } else {
            if let weatherData = weatherMapPlaceViewModel.weatherModel {
                let newFavorite = FavouriteLocation(
                    name: locationName,
                    latitude: weatherData.coord.lat,
                    longitude: weatherData.coord.lon
                )
                context.insert(newFavorite)
            }
        }
        isFavorite.toggle()
    }

    

    func windDirectionToCardinal(_ degrees: Double) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"]
        let index = Int((degrees + 22.5) / 45.0) % 8
        return directions[index]
    }
    
    private func formatDate(dt: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(dt))
        let formatter = DateFormatter()
        formatter.dateFormat = "ha" // Hour AM/PM format
        return formatter.string(from: date)
    }
    
    private func fetchWeatherData(for location: String) {
            Task {
                do {
                    weatherMapPlaceViewModel.newLocation = location
                    let coordinates = try await weatherMapPlaceViewModel.getCoordinatesForCity()
                    try await weatherMapPlaceViewModel.fetchWeatherData(lat: coordinates.latitude, lon: coordinates.longitude)
                    isLoading = false
                } catch {
                    print("Error fetching weather data: \(error.localizedDescription)")
                    isLoading = false
                }
            }
        }
    
    private func getBackgroundImage() -> String {
            if let weatherData = weatherMapPlaceViewModel.weatherDataModel {
                let currentTime = Date().timeIntervalSince1970
                let sunriseTime = TimeInterval(weatherData.current.sunrise ?? 0)
                let sunsetTime = TimeInterval(weatherData.current.sunset ?? 0)

                // Determine if it's daytime or nighttime
                if currentTime >= sunriseTime && currentTime < sunsetTime {
                    return "sky-2" // Replace with the name of your daytime image
                } else {
                    return "sky-night" // Replace with the name of your nighttime image
                }
            }

            // Default background if no data is available
            return "BG"
        }
}


#Preview {
    CurrentWeatherView(locationName: "Colombo").environmentObject(WeatherMapPlaceViewModel())
}
