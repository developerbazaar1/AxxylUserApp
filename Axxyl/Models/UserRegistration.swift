//
//  UserRegistration.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 27/09/22.
//

import Foundation


class UserRegistrationPayload : BasePayload {
    var firstName:String = ""
    var lastName : String = ""
    var emailId:String = ""
    var password:String = ""
    var phoneNumber : String = ""
    var usertype : UserType!
    var cardname : String = ""
    var cardnum : String = ""
    var cardcvv : String = ""
    var cardexpmonth : Int = 0
    var cardexpyear : Int = 0
    var car_number : String = ""
    var carColor : String = ""
    var carModel : String = ""
    var handicapped : Bool = false
    var carTypeId = "22" // TODO : don't know from we are going to take car type
    
    
    init() {
        super.init(action: Actions.registration)
    }
    
    init(firstName: String, lastName: String, emailId: String, password: String, phoneNumber: String, usertype: UserType!, cardname: String, cardnum: String, cardcvv: String, cardexpmonth: Int, cardexpyear: Int, car_number: String, carColor: String, carModel: String, handicapped: Bool, carTypeId: String = "22") {
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
    }
    
//    init(firstName: String, lastName: String, emailId: String, password: String, phoneNumber: String, isWheelChair: Bool) {
//        super.init(action: Actions.registration)
//        self.firstName = firstName
//        self.lastName = lastName
//        self.emailId = emailId
//        self.password = password
//        self.phoneNumber = phoneNumber
//        self.isWheelChair = isWheelChair
//    }
}
