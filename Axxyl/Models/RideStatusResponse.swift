//
//  RideStatusResponse.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 22/01/23.
//

import Foundation

struct RideStatusResponse : Decodable {
    var msg : String?
    var status : String
    var Car : RideStatusCar?
    var User : RideStatusUser?
    var Ride : RideStatusRide?
    
    func isSuccess() -> Bool {
        return status == "1"
    }
}

struct RideStatusCar : Decodable {
    var carTypeId : String
    var car_number: String
    var carColor: String
    var carModel: String
}

struct RideStatusUser : Decodable {
    var name: String
    var fname: String
    var lname: String
    var phone: String
    var lat: String
    var lng: String
    var profile_image: String
}

struct RideStatusRide : Decodable {
    var userId : String
    var carTypeId: String
    var pickuplatLong: String
    var droplatLong: String
    var pickupLocation: String
    var dropLocation: String
    var droplatLong_1: String
    var dropLocation_1: String
    var droplatLong_1_status: String
    var droplatLong_2: String
    var dropLocation_2: String
    var droplatLong_2_status: String
    var rideId: String
    var rideStatus: String
    var geoDropCharge: String
    var geoPickupCharge: String
}
