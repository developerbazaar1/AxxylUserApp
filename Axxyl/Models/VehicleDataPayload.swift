//
//  VehicleDataPayload.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 22/01/23.
//

import Foundation

struct AddMoreDriverCarsPayload : Encodable {
    var action = Actions.addMoreDriverCars.rawValue
    var userId : String
    var carTypeId : String
    var car_number : String
    var carColor : String
    var carModel : String
    var accomodateWheelChair : String
    var carType : String
}

struct EditDriverCarDetailsPayload : Encodable {
    var action = Actions.editDriverCarDetails.rawValue
    var carTypeId : String
    var old_car_number : String
    var car_number : String
    var carColor : String
    var carModel : String
    var accomodateWheelchair : Bool = false
} 

struct SelectDriverCarPayload : Encodable {
    var action = Actions.selectDriverCar.rawValue
    var carTypeId : String
    var userId: String
    var car_number : String
    var carColor : String
    var carModel : String
    var accomodateWheelchair : Bool = false
}

struct GetDriverCarsPayload : Encodable {
    var action = Actions.getDriverCarsList.rawValue
    var userId:String
}

struct DeleteDriverCarDetailsPayload : Encodable {
    var action = Actions.deleteDriveCarDetails.rawValue
    var userId:String
    var carTypeId : String
    var car_number : String
}

struct DriverCarsResponse: Decodable {
    var status : String
    var carDetails : [DriverCar]?
    var msg : String?
    
    func isSuccess() -> Bool {
        return status == "1"
    }
}

struct DeleteDriverCarResponse: Decodable {
    var status : String
    var msg : String?
    
    func isSuccess() -> Bool {
        return status == "1"
    }
}
