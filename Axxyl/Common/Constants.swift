//
//  Constants.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 24/09/22.
//

import Foundation

struct AppURLS {
    static let baseURL = "https://axxyl.com/webservices_android"
}

public enum Actions : String {
    case login = "login"
    case logout = "logout"
    case registration = "registration"
    case forgetpassword = "forgetpassword"
    case profile = "Profile"
    case editprofile = "editprofile"
    case changePassword = "changePassword"
    
    // Card Add backend side Apis
    case getdatacardedit = "getdatacardedit"
    case addMoreCards = "addMoreCards"
    case getdatacard = "getdatacard"
    case getdatacardDetails = "getdatacardDetails"
    case selectUserCard = "selectUserCard"
    
    
    case userHistory = "userHistory"
    case driverHistory = "driverHistory"
    case carType = "carType"
    case pickupRequest = "pickupRequest"
    case pickupRequestDetails = "pickupRequestDetails"
    case deleteUserCardDetails = "deleteUserCardDetails"
    case editUserCardDetails = "editUserCardDetails"
    case getEstimatedPriceDetails = "getstemaitPriceDetails"
    case canclerequest = "canclerequest"
    case getRideStatus = "getRideStatus"
    case editDriverCarDetails = "editDriverCarDetails"
    case addMoreDriverCars = "addMoreDriverCars"
    case selectDriverCar = "selectDriverCar"
    case deleteDriveCarDetails = "deleteDriveCarDetails"
    case getDriverCarsList = "getDriverCarsList"
    case editDriverPayoutDetails = "editDriverPayoutDetails"
    case getDriverPayoutDetails = "getPayoutDetails"
    case uploadDriverDocuments = "uploadDoc"
    case getUploadedDriverDocuments = "checkUploadDoc"
    case setting = "setting"
    case settingcheck = "settingcheck"
    case updateLatLong = "updateLatLong"
    case acceptServiceReq = "acceptServiceReq"
    case arraiveatUser = "arraiveatUser"
    case arrivalNotificationToCustomer = "arrivalNotificationToCustomer"
    case startReqestServices = "startReqestServices"
    case ariveAndEnd = "ariveAndEnd"
    case driversNearBy = "showDriversOnMap"
    case driverPaymentSummary = "driverPaymentSummary"
    case getlatlong = "getlatlong"
    case updatewatingstart = "updatewatingstart"
    case cancle = "cancle"
    case processPayment = "processPayment"
    case deleteUserProfile = "deleteUserProfile"
    case deleteDriverProfile = "deleteDriverProfile"
    case validateCreditCard = "validateCreditCard"
    case createPaymentIntent = "createPaymentIntent"
    case confirmPayment = "confirmPayment"
}


struct AppUserDefaultsKeys {
    static let usertype = "usertype"
    static let deviceToken = "deviceToken"
    static let currentUserData = "currentUserData"
}

enum VehicleScreenMode: String {
    case AddCar = "Add Car"
    case EditCar = "Edit Car"
    case RegisterCar = "Vehicle Details"
}

enum CreditCardPaymentScreenMode: String {
    case addCard = "Add Card"
    case editCard = "Edit Card"
    case registerDriverCard = "RegisterDriverCard"
    case registerPassangerCard = "RegisterPassangerCard"
    case addPaymentMethod = "AddPaymentMethod"
}

enum PayoutDetaisScreenMode: String {
    case editPayoutDetails = "Edit Payout Details"
    case registerDriverPayoutDetails = "Register Driver Payout Details"
}

enum MailingPayoutDetaisScreenMode: String {
    case editMailingPayoutDetails = "Edit Mailing Payout Details"
    case registerDriverMailingPayoutDetails = "Register Driver Mailing Payout Details"
}

enum DocumentsUploadScreenMode: String {
    case signupMode = "signupMode"
    case menuMode = "menuMode"
}

enum PaymentFeeScreenMode: String {
    case paymentSummary = "Payment summary"
    case monthlyFee = "Monthly fee"
}
