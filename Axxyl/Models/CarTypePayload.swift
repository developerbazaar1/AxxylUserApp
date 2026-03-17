//
//  CarTypePayload.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 10/10/22.
//

import Foundation

struct CarTypePayload : Encodable {
    var action = Actions.carType.rawValue
    var handicapped : String
}
