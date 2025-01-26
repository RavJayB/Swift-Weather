//
//  NavBarView.swift
//  AppleWeather
//
//  Created by ravindu bandara on 23/10/2024.
//

import SwiftUI

struct NavBarView: View {

    // MARK:  Varaible section - set up variable to use WeatherMapPlaceViewModel and SwiftData

    /*
     set up the @EnvironmentObject for WeatherMapPlaceViewModel
     Set up the @Environment(\.modelContext) for SwiftData's Model Context
     Use @Query to fetch data from SwiftData models

     State variables to manage locations and alertmessages
     */
    @StateObject var viewModel = WeatherMapPlaceViewModel()
        @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    @Environment(\.modelContext) private var context

    // MARK:  Configure the look of tab bar

    init() {
        // Customize TabView appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.9) 
        UITabBar.appearance().standardAppearance = appearance
//        UITabBar.appearance().scrollEdgeAppearance = appearance // Ensure it applies to scrollable edge
    }


    var body: some View {
        VStack{

            TabView {
                CurrentWeatherView(locationName: "Colombo") // Provide default location
                                    .environmentObject(weatherMapPlaceViewModel) // Pass the EnvironmentObject
                                    .tabItem {
                                        Label("Now", systemImage: "sun.max.fill")
                                    }
                MapView()
                    .tabItem {
                        Label("Place Map", systemImage: "map")
                    }
                VisitedPlacesView()
                    .tabItem{
                        Label("Stored Places", systemImage: "globe")
                    }
            } // TabView
            .background(Color.red.opacity(0.2))

            .onAppear {
                // MARK:  Write code to manage what happens when this view appears
            }
        }
    }
}

#Preview {
    NavBarView()
        .environmentObject(WeatherMapPlaceViewModel())
        .modelContainer(for: [FavouriteLocation.self])
}
