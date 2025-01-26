//
//  Weather.swift
//  AppleWeather
//
//  Created by ravindu bandara on 23/10/2024.
//

import SwiftUI

@main
struct AppleWeather: App {
    // MARK:  create a StateObject - weatherMapPlaceViewModel and inject it as an environmentObject.
    @StateObject private var weatherMapPlaceViewModel = WeatherMapPlaceViewModel()


    var body: some Scene {
        WindowGroup {
            NavBarView()
                .environmentObject(weatherMapPlaceViewModel)
                .modelContainer(for: [FavouriteLocation.self])
        // MARK:  Create a database to store locations using SwiftData
            
        }
    }
}
