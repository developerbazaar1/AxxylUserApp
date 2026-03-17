//
//  ForgotPasswordResponse.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 29/09/22.
//

import Foundation

struct ForgotPasswordResponse : Decodable {
    var status : Int
    var msg: String
    
    func isSuccess() -> Bool {
        return status == 1
    }
}
