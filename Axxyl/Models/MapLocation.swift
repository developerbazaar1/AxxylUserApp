//
//  MapLocation.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 09/10/22.
//

import Foundation

struct MapLocation: Equatable, Codable {
    var id: Int?
    var name: String?
    var phoneNumber: String?
    var address: String?
    var latitude: Double?
    var longitude: Double?
//    If require in future then only we will parase these
//    var street: String?
//    var city: String?
//    var zip: String?
//    var country: String?
//    var countryCode: String?
//    var state: String?
//    var placemark: String?
//    var timezone: String?
//    var subAdministrativeArea: String?
//    var subLocality: String?
//    var thoroughfare: String?
//    var regionRadius: Float?
    
    init(id: Int? = nil, name: String? = nil, phoneNumber: String? = nil, address: String? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
}
