//
//  ForgotPasswordRequest.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 29/09/22.
//

import Foundation

struct ForgotPasswordRequest : Encodable {
    let action : String = Actions.forgetpassword.rawValue
    var emailId : String
}
