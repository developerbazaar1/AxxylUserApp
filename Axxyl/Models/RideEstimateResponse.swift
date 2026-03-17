//
//  RideEstimateResponse.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 26/11/22.
//

import Foundation

struct CarCategory : Decodable {
    var ID : String
    var name : String
    var seats : String
    var price : String
    var total: Double
    
    func displayTotalPrice() -> String {
        return String(format: "$%.2f", total)
    }
}

struct RideEstimateResponse : Decodable {
    var msg : String?
    var status : Int
    var catPriceList : [CarCategory]?
    var geoPickPrice: Double? = 10.0
    var geoDropPrice: Double? = 0.0
    var distance: String?
    var time: String?
    func isSuccess() -> Bool {
        return status == 1
    }
}
