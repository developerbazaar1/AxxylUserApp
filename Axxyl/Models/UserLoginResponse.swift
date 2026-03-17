//
//  UserLoginResponse.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 28/09/22.
//

import Foundation

struct UserInfo : Codable {
    var handicapped: String
    var id: String
    var name: String
    var emailId: String
    var country: String?
    var phone: String
    var password2: String
    var usertype: String
    var bookingOn: String
    var car_number:String
    var profile_image: String
    var docUploaded: String
    var pa_firstName: String
    var pa_lastName: String
    var pa_address: String
    var pa_country: String
    var pa_state: String
    var pa_city: String
    var pa_zipcode: String
    var payout_type: String
}

struct UserLoginResponse : Codable {
    var status: Int
    var price: String?
    var msg: String
    var userType: String?
    var deviceToken_avaibility:String?
    var user : UserInfo?
    
    func isSuccess() -> Bool {
        return status == 1
    }
}
