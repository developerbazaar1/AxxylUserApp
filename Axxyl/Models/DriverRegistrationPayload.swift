//
//  DriverRegistrationPayload.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 21/01/23.
//

import Foundation

class DriverRegistrationPayload: UserRegistrationPayload {
    var bankname = ""
    var account_name = ""
    var account_number = ""
    var routing_number = ""
    var account_emailId = ""
    var carType = ""
    var firstName_mail = ""
    var lastName_mail = ""
    var address_mail = ""
    var country_mail = ""
    var state_mail = ""
    var city_mail = ""
    var zipcode_mail = ""
    var payout_type = ""
    
    
    override init() {
        super.init()
    }
    
    init(firstName: String, lastName: String, emailId: String, password: String, phoneNumber: String, usertype: UserType!, cardname: String, cardnum: String, cardcvv: String, cardexpmonth: String, cardexpyear: String, car_number: String, carColor: String, carModel: String, handicapped: Bool, carTypeId: String = "22", bankname: String, account_name: String, account_number: String, routing_number: String, account_emailId: String, carType: String, pa_firstName: String, pa_lastName: String, pa_country: String, pa_state: String, pa_city: String, pa_address: String, pa_zipcode: String) {
        super.init()
        self.firstName = firstName
        self.lastName = lastName
        self.emailId = emailId
        self.password = password
        self.phoneNumber = phoneNumber
        self.usertype = usertype
        self.cardname = cardname
        self.cardnum = cardnum
        self.cardcvv = cardcvv
        self.cardexpmonth = cardexpmonth
        self.cardexpyear = cardexpyear
        self.car_number = car_number
        self.carColor = carColor
        self.carModel = carModel
        self.handicapped = handicapped
        self.carTypeId = carTypeId
        self.bankname = bankname
        self.account_name = account_name
        self.account_number = account_number
        self.routing_number = routing_number
        self.account_emailId = account_emailId
        self.carType = carType
        self.fName = pa_firstName
        self.lName = pa_lastName
        self.country = pa_country
        self.state = pa_state
        self.city = pa_city
        self.address = pa_address
        self.zipcode = pa_zipcode
    }
    
    
    
    override func getSerializableDict() -> GenericDictionary {
        var dt = GenericDictionary()
        dt.updateValue(self.action.rawValue as AnyObject, forKey: "action")
        dt.updateValue(self.emailId as AnyObject, forKey: "emailId")
        dt.updateValue(self.password as AnyObject, forKey: "password")
        dt.updateValue(self.firstName as AnyObject, forKey: "fname")
        dt.updateValue(self.lastName as AnyObject, forKey: "lname")
        dt.updateValue(self.phoneNumber as AnyObject, forKey: "phone")
        dt.updateValue(self.cardname as AnyObject, forKey: "cardname")
        dt.updateValue(self.cardnum as AnyObject, forKey: "cardnum")
        dt.updateValue(self.cardcvv as AnyObject, forKey: "cardcvv")
        dt.updateValue(self.cardexpmonth as AnyObject, forKey: "cardexpmonth")
        dt.updateValue(self.cardexpyear as AnyObject, forKey: "cardexpyear")
        dt.updateValue(self.car_number as AnyObject, forKey: "car_number")
        dt.updateValue(self.carColor as AnyObject, forKey: "carColor")
        dt.updateValue(self.carModel as AnyObject, forKey: "carModel")
        dt.updateValue(self.updatemobile as AnyObject, forKey: "updatemobile")
        dt.updateValue(self.device as AnyObject, forKey: "device")
        dt.updateValue(self.deviceToken as AnyObject, forKey: "deviceToken")
        dt.updateValue(self.usertype.rawValue as AnyObject, forKey: "usertype")
        dt.updateValue(( self.handicapped ? 1 : 0) as AnyObject, forKey: "handicapped")
        dt.updateValue(self.bankname as AnyObject, forKey: "bankname")
        dt.updateValue(self.account_name as AnyObject, forKey: "account_name")
        dt.updateValue(self.account_number as AnyObject, forKey: "account_number")
        dt.updateValue(self.routing_number as AnyObject, forKey: "routing_number")
        dt.updateValue(self.account_emailId as AnyObject, forKey: "account_emailId")
        dt.updateValue(self.carType as AnyObject, forKey: "carType")
        dt.updateValue(self.fName as AnyObject, forKey: "firstName")
        dt.updateValue(self.lName as AnyObject, forKey: "lastName")
        dt.updateValue(self.address as AnyObject, forKey: "address")
        dt.updateValue(self.country as AnyObject, forKey: "country")
        dt.updateValue(self.state as AnyObject, forKey: "state")
        dt.updateValue(self.city as AnyObject, forKey: "city")
        dt.updateValue(self.zipcode as AnyObject, forKey: "zipcode")
        dt.updateValue(self.fName as AnyObject, forKey: "firstName_mail")
        dt.updateValue(self.lName as AnyObject, forKey: "lastName_mail")
        dt.updateValue(self.address_mail as AnyObject, forKey: "address_mail")
        dt.updateValue(self.country_mail as AnyObject, forKey: "country_mail")
        dt.updateValue(self.state_mail as AnyObject, forKey: "state_mail")
        dt.updateValue(self.city_mail as AnyObject, forKey: "city_mail")
        dt.updateValue(self.zipcode_mail as AnyObject, forKey: "zipcode_mail")
        dt.updateValue(self.payout_type as AnyObject, forKey: "payout_type")
        return dt
    }
}
