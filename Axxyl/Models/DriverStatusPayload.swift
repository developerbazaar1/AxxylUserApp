//
//  DriverStatusPayload.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 04/02/23.
//

import Foundation

struct DriverStatusPayload : Codable {
    var action = Actions.setting.rawValue
    var userId : String
    var bookingOn : String
}

struct GetDriverStatusPayload : Codable {
    var action = Actions.settingcheck.rawValue
    var userId : String
}

struct DriverLocationPayload : Codable {
    var action = Actions.updateLatLong.rawValue
    var userId : String
    var lat : Double
    var long : Double
}

struct DriversCurrentLocationPayload : Codable {
    var action = Actions.getlatlong.rawValue
    var userId : String
}
