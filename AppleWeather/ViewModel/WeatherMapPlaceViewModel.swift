//
//  WeatherMapPlaceViewModel.swift
//  AppleWeather
//
//  Created by ravindu bandara on 23/10/2024.
//

import Foundation
import CoreLocation
class WeatherMapPlaceViewModel: ObservableObject {


    @Published var weatherDataModel: WeatherDataModel? // Data for the "onecall" API
        @Published var weatherModel: WeatherModel? // Data for the "weather" API
        @Published var isLoading: Bool = false
        @Published var newLocation = "COLOMBO"
        @Published var searchResults: [WeatherModel] = [] 
        @Published var favorites: [String] = ["London", "New York", "Tokyo"]
        @Published var errorMessage: String?
    
  
    
    func getCoordinatesForCity(city: String? = nil) async throws -> CLLocationCoordinate2D {
            let locationToSearch = city ?? newLocation
            let geocoder = CLGeocoder()

            do {
                let placemarks = try await geocoder.geocodeAddressString(locationToSearch)

                guard let firstPlacemark = placemarks.first,
                      let location = firstPlacemark.location else {
                    throw NSError(domain: "WeatherApp", code: 404, userInfo: [NSLocalizedDescriptionKey: "Location not found"])
                }

                return location.coordinate
            } catch {
                throw NSError(domain: "WeatherApp", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch coordinates: \(error.localizedDescription)"])
            }
        }

    // MARK:  function to fetch weather data safely from openweather using location coordinates

    func fetchWeatherData(lat: Double, lon: Double) async throws {

        // write code for this function with suitable comments
//        https://api.openweathermap.org/data/3.0/onecall?lat=50&lon=50&units=metric&appid=19002a6736dce98b2d635896cd45fd2d
        guard let url = URL(string: "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&units=metric&appid={add your You API key here}") else {
            print("Invalid url")
            return
        }
        
        do{
            let (data,response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                print("Invalid reponse code here")
                return
            }
            
            let decodeData = try JSONDecoder().decode(WeatherDataModel.self, from: data)
            print(decodeData)
            
            DispatchQueue.main.async {
                self.weatherDataModel = decodeData
            }
            
        } catch {
            throw NSError(domain: "WeatherApp", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch weather data: \(error.localizedDescription)"])
        }
    }

    // MARK:  function to get tourist places safely for a  map region and store for use in showing them on a map

    func setAnnotations() async throws{

    }
    
    
    func fetchWeatherCityData(for cityName: String) async throws {
            guard !cityName.isEmpty else {
                errorMessage = "City name cannot be empty."
                return
            }

            // Fetch city data (lat/lon and basic weather)
            let cityWeatherURL = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&units=metric&appid={add your You API key here}"
            guard let url = URL(string: cityWeatherURL) else {
                errorMessage = "Invalid URL for city weather data."
                return
            }

            DispatchQueue.main.async {
                self.isLoading = true
                self.errorMessage = nil
            }

            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NSError(domain: "WeatherApp", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server."])
                }

                let cityWeather = try JSONDecoder().decode(WeatherModel.self, from: data)
                DispatchQueue.main.async {
                    self.weatherModel = cityWeather
                }

                // Fetch detailed weather using OneCall API
                try await fetchWeatherData(lat: cityWeather.coord.lat, lon: cityWeather.coord.lon)

            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch city weather: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }

}


