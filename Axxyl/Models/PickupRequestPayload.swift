//
//  PickupRequestPayload.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 24/10/22.
//

import Foundation

struct PickupRequestPayload : Encodable {
    var action = Actions.pickupRequestDetails.rawValue
    var userId:String
    var lat : Double
    var long : Double
    var carTypeId: String
    var pickuplatLong : String
    var droplatLong : String
    var pickupLocation: String
    var sourcestate : String
    var dropLocation: String
}
