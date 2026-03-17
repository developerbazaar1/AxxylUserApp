//
//  DriverPayment.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 11/02/23.
//

import Foundation

struct DriverPaymentSummaryPayload : Codable {
    var action = Actions.driverPaymentSummary.rawValue
    var userId : String
}

struct DriverPaymentSummaryResponse: Decodable {
    var status : String
    var msg : String?
    var response: DriverPaymentSummaryResponseObj
    func isSuccess() -> Bool {
        return status == "1"
    }
}

struct DriverPaymentSummaryResponseObj: Decodable {
    var card : DriverPaymentSummaryCradObj
    var cash : DriverPaymentSummaryCashObj
}

struct DriverPaymentSummaryCradObj: Decodable {
    var Total_Ride : Int
    var total_airport_charge : Int
    var card : String
    var processingfee : Double
    var driver_Tip : Int
}

struct DriverPaymentSummaryCashObj: Decodable {
    var Total_Ride : Int
    var cash : String
    var driver_Tip : Int
    var total_airport_charge : Int
}

struct DriverUpdateWaitTimePayload : Codable {
    var action = Actions.updatewatingstart.rawValue
    var reqId: String
    var vendorId: String
}
