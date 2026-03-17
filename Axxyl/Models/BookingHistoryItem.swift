//
//  BookingHistoryItem.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 02/10/22.
//

import Foundation

struct BookingHistoryItem : Codable {
    var totalTime:String
    var reqId:String
    var totalPrice: Double?
    var geoDropCharge : String
    var geoPickupCharge : String
    var totalDistance: String
    var pickuplatLong: String
    var droplatLong:String?
    var pickupTime : String
    var dropTime: String
    var ratting: String?
    var date : String?
    var name : String
    var phone : String
    var emailId: String
    var pickupLocation : String?
    var dropLocation : String?
    var status : String
    var venderId : String?
    var avgspeed : String
    var driver_tip : Int?
    var payment_type : String
    var another_status : String
    var car_number : String
    var car_name : String
}
