//
//  BasePayload.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 27/09/22.
//

import Foundation

class BasePayload {
    var action : Actions!
    let device : String = "iOS"
    var deviceToken: String {
        return UserDefaults.standard.string(forKey: AppUserDefaultsKeys.deviceToken) ?? ""
    }
    
    var updatemobile: String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "version :" + appVersion
        }
        return "version: 1"
    }
    
    init(action: Actions!) {
        self.action = action
    }
}
