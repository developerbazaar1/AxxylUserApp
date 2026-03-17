//
//  Booking.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 30/09/22.
//

import Foundation


struct RiderTrip {
    var totalTime : String
    var reqId : String
    var totalPrice : Double
    var geoDropCharge : String
    var geoPickupCharge : String
    var totalDistance : String
    var pickuplatLong : String
    var droplatLong : String
    var pickupTime : String
    var dropTime : String
    var date : String
    var name : String
    var phone : String
    var emailId : String
    var pickupLocation : String
    var dropLocation : String
    var status : String
    var venderId : String
    var avgspeed : String
    var driver_tip : Double
    var payment_type : String
    var another_status : String
    var car_number : String
    
    init(totalTime: String, reqId: String, totalPrice: Double, geoDropCharge: String, geoPickupCharge: String, totalDistance: String, pickuplatLong: String, droplatLong: String, pickupTime: String, dropTime: String, date: String, name: String, phone: String, emailId: String, pickupLocation: String, dropLocation: String, status: String, venderId: String, avgspeed: String, driver_tip: Double, payment_type: String, another_status: String, car_number: String) {
        self.totalTime = totalTime
        self.reqId = reqId
        self.totalPrice = totalPrice
        self.geoDropCharge = geoDropCharge
        self.geoPickupCharge = geoPickupCharge
        self.totalDistance = totalDistance
        self.pickuplatLong = pickuplatLong
        self.droplatLong = droplatLong
        self.pickupTime = pickupTime
        self.dropTime = dropTime
        self.date = date
        self.name = name
        self.phone = phone
        self.emailId = emailId
        self.pickupLocation = pickupLocation
        self.dropLocation = dropLocation
        self.status = status
        self.venderId = venderId
        self.avgspeed = avgspeed
        self.driver_tip = driver_tip
        self.payment_type = payment_type
        self.another_status = another_status
        self.car_number = car_number
    }
}
