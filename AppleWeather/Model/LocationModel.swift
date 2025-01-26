//
//  LocationModel.swift
//  AppleWeather
//
//  Created by ravindu bandara on 23/10/2024.
//

import Foundation
import SwiftData

// MARK:   LocationModel class to be used with SwiftData - database to store places information
// add suitable macro
//
//class LocationModel {
//
//    // MARK:  list of attributes to manage locations
//}


@Model
class FavouriteLocation {
    @Attribute(.unique) var name: String
    var addedAt: Date
    var latitude: Double
    var longitude: Double

    init(name: String, latitude: Double, longitude: Double, addedAt: Date = Date()) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.addedAt = addedAt
    }
}
