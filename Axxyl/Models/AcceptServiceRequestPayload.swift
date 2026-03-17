//
//  AcceptServiceRequestPayload.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 04/02/23.
//

import Foundation

struct AcceptServiceRequestPayload : Codable {
    var action = Actions.acceptServiceReq.rawValue
    var userId : String
    var loginId : String
    var reqId : String
    var lat : Double
    var long : Double
}

struct ArrivedAtUserLocationRequestPayload : Codable {
    var action = Actions.arraiveatUser.rawValue
    var userId : String
    var loginId : String
    var reqId : String
}


struct ArrivedAtUserLocationNotifyRequestPayload : Codable {
    var action = Actions.arrivalNotificationToCustomer.rawValue
    var userId : String
    var loginId : String
    var reqId : String
    var buffer : String
}
