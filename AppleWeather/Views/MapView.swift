
import SwiftUI
import MapKit
import CoreLocation
import SwiftData

struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let title: String
    let coordinate: CLLocationCoordinate2D
}

struct MapView: View {
    @Query(sort: \FavouriteLocation.addedAt, order: .reverse) private var favoriteLocations: [FavouriteLocation]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )
    @State private var annotations: [MapAnnotationItem] = []
    @State private var selectedCity: String? // For navigation
    @State private var isNavigatingToWeather = false // Trigger for navigation

    private let maxDelta: Double = 180.0 // Maximum allowable delta
    private let minDelta: Double = 0.005 // Minimum allowable delta

    var body: some View {
        NavigationStack {
            VStack {
                Map(coordinateRegion: $region, annotationItems: annotations) { annotation in
                    MapAnnotation(coordinate: annotation.coordinate) {
                        Button(action: {
                            selectedCity = annotation.title
                            isNavigatingToWeather = true
                        }) {
                            VStack {
                                Image(systemName: "pin.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.red)
                                Text(annotation.title)
                                    .font(.caption)
                                    .bold()
                                    .background(Color.white.opacity(0.7))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                .onAppear {
                    loadAnnotations()
                }
                .edgesIgnoringSafeArea(.all)

                HStack {
                    Button(action: zoomOut) {
                        Image(systemName: "minus.magnifyingglass")
                            .font(.title)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }

                    Button(action: zoomIn) {
                        Image(systemName: "plus.magnifyingglass")
                            .font(.title)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }
                .padding()
            }
            .navigationDestination(isPresented: $isNavigatingToWeather) {
                if let city = selectedCity {
                    CurrentWeatherView(locationName: city)
                }
            }
        }
    }

    private func loadAnnotations() {
        annotations = [] // Clear existing annotations
        let geocoder = CLGeocoder()
        let dispatchGroup = DispatchGroup()

        for location in favoriteLocations {
            dispatchGroup.enter()
            geocoder.geocodeAddressString(location.name) { placemarks, error in
                if let placemark = placemarks?.first,
                   let coordinate = placemark.location?.coordinate {
                    let annotation = MapAnnotationItem(title: location.name, coordinate: coordinate)
                    DispatchQueue.main.async {
                        annotations.append(annotation)
                    }
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            adjustRegionToFitAnnotations() // Adjust after all annotations are added
        }
    }


    private func adjustRegionToFitAnnotations() {
        guard !annotations.isEmpty else { return }

        var minLat = annotations.first!.coordinate.latitude
        var maxLat = annotations.first!.coordinate.latitude
        var minLon = annotations.first!.coordinate.longitude
        var maxLon = annotations.first!.coordinate.longitude

        for annotation in annotations {
            minLat = min(minLat, annotation.coordinate.latitude)
            maxLat = max(maxLat, annotation.coordinate.latitude)
            minLon = min(minLon, annotation.coordinate.longitude)
            maxLon = max(maxLon, annotation.coordinate.longitude)
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: max(minDelta, min(maxDelta, maxLat - minLat + 0.1)),
            longitudeDelta: max(minDelta, min(maxDelta, maxLon - minLon + 0.1))
        )

        region = MKCoordinateRegion(center: center, span: span)
    }

    private func zoomIn() {
        region.span.latitudeDelta = max(minDelta, region.span.latitudeDelta / 2)
        region.span.longitudeDelta = max(minDelta, region.span.longitudeDelta / 2)
    }

    private func zoomOut() {
        region.span.latitudeDelta = min(maxDelta, region.span.latitudeDelta * 2)
        region.span.longitudeDelta = min(maxDelta, region.span.longitudeDelta * 2)
    }
}

#Preview {
    MapView()
        .modelContainer(for: [FavouriteLocation.self])
}
