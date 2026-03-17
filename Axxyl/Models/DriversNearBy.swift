//
//  DriversNearBy.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 05/02/23.
//

import Foundation

struct DriversNearByPayload: Codable {
    var action = Actions.driversNearBy.rawValue
    var userId : String
    var lat : Double
    var long : Double
}

struct DriversNearByResponse: Decodable {
    var status : Int
    var msg : String?
    var vendor: [DriverNearByObj]    
    func isSuccess() -> Bool {
        return status == 1
    }
}

struct DriverNearByObj: Decodable {
    var name : String
    var emailId : String
    var vendorId : String
    var lat : String
    var long : String
    var distance : Double
}
