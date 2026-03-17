//
//  DriverStatusResponse.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 04/02/23.
//

import Foundation

struct DriverStatusResponse : Decodable {
    var msg : String?
    var status : Int
    
    func isSuccess() -> Bool {
        return status == 1
    }
}

struct GetDriverStatusResponse : Decodable {
    var msg : String?
    var status : Int
    var bookingOn: String?
    
    func isSuccess() -> Bool {
        return status == 1
    }
}

struct DCLocation : Decodable {
    var id : String
    var lat : String
    var long : String
}

struct DriverLocationResponse : Decodable {
    var msg : String?
    var status : Int
    var response: DCLocation?
    
    func isSuccess() -> Bool {
        return status == 1
    }
}
