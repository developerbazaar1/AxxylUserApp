//
//  BankAccount.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 22/01/23.
//

import Foundation

struct BankAccount: Decodable, Equatable {
    var name: String
    var bankname: String
    var routing_number: String
    var account_number: String
    var email: String
    var active: String
    var firstName: String
    var lastName: String
    var address: String
    var country: String
    var state: String
    var city: String
    var zipcode: String
    var payout_type: String
    
    init(bankname: String, name: String, account_number: String, routing_number: String, email: String, active: String, firstName: String, lastName: String, address: String, country: String, state: String, city: String, zipcode: String, payout_type: String) {
        self.bankname = bankname
        self.name = name
        self.account_number = account_number
        self.routing_number = routing_number
        self.email = email
        self.active = active
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.country = country
        self.state  = state
        self.city = city
        self.zipcode = zipcode
        self.payout_type = payout_type
    }
}

struct PayoutDetailsPaylaod: Encodable {
    var action = Actions.getDriverPayoutDetails.rawValue
    var userId:String
}

struct MailingPayoutDetails: Decodable {
    var firstName: String
    var lastName: String
    var address: String
    var country: String
    var state: String
    var city: String
    var zipcode: String
}

struct PayoutDetailsResponse: Decodable {
    var status : String
    var PayoutDetails : [BankAccount]?
    var msg : String?
    
    func isSuccess() -> Bool {
        return status == "1"
    }
}

struct EditDriverPayoutDetails: Encodable {
    var action = Actions.editDriverPayoutDetails.rawValue
    var userId:String
    var name: String
    var bankname: String
    var routing_number: String
    var account_number: String
    var email: String
    var firstName: String
    var lastName: String
    var address: String
    var country: String
    var state: String
    var city: String
    var zipcode: String
    var payout_type: String
}

struct EditDriverPayoutDetailseResponse: Decodable {
    var status : Int
    var msg : String?
    
    func isSuccess() -> Bool {
        return status == 1
    }
}
