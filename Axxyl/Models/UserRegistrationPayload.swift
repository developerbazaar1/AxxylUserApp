//
//  UserRegistrationPayload.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 28/09/22.
//

import Foundation

class UserRegistrationPayload : BasePayload {
    var firstName: String = ""
    var lastName : String = ""
    var emailId: String = ""
    var password: String = ""
    var countryCode: String = ""
    var phoneNumber : String = ""
    var usertype : UserType!
    var cardname : String = ""
    var cardnum : String = ""
    var cardcvv : String = ""
    var cardexpmonth : String = ""
    var cardexpyear : String = ""
    var car_number : String = ""
    var fName : String = ""
    var lName : String = ""
    var country : String = ""
    var state : String = ""
    var city : String = ""
    var address : String = ""
    var zipcode : String = ""
    var carColor : String = ""
    var carModel : String = ""
    var handicapped : Bool = false
    var carTypeId : String =  ""
    var profile_image: Media?
    var user_country : String = ""
    var user_state : String = ""
    var user_city : String = ""
    var user_address : String = ""
    var user_zipcode : String = ""
//    var bankname = ""
//    var account_name = ""
//    var account_number = ""
//    var routing_number = ""
//    var account_emailId = ""
    
    
    init() {
        super.init(action: Actions.registration)
    }
    
//    init(firstName: String, lastName: String, emailId: String, password: String, phoneNumber: String, usertype: UserType!, cardname: String, cardnum: String, cardcvv: String, cardexpmonth: String, cardexpyear: String, car_number: String, carColor: String, carModel: String, handicapped: Bool, carTypeId: String = "22", bankname: String, account_name: String, account_number: String, routing_number: String, account_emailId: String) {
    init(firstName: String, lastName: String, emailId: String, password: String, phoneNumber: String, usertype: UserType!, cardname: String, cardnum: String, cardcvv: String, cardexpmonth: String, cardexpyear: String, car_number: String, carColor: String, carModel: String, handicapped: Bool, carTypeId: String = "22", pa_firstName: String, pa_lastName: String, pa_country: String, pa_state: String, pa_city: String, pa_address: String, pa_zipcode: String,
         user_country: String, user_state: String, user_city: String, user_address: String, user_zipcode: String) {
        super.init(action: Actions.registration)
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
        self.fName = pa_firstName
        self.lName = pa_lastName
        self.country = pa_country
        self.state = pa_state
        self.city = pa_city
        self.address = pa_address
        self.zipcode = pa_zipcode
        self.user_country = user_country
        self.user_state = user_state
        self.user_city = user_city
        self.user_address = user_address
        self.user_zipcode = user_zipcode
    }
    
    
    
    func getSerializableDict() -> GenericDictionary {
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
        dt.updateValue(self.fName as AnyObject, forKey: "firstName")
        dt.updateValue(self.lName as AnyObject, forKey: "lastName")
        dt.updateValue(self.country as AnyObject, forKey: "country")
        dt.updateValue(self.state as AnyObject, forKey: "state")
        dt.updateValue(self.city as AnyObject, forKey: "city")
        dt.updateValue(self.address as AnyObject, forKey: "address")
        dt.updateValue(self.zipcode as AnyObject, forKey: "zipcode")
        dt.updateValue(self.user_country as AnyObject, forKey: "user_country")
        dt.updateValue(self.user_state as AnyObject, forKey: "user_state")
        dt.updateValue(self.user_city as AnyObject, forKey: "user_city")
        dt.updateValue(self.user_address as AnyObject, forKey: "user_address")
        dt.updateValue(self.user_zipcode as AnyObject, forKey: "user_zipcode")
        return dt
    }
}

struct UserLogoutPayload : Encodable {
    var action = Actions.logout.rawValue
    var userId:String
}

struct UserDeleteProfilePayload : Encodable {
    var action = Actions.deleteUserProfile.rawValue
    var userId:String
}

struct DriverDeleteProfilePayload : Encodable {
    var action = Actions.deleteDriverProfile.rawValue
    var userId:String
}


struct ValidateCreditCardPayload: Encodable {
    var action = Actions.validateCreditCard.rawValue
    var firstName: String
    var lastName: String
    var country: String
    var state: String
    var city: String
    var address: String
    var zipcode: String
    var card_number: String
    var card_code: String
    var expiration_date: String
}
