//
//  ChangePasswordPayload.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 02/10/22.
//

import Foundation


struct ChangePasswordPayload : Encodable {
    var action = Actions.changePassword.rawValue
    var oldPassword:String
    var newPassword:String
    var userId:String
}
