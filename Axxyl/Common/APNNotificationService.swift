//
//  APNNotificationService.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 29/11/22.
//

import Foundation

enum PushNotificationTypes : String {
    case arrivalNotify = "arrivalNotify"
    case accept = "accept"
    case arrived = "arrived"
    case tripStarted = "start"
    case ariveEnd = "ariveEnd"
    case cancle = "cancle"
    
    // Driver Notifications, should we create different enum???
    case sentReq = "sentReq"
}

class CommonNotificationData {
    var msgType : String = ""
    var reqId : String = ""
    var message : String = ""
    var notificationType : String = ""
    var cachedDict : [AnyHashable: Any]?
    init(dict : [AnyHashable : Any]) {
        self.cachedDict = dict
        self.msgType = (dict["msgType"] as? String) ?? ""
        self.reqId = (dict["reqId"] as? String) ?? ""
        self.message = (dict["message"] as? String) ?? ""
        self.notificationType = (dict["notificationType"] as? String) ?? ""
    }
}

class NotificationData : CommonNotificationData {
    var vendorPhone : String = ""
    var type : String = ""
    var vendorEmail : String = ""
    var vendorImage : String = ""
    var pickuplatLong : String = ""
    var car_number : String = ""
    var vendorName : String = ""
    var droplatLong : String = ""
    var vendorClong : String = ""
    var carModel : String = ""
    var vendorClat : String = ""
    var carColor : String = ""
    var vendorId : String = ""
    
    override init(dict: [AnyHashable : Any]) {
        super.init(dict: dict)
        self.vendorPhone = (dict["vendorPhone"] as? String) ?? ""
        self.type = (dict["type"] as? String) ?? ""
        self.vendorEmail = (dict["vendorEmail"] as? String) ?? ""
        self.vendorImage = (dict["vendorImage"] as? String) ?? ""
        self.pickuplatLong = (dict["pickuplatLong"] as? String) ?? ""
        self.car_number = (dict["car_number"] as? String) ?? ""
        self.vendorName = (dict["vendorName"] as? String) ?? ""
        self.droplatLong = (dict["droplatLong"] as? String) ?? ""
        self.vendorClong = (dict["vendorClong"] as? String) ?? ""
        self.carModel = (dict["carModel"] as? String) ?? ""
        self.vendorClat = (dict["vendorClat"] as? String) ?? ""
        self.carColor = (dict["carColor"] as? String) ?? ""
        self.vendorId = (dict["vendorId"] as? String) ?? ""
    }
}

class ArrivedEndNotificationData : CommonNotificationData {
    var avgSpeed : String = ""
    var dropLocation : String = ""
    var dropTime: String = ""
    var geoDropCharge: String = ""
    var geoPickupCharge: String = ""
    var pickupTime: String = ""
    var totalDistance: String = ""
    var totalPrice: String = ""
    var totalTime: String = ""
    var vendorId : String = ""
    var waitingCost: String = ""
    override init(dict: [AnyHashable : Any]) {
        super.init(dict: dict)
        self.avgSpeed = (dict["avgSpeed"] as? String) ?? ""
        self.dropLocation = (dict["dropLocation"] as? String) ?? ""
        self.dropTime = (dict["dropTime"] as? String) ?? ""
        self.geoDropCharge = (dict["geoDropCharge"] as? String) ?? ""
        self.geoPickupCharge = (dict["geoPickupCharge"] as? String) ?? ""
        self.pickupTime = (dict["pickupTime"] as? String) ?? ""
        self.totalDistance = (dict["totalDistance"] as? String) ?? ""
        self.totalPrice = (dict["totalPrice"] as? String) ?? ""
        self.totalTime = (dict["totalTime"] as? String) ?? ""
        self.vendorId = (dict["vendorId"] as? String) ?? ""
        self.waitingCost = (dict["waitingCost"] as? String) ?? ""
    }
}

class CancelEndNotificationData : CommonNotificationData {
    var cancellation_price : String = ""
    var droplatLong : String = ""
    var pickuplatLong: String = ""
    var userClat: String = ""
    var userId: String = ""
    var userName: String = ""
    var userPhone: String = ""
    var vendorClong: String = ""
    
