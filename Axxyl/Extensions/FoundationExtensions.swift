//
//  FoundationExtensions.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 21/09/22.
//

import Foundation
import MapKit


extension Error {
    func isErrorNetworkRelated() -> Bool {
       return (self as NSError).isErrorNetworkRelated()
    }
}

extension NSError {
    
    @objc class func isErrorNetworkRelated(code : Int) -> Bool {
        
        let error = NSError(domain: "", code: code, userInfo: nil)
        
        return error.isErrorNetworkRelated()
    }
    
    //determine if error is releated to network error
    @objc func isErrorNetworkRelated() -> Bool {
        
        //see here for a list of possible network errors: http://nshipster.com/nserror/
        let errorCode = self.code
        
        //domain and dns erros
        if (errorCode == -1 || errorCode == 1 || errorCode == 2 || errorCode == 100 || errorCode == 101) {
            return true
        }
        
        //sock errors
        if ((errorCode >= 110 && errorCode <= 113) || (errorCode >= 120 && errorCode <= 124)){
            return true
        }
        
        //HTTP errors
        if (errorCode >= 300 && errorCode <= 311){
            return true
        }
        
        //URL connection errors
        if (errorCode >= -1021 && errorCode <= -998){
            return true
        }
        
        //Server errors
        if (errorCode >= 500 && errorCode <= 505) {
            return true
        }
        
        return false
    }
}

extension String {
    func validateEmail() -> Bool {
        let emailRegEx = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func getMaskedCardNum(longLength: Bool) -> String {
        let subStr = self.suffix(4)
        if longLength {
            return "**** **** **** " + String(subStr)
        } else {
            return "**** " + String(subStr)
        }
    }
}

extension UserDefaults {
    func storeInToHistory(mapLocation: MapLocation) {
        if let encodedDataArray = UserDefaults.standard.value(forKey: "SEARCH_HISTORY") {
            do {
                let storedItems = try JSONDecoder().decode([MapLocation].self, from: encodedDataArray as! Data)
                var searchArray = storedItems
                if searchArray.count < 25 {
                    searchArray.append(mapLocation)
                } else if !storedItems.contains(where: { obj in
                    obj.name == mapLocation.name
                }){
                    searchArray.remove(at: 0)
                    searchArray.append(mapLocation)
                }
                
                if let encoded = try? JSONEncoder().encode(searchArray) {
                    UserDefaults.standard.set(encoded, forKey: "SEARCH_HISTORY")
                }
            } catch let error {
                print("Decoding Error: \(error)")
            }
        } else {
            let array = [mapLocation]
            if let encoded = try? JSONEncoder().encode(array) {
                UserDefaults.standard.set(encoded, forKey: "SEARCH_HISTORY")
            }
        }
    }
}

extension Data {
   mutating func append(_ string: String) {
      if let data = string.data(using: .utf8) {
         append(data)
      }
   }
}


extension Date {

    static func getCurrentDate() -> String {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "MMM dd, HH:mm a"

        return dateFormatter.string(from: Date())

    }
}

extension MKMapItem {
  convenience init(coordinate: CLLocationCoordinate2D, name: String) {
    self.init(placemark: .init(coordinate: coordinate))
    self.name = name
  }
}

extension Double {
  func convert(from originalUnit: UnitLength, to convertedUnit: UnitLength) -> String {
      let meaFormatter = MeasurementFormatter()
      meaFormatter.numberFormatter.maximumFractionDigits = 2
      let v = Measurement(value: self, unit: originalUnit)
      let miles = v.converted(to: convertedUnit)
      return meaFormatter.string(from: miles)
  }
}
