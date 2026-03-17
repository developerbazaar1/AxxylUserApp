//
//  CarTypeResponse.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 10/10/22.
//

import Foundation

struct CarType : Decodable {
    var name : String
    var price : String
    var carTypeId : String
    var seats : String
    var carTypeIcon : String
    var rental_price: String
}
struct CarTypeResponse : Decodable {
    var msg : String
    var status : Int
    var carType : [CarType]?
    
    func isSuccess() -> Bool {
        return status == 1
    }
}
