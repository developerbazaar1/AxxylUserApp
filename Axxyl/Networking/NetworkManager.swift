//
//  NetworkManager.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 20/09/22.
//

import Foundation

enum HeaderField : String {
    case HeaderFieldXSceneMerchant = "X-Scene-Merchant"
    case HeaderFieldXSceneOrganization = "X-Scene-Organization"
}

public enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
    case patch   = "PATCH"
}

let BASE_URL = "https://axxyl.com/webservices_android"

class RequestContext {
    
    var device = "ios"
    var updatemobile = "version: 1"
    var deviceToken = ""
    
    convenience init(device: String, updatemobile: String, deviceToken:String) {
        self.init()
        
        self.device = device
        self.updatemobile = updatemobile
        self.deviceToken = deviceToken
    
    }
}

class NetworkManager : NSObject {
 
    class func patchRequest(_ request: UnsafePointer<NSMutableURLRequest>, extraHeaders : AnyObject?) {
        
        request.pointee.addValue("iOS", forHTTPHeaderField: "device")
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            request.pointee.addValue(appVersion, forHTTPHeaderField: "updatemobile")
        }
        
        request.pointee.addValue("1271", forHTTPHeaderField: "userId")
        
//        request.pointee.addValue(UserManager.instance.currentUserId, forHTTPHeaderField: "userId")
        
        if let headers = extraHeaders as? NSDictionary {
            for key in headers.allKeys {
                if let value = headers.value(forKey: key as! String) as? String {
                    request.pointee.addValue("\(value)", forHTTPHeaderField: key as! String)
                    print("Setting extra header: \(key) :: \(value)");
                }
            }
        }
    }
    
    func post(_ url: String, data: AnyObject, headers : AnyObject? = nil, success: @escaping (Data) -> (),
              error: @escaping (String, _ isNetworkError: Bool) -> ()) {
        
        let vURL = url
        
        var request = URLRequest(url: URL(string: vURL)!)
        //            var err: NSError?
        
        request.httpMethod = HTTPMethod.post.rawValue
        
        if data is Data {
            request.httpBody = data as? Data
        }else{
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
//                print("Payload for \(url) ----> \(request.httpBody, default: "Not found")")
            }catch {
                print("Error while setting request body")
            }
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
    
        
        let sessionConfig: URLSessionConfiguration = getConfiguredVeeaSession()
        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        session.dataTask(with: request as URLRequest, completionHandler: {data, response, networkErr -> Void in
            
            let networkError = networkErr as NSError?
            
            if (data == nil) {
                
                print("Server call to \"" + url + "\" failed. Nil Data Received.")
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    if networkError != nil {
                        if let errorDescription = networkError!.userInfo["NSLocalizedDescription"] as? String {
                            error(errorDescription, networkError!.isErrorNetworkRelated())
                        }else{
                            error("Unknown Error", networkError!.isErrorNetworkRelated())
                        }
                    }else{
                        //data is nil but no network error is returned
                        error("Unknown Error", false)
                    }
                    
                    
                })
                return
                
            }
            
            let dataAsString : NSString? = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            if dataAsString != nil {
                print(dataAsString!)
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                print("My url \(url) and data as String: ->\(dataAsString!)-<")
                success(data!)
            })
            
        }).resume()
        
    }
}



func getConfiguredVeeaSession() -> URLSessionConfiguration {
    let sessionConfig: URLSessionConfiguration = URLSessionConfiguration.default
    
    sessionConfig.timeoutIntervalForRequest = 60
    sessionConfig.timeoutIntervalForResource = 60
    
    if #available(iOS 11, *) {
        sessionConfig.waitsForConnectivity = true
    }
    
    return sessionConfig
}
