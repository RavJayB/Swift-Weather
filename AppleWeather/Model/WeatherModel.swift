

import Foundation

struct WeatherModel: Codable, Identifiable {
    let id = UUID()                // Unique ID for Identifiable conformance
    let name: String               // City name
    let timezone: Int              // Timezone offset in seconds
    let coord: Coordinates         // Coordinates (latitude and longitude)
    let main: MainWeather          // Main weather details
    let weather: [Weather]         // Weather conditions (e.g., description, icon)
    let wind: Wind?                // Wind information (speed, direction)
    let sys: Sys                   // System information (sunrise, sunset)

    struct Coordinates: Codable {
        let lon: Double            // Longitude
        let lat: Double            // Latitude
    }

    struct MainWeather: Codable {
        let temp: Double           // Current temperature
        let feelsLike: Double      // Feels-like temperature
        let tempMin: Double        // Minimum temperature
        let tempMax: Double        // Maximum temperature
        let pressure: Int          // Atmospheric pressure
        let humidity: Int          // Humidity percentage

        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure
            case humidity
        }
    }

    struct Weather: Codable {
        let id: Int                // Weather condition ID
        let description: String    // Weather description
        let icon: String           // Weather icon code
    }

    struct Wind: Codable {
        let speed: Double          // Wind speed in m/s
        let deg: Int               // Wind direction in degrees
        let gust: Double?          // Wind gust speed in m/s
    }

    struct Sys: Codable {
        let sunrise: Int           // Sunrise time (Unix timestamp)
        let sunset: Int            // Sunset time (Unix timestamp)
    }

    enum CodingKeys: String, CodingKey {
        case name
        case timezone
        case coord
        case main
        case weather
        case wind
        case sys
    }
}