    override init(dict: [AnyHashable : Any]) {
        super.init(dict: dict)
        self.cancellation_price = (dict["cancellation_price"] as? String) ?? ""
        self.droplatLong = (dict["droplatLong"] as? String) ?? ""
        self.pickuplatLong = (dict["pickuplatLong"] as? String) ?? ""
        self.userClat = (dict["userClat"] as? String) ?? ""
        self.userId = (dict["userId"] as? String) ?? ""
        self.userName = (dict["userName"] as? String) ?? ""
        self.userPhone = (dict["userPhone"] as? String) ?? ""
        self.vendorClong = (dict["vendorClong"] as? String) ?? ""
    }
}

class DriverReceivedRideRequestNotificationData : CommonNotificationData {
    var droplatLong : String = ""
    var dropLocation : String = ""
    var pickuplatLong: String = ""
    var pickupLocation: String = ""
    var signature: String = ""
    var userEmail: String = ""
    var userId: String = ""
    var userLat: String = ""
    var userLong: String = ""
    var UserImage: String = ""
    var UserName: String = ""
    var UserPhone: String = ""
    var userPrice: String = ""
    var userScreenshot: String = ""
    
    override init(dict: [AnyHashable : Any]) {
        super.init(dict: dict)
        self.droplatLong = (dict["droplatLong"] as? String) ?? ""
        self.dropLocation = (dict["dropLocation"] as? String) ?? ""
        self.pickuplatLong = (dict["pickuplatLong"] as? String) ?? ""
        self.pickupLocation = (dict["pickupLocation"] as? String) ?? ""
        self.signature = (dict["signature"] as? String) ?? ""
        self.userEmail = (dict["userEmail"] as? String) ?? ""
        self.userId = (dict["userId"] as? String) ?? ""
        self.userLat = (dict["userLat"] as? String) ?? ""
        self.userLong = (dict["userLong"] as? String) ?? ""
        self.UserImage = (dict["UserImage"] as? String) ?? ""
        self.UserName = (dict["UserName"] as? String) ?? ""
        self.UserPhone = (dict["UserPhone"] as? String) ?? ""
        self.userPrice = (dict["userPrice"] as? String) ?? ""
        self.userScreenshot = (dict["userScreenshot"] as? String) ?? ""
    }
}

let key_rider_notifications = "rider_notifications"
let key_driver_notifications = "driver_notifications"

class APNNotificationService : NSObject {
    static let instance = APNNotificationService()
    
    private override init() {
        super.init()
    }
    
    var pushNotificationQueue = PushNotificationQueue<CommonNotificationData>()
    
    func storeNotificationDataInDefaults(dict: [AnyHashable : Any], msgType: String) {
        if var riderNotifications = UserDefaults.standard.object(forKey: key_rider_notifications) as? [String] {
            riderNotifications.append(msgType)
            print("rider_notifications : \(riderNotifications)")
            UserDefaults.standard.setValue(riderNotifications, forKey: key_rider_notifications)
        }else{
            UserDefaults.standard.setValue([msgType], forKey: key_rider_notifications)
        }
        UserDefaults.standard.set(dict, forKey: msgType)
    }
    
    func storeDriverNotificationDataInDefaults(dict: [AnyHashable : Any], msgType: String) {
        if var driverNotifications = UserDefaults.standard.object(forKey: key_driver_notifications) as? [String] {
            driverNotifications.append(msgType)
            print("driver_notifications : \(driverNotifications)")
            UserDefaults.standard.setValue(driverNotifications, forKey: key_driver_notifications)
        }else{
            UserDefaults.standard.setValue([msgType], forKey: key_driver_notifications)
        }
        
        UserDefaults.standard.set(dict, forKey: msgType)
    }
    
