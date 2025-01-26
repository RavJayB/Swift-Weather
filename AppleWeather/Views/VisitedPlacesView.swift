import SwiftUI
import SwiftData

struct VisitedPlacesView: View {
    @StateObject var viewModel = WeatherMapPlaceViewModel()
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    @State private var searchText: String = ""
    @State private var selectedCityWeather: WeatherModel?
    @State private var isNavigatingToWeather = false
    @State private var cityTemperatures: [String: String] = [:]
    @State private var isLoading = true // Add loading state
    @State private var errorMessage: String? 
    
    @Environment(\.modelContext) private var context
    @Query(sort: \FavouriteLocation.addedAt, order: .reverse) private var favoriteLocations: [FavouriteLocation]

    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar with a Button
                HStack {
                    TextField("Search for a city", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    Button(action: {
                        Task {
                            await fetchCityWeather()
                        }
                    }) {
                        Text("Search")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()

                // Favorites Section with Temperatures
                if !favoriteLocations.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Favourite Cities")
                            .font(.headline)
                            .padding(.horizontal)

                        List {
                            ForEach(favoriteLocations) { location in
                                Button(action: {
                                    Task {
                                        await fetchCityWeather(for: location.name)
                                    }
                                }) {
                                    HStack {
                                        Text(location.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity, alignment: .leading) // Align text to the left
                                        
                                        if let temp = cityTemperatures[location.name] {
                                            Text("\(temp)°")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.7))
                                                .frame(maxWidth: .infinity, alignment: .trailing) // Align temperature to the right
                                        } else {
                                            Text("Fetching temperature...")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.7))
                                                .frame(maxWidth: .infinity, alignment: .trailing) // Align fetching text to the right
                                                .onAppear {
                                                    fetchTemperature(for: location.name)
                                                }
                                        }
                                    }

                                    .padding()
                                    .background(Color.blue).cornerRadius(8)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

                                }
                            }
                            .onDelete(perform: deleteFavorite)
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                        .background(Color.white)
                    }
                }

                if viewModel.isLoading {
                    ProgressView("Fetching weather data...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()
            }
            .navigationTitle("Weather")
            .navigationDestination(isPresented: $isNavigatingToWeather) {
                if let weather = selectedCityWeather {
                    CurrentWeatherView(locationName: weather.name)
                        .environmentObject(viewModel)
                }
            }
            .onAppear {
                resetStateIfNavigatingBack()
            }
        }
//        .toolbar {
//            
//            ToolbarItem(placement: .navigationBarTrailing) {
//                if let selectedWeather = selectedCityWeather {
//                    Button(action: {
//                        toggleFavorite(selectedWeather.name)
//                    }) {
//                        Image(systemName: isFavorite(selectedWeather.name) ? "star.fill" : "star")
//                            .resizable()
//                            .frame(width: 24, height: 24)
//                            .foregroundColor(isFavorite(selectedWeather.name) ? .yellow : .gray)
//                    }
//                }
//            }
//        }
    }
    
    private func fetchTemperature(for cityName: String) {
        Task {
            do {
                try await viewModel.fetchWeatherCityData(for: cityName)
                if let weatherData = viewModel.weatherModel {
                    DispatchQueue.main.async {
                        cityTemperatures[cityName] = String(format: "%.1f", weatherData.main.temp)
                    }
                }
            } catch {
                print("Error fetching temperature for \(cityName): \(error.localizedDescription)")
            }
        }
    }

    /// Fetch city weather and navigate to `CurrentWeatherView`
    private func fetchCityWeather(for cityName: String? = nil) async {
        let cityToFetch = cityName ?? searchText
        guard !cityToFetch.isEmpty else {
            viewModel.errorMessage = "Please enter a city name."
            return
        }

        do {
            viewModel.isLoading = true // Show the progress bar
            try await viewModel.fetchWeatherCityData(for: cityToFetch)
            viewModel.isLoading = false // Stop showing the progress bar

            if let weather = viewModel.weatherModel {
                selectedCityWeather = weather
                isNavigatingToWeather = true // Trigger navigation to CurrentWeatherView
            } else {
                viewModel.errorMessage = "City not found or no weather data available."
            }
        } catch {
            viewModel.isLoading = false
            viewModel.errorMessage = error.localizedDescription
        }
    }

    private func toggleFavorite(_ cityName: String) {
        if isFavorite(cityName) {
            if let favorite = favoriteLocations.first(where: { $0.name == cityName }) {
                context.delete(favorite)
            }
        } else {
            // Ensure the WeatherModel has latitude and longitude
            if let weatherData = viewModel.weatherModel {
                let newFavorite = FavouriteLocation(
                    name: cityName,
                    latitude: weatherData.coord.lat,
                    longitude: weatherData.coord.lon,
                    addedAt: Date()
                )
                withAnimation {
                    context.insert(newFavorite)
                    try? context.save()
                }
            }
        }
    }

    /// Check if a city is in favorites
    private func isFavorite(_ cityName: String) -> Bool {
        favoriteLocations.contains(where: { $0.name == cityName })
    }

    /// Delete a favorite city
    private func deleteFavorite(at offsets: IndexSet) {
        for index in offsets {
            context.delete(favoriteLocations[index])
        }
        withAnimation {
            try? context.save()
        }
    }

    /// Reset state when navigating back to `VisitedPlacesView`
    private func resetStateIfNavigatingBack() {
        viewModel.isLoading = false
        viewModel.errorMessage = nil
        searchText = ""
        selectedCityWeather = nil
    }
    
}

#Preview {
    VisitedPlacesView()
        .modelContainer(for: [FavouriteLocation.self])
}

