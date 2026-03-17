//
//  PickupResponse.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 24/10/22.
//

import Foundation


struct PickupResponse : Decodable {
    var msg : String?
    var status : String
    var rideId: String?
    
    func isSuccess() -> Bool {
        return status == "1"
    }
}
