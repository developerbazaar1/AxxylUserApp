//
//  RideEstimatedPricePayload.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 26/11/22.
//

import Foundation


struct RideEstimatedPricePayload : Encodable {
    var action = Actions.getEstimatedPriceDetails.rawValue
    var carId: String
    var pickuplatLong : String
    var droplatLong_1 : String
    var droplatLong_2 : String
    var droplatLong : String
    var origin : String
    var destination: String
}

