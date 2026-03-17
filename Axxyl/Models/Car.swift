//
//  Car.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 04/12/22.
//

import Foundation

struct Car {
    var number: String
    var color: String
    var model: String
    var type: String
    var wheelChairCapable: Bool
    var isSelected: Bool
    
    init(number: String, color: String, model: String, type: String, wheelChairCapable: Bool, isSelected: Bool) {
        self.number = number
        self.color = color
        self.model = model
        self.type = type
        self.wheelChairCapable = wheelChairCapable
        self.isSelected = isSelected
    }
}

struct DriverCar : Decodable {
    var category_id: String
    var car_number: String
    var carColor: String
    var carModel: String
   // var carType: String
   // var accomodateWheelchair: String
    var active:String
    
    func isActive() -> Bool{
        return self.active.lowercased() == "yes"
    }
    
//    func isaccomodateWheelchair() -> Bool{
//        return self.accomodateWheelchair.lowercased() == "yes"
//    }
}