    func clearCachedNotifications() {
        if let riderNotifications = UserDefaults.standard.object(forKey: key_rider_notifications) as? [String] {
            for riderNotification in riderNotifications {
                UserDefaults.standard.removeObject(forKey: riderNotification)
            }
            UserDefaults.standard.removeObject(forKey: key_rider_notifications)
        }
        
        if let driverNotifications = UserDefaults.standard.object(forKey: key_driver_notifications) as? [String] {
            for driverNoti in driverNotifications {
                UserDefaults.standard.removeObject(forKey: driverNoti)
            }
            UserDefaults.standard.removeObject(forKey: key_driver_notifications)
        }
    }
    
    func getNotificationData(notificationType : PushNotificationTypes) -> CommonNotificationData? {
        if let dict = UserDefaults.standard.object(forKey: notificationType.rawValue) as? [AnyHashable : Any] {
            if notificationType == .cancle {
                return CancelEndNotificationData(dict: dict)
            }
            if notificationType == .ariveEnd {
                return ArrivedEndNotificationData(dict: dict)
            }
            return NotificationData(dict: dict)
        }
        return nil
    }
    
    func parseRemoteNotification(userInfo : [AnyHashable : Any]) {
        print("[DEBUG][APNService] parseRemoteNotification called")
        print("[DEBUG][APNService] Raw userInfo: \(userInfo)")
        
        guard let notificationType = userInfo["notificationType" as String] as? String else {
            print("[DEBUG][APNService] ❌ Missing 'notificationType' key in notification payload")
            return
        }
        print("[DEBUG][APNService] notificationType: '\(notificationType)'")
        
        guard let msgType = userInfo["msgType" as String] as? String else {
            print("[DEBUG][APNService] ❌ Missing 'msgType' key in notification payload")
            return
        }
        print("[DEBUG][APNService] msgType: '\(msgType)'")
        
        var notData : CommonNotificationData?
        
        if notificationType == "U" { // passenger notifications
            print("[DEBUG][APNService] Routing as USER (passenger) notification")
            
            if msgType == PushNotificationTypes.cancle.rawValue {
                notData = CancelEndNotificationData(dict: userInfo)
                self.clearCachedNotifications()
            } else if msgType == PushNotificationTypes.ariveEnd.rawValue {
                notData = ArrivedEndNotificationData(dict: userInfo)
            } else if msgType == "arrivalNotify" {
                print("[DEBUG][APNService] Handling 'arrivalNotify' as ride accepted.")
                // It has the same payload structure as an accept notification
                notData = NotificationData(dict: userInfo)
            } else {
                notData = NotificationData(dict: userInfo)
            }
            
            if notData != nil {
                self.storeNotificationDataInDefaults(dict: userInfo, msgType: msgType)
                print("[DEBUG][APNService] Posting NotificationCenter event for name: '\(notData!.msgType)'")
                
                DispatchQueue.main.async {
                    // If it's arrivalNotify, we also need to post an "accept" notification so the UI moves forward
                    NotificationCenter.default.post(name: NSNotification.Name(notData!.msgType), object: notData!)
                    
                    if msgType == "arrivalNotify" {
                        print("[DEBUG][APNService] Also posting 'accept' for 'arrivalNotify' payload")
                        NotificationCenter.default.post(name: NSNotification.Name(PushNotificationTypes.accept.rawValue), object: notData!)
                    }
                }
            }
        } else if (notificationType == "E" || notificationType == "V") { // driver notifications
            print("[DEBUG][APNService] Routing as DRIVER notification")
            
            if msgType == PushNotificationTypes.sentReq.rawValue {
                notData = DriverReceivedRideRequestNotificationData(dict: userInfo)
            } else if msgType == PushNotificationTypes.cancle.rawValue {
                notData = CancelEndNotificationData(dict: userInfo)
                self.clearCachedNotifications()
            }
            if notData != nil {
                self.storeDriverNotificationDataInDefaults(dict: userInfo, msgType: msgType)
                print("[DEBUG][APNService] Posting NotificationCenter event for name: '\(notData!.msgType)'")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(notData!.msgType), object: notData!)
                }
            }
        } else {
            print("[DEBUG][APNService] ⚠️ Unknown notificationType: '\(notificationType)' - not 'U', 'E', or 'V'")
        }
    }
}
