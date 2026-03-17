//
//  EditProfilePayload.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 01/10/22.
//

import Foundation


struct EditProfilePayload {
    var action = Actions.editprofile.rawValue
    var userId: String
    var fname: String
    var lname: String
    var phone: String
    var countryCode: String
    var handicapped: String
    var profile_image: Media?
    var pa_address: String
    var pa_country: String
    var pa_state: String
    var pa_city: String
    var pa_zipcode: String
}
