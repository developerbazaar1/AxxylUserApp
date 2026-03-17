//
//  BookingService.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 02/10/22.
//

import Foundation
import CoreLocation

class BookingService : NSObject {
    
    static let instance = BookingService()
    
    var currentRideEstimateResponse: RideEstimateResponse?
    var currentVehicleType : CarCategory?
    var currentPaymentMethod : UserCard?
    var routeLocations: [MapLocation]?
    var rideIdInProgress : String?
    var tipAmount : String = ""
    
    private override init() {
        super.init()
    }
    
    func getOriginAddress() -> String {
        guard let routes = self.routeLocations, routes.count > 1 else {
            return "Origin address not set"
        }
        
        return routes.first!.address ?? ""
    }
    
    func getDestinationAddress() -> String {
        guard let routes = self.routeLocations, routes.count > 1 else {
            return "Destination address not set"
        }
        return routes.last!.address ?? ""
    }
    
    func getDestinationCoordinates() -> CLLocationCoordinate2D {
        guard let routes = self.routeLocations, routes.count > 1 else {
            print("[WARN] Destination lat longs are not found... this should not happend")
            return CLLocationCoordinate2DMake(0.0, 0.0)
        }
        self.routeLocations
        return CLLocationCoordinate2DMake(routes.last!.latitude ?? 0.0, routes.last!.longitude ?? 0.0)
    }
    
    func getBookingHistory(successCallBack: @escaping (BookingHistoryResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let bookingHistoryPayload = BookingHistoryPayload(action: Actions.userHistory.rawValue, userId: currentUser.id, usertype: currentUser.usertype)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(bookingHistoryPayload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(BookingHistoryResponse.self,
                                                                 from: responseData)
                    print(decodedResponse)
                    successCallBack(decodedResponse)
                } catch let error {
                    print(error)
                    errorCallBack("Failed to parse the response")
                }
                
            } error: { errorMsg, isNetworkError in
                errorCallBack(errorMsg)
            }
        } catch {
            errorCallBack("Failed to encode data")
        }
    }
    
    func getCarType(successCallBack: @escaping (CarTypeResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let carTypePayload = CarTypePayload(handicapped: currentUser.handicapped)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(carTypePayload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(CarTypeResponse.self,
                                                                 from: responseData)
                    print(decodedResponse)
                    successCallBack(decodedResponse)
                } catch let error {
                    print(error)
                    errorCallBack("Failed to parse the response")
                }
                
            } error: { errorMsg, isNetworkError in
                errorCallBack(errorMsg)
            }
        } catch {
            errorCallBack("Failed to encode data")
        }
    }
    
    func getEstimatedPriceDetails(successCallBack: @escaping (RideEstimateResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let routes = self.routeLocations, routes.count > 1 else {
            errorCallBack("Pick-up and drop-off location not set")
            return
        }
        
        let pickup = "\(routes.first!.latitude ?? 0.0),\(routes.first!.longitude ?? 0.0)"
        let dropoff = "\(routes.last!.latitude ?? 0.0),\(routes.last!.longitude ?? 0.0)"
        
        let estimatePayload = RideEstimatedPricePayload(carId: "", pickuplatLong: pickup, droplatLong_1: "", droplatLong_2: "", droplatLong: dropoff, origin: getOriginAddress(), destination: getDestinationAddress())
        print("get Estimated Price Payload - \(estimatePayload)")
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(estimatePayload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(RideEstimateResponse.self,
                                                                 from: responseData)
                    print(decodedResponse)
                    successCallBack(decodedResponse)
                } catch let error {
                    print(error)
                    errorCallBack("Failed to parse the response")
                }
                
            } error: { errorMsg, isNetworkError in
                errorCallBack(errorMsg)
            }
        } catch {
            errorCallBack("Failed to encode data")
        }
    }
    
    

    func requestAPickup(successCallBack: @escaping (PickupResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        guard let carType = self.currentVehicleType else {
            errorCallBack("Car Type not selected")
            return
        }
        
        guard let routes = self.routeLocations, routes.count > 1 else {
            errorCallBack("Pick-up and drop-off location not set")
            return
        }
        
        let pickup = "\(routes.first!.latitude ?? 0.0),\(routes.first!.longitude ?? 0.0)"
        let dropoff = "\(routes.last!.latitude ?? 0.0),\(routes.last!.longitude ?? 0.0)"
        
        let payload = PickupRequestPayload(userId: currentUser.id, lat: routes.first!.latitude ?? 0.0, long: routes.first!.longitude ?? 0.0, carTypeId: carType.ID, pickuplatLong: pickup, droplatLong: dropoff, pickupLocation: getOriginAddress(), sourcestate: "", dropLocation: getDestinationAddress())
        
        // DEBUG: Print the full pickup request payload
        print("[DEBUG][requestAPickup] Sending pickup request...")
        print("[DEBUG][requestAPickup] userId: \(currentUser.id)")
        print("[DEBUG][requestAPickup] carTypeId: \(carType.ID)")
        print("[DEBUG][requestAPickup] pickup lat/long: \(pickup)")
        print("[DEBUG][requestAPickup] dropoff lat/long: \(dropoff)")
        print("[DEBUG][requestAPickup] pickupLocation: \(getOriginAddress())")
        print("[DEBUG][requestAPickup] dropLocation: \(getDestinationAddress())")
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(payload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                // DEBUG: Log raw server response
                if let rawResponse = String(data: responseData, encoding: .utf8) {
                    print("[DEBUG][requestAPickup] Raw server response: \(rawResponse)")
                }
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(PickupResponse.self,
                                                                 from: responseData)
                    print("[DEBUG][requestAPickup] Decoded response - status: \(decodedResponse.status), rideId: \(String(describing: decodedResponse.rideId)), msg: \(String(describing: decodedResponse.msg))")
                    successCallBack(decodedResponse)
                } catch let error {
                    print("[DEBUG][requestAPickup] JSON decode FAILED: \(error)")
                    errorCallBack("Failed to parse the response")
                }
                
            } error: { errorMsg, isNetworkError in
                print("[DEBUG][requestAPickup] Network error: \(errorMsg), isNetworkError: \(isNetworkError)")
                errorCallBack(errorMsg)
            }
        } catch {
            print("[DEBUG][requestAPickup] Encoding FAILED: \(error)")
            errorCallBack("Failed to encode data")
        }
    }
    
    func cancelRideInProgress(successCallBack: @escaping (GeneralResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        guard let reqId = self.rideIdInProgress else {
            errorCallBack("ReqId Not found")
            return
        }
        
        let payload = CancelRideRequestPayload(userId: currentUser.id, reqId: reqId)
        
        print(payload)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(payload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(GeneralResponse.self,
                                                                 from: responseData)
                    print(decodedResponse)
                    successCallBack(decodedResponse)
                } catch let error {
                    print(error)
                    errorCallBack("Failed to parse the response")
                }
                
            } error: { errorMsg, isNetworkError in
                errorCallBack(errorMsg)
            }
        } catch {
            errorCallBack("Failed to encode data")
        }
    }
    
    func getRideStatus(user_type:String, rideId:String, successCallBack: @escaping (RideStatusResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let getRideStatus = RideStatusPayload(userId: currentUser.id, user_type: user_type, rideId: rideId)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(getRideStatus)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(RideStatusResponse.self,
                                                                 from: responseData)
                    print(decodedResponse)
                    successCallBack(decodedResponse)
                } catch let error {
                    print(error)
                    errorCallBack("Failed to parse the response")
                }
                
            } error: { errorMsg, isNetworkError in
                errorCallBack(errorMsg)
            }
        } catch {
            errorCallBack("Failed to encode data")
        }
    }
    
    func getdriversNearby(location: CLLocation, successCallBack: @escaping (DriversNearByResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let getRideStatus = DriversNearByPayload(userId: currentUser.id, lat: location.coordinate.latitude, long: location.coordinate.longitude)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(getRideStatus)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(DriversNearByResponse.self,
                                                                 from: responseData)
                    print(decodedResponse)
                    successCallBack(decodedResponse)
                } catch let error {
                    print(error)
                    errorCallBack("Failed to parse the response")
                }
                
            } error: { errorMsg, isNetworkError in
                errorCallBack(errorMsg)
            }
        } catch {
            errorCallBack("Failed to encode data")
        }
    }
    
    func getDriversLocation(driverId:String, successCallBack: @escaping (DriverLocationResponse) -> (), errorCallBack: @escaping (String) -> ()) {
            
            let driverLoc = DriversCurrentLocationPayload(userId: driverId)
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(driverLoc)
                let networkManager = NetworkManager()
                networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                    do {
                        let jsonDecoder = JSONDecoder()
                        let decodedResponse = try jsonDecoder.decode(DriverLocationResponse.self,
                                                                     from: responseData)
                        print(decodedResponse)
                        successCallBack(decodedResponse)
                    } catch let error {
                        print(error)
                        errorCallBack("Failed to parse the response")
                    }
                    
                } error: { errorMsg, isNetworkError in
                    errorCallBack(errorMsg)
                }
            } catch {
                errorCallBack("Failed to encode data")
            }
        }
    
    func createStripePaymentIntent(amount: String, successCallBack: @escaping (StripePaymentIntentResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        // WARNING: Storing Secret Key in the app is highly insecure and NOT recommended for production.
        // This is done strictly per user request to avoid backend dependency.
        let stripeSecretKey = "sk_test_51T7RrFPeNGecK3XbErtounVt86dGnAg10JLQ3RtT6V3K73kwgmxkLaa7wx7XFiF5a9UzzggY3q6TnE25ptSfcDFF00EzXUK5y8"
        
        guard let url = URL(string: "https://api.stripe.com/v1/payment_intents") else {
            errorCallBack("Invalid Stripe URL")
            return
        }
        
        var amountValue = amount
        if amountValue.hasPrefix("$") {
            amountValue = String(amountValue.dropFirst())
        }
        
        // Stripe expects amounts in cents for USD
        guard let amountDouble = Double(amountValue) else {
            errorCallBack("Invalid amount format")
            return
        }
        let amountInCents = Int(amountDouble * 100)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(stripeSecretKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParams = [
            "amount": "\(amountInCents)",
            "currency": "usd",
            "payment_method_types[]": "card",
            "metadata[tripId]": self.rideIdInProgress ?? "unknown"
        ]
        
        let bodyString = bodyParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                errorCallBack(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                errorCallBack("No data received from Stripe")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let clientSecret = json["client_secret"] as? String {
                        let stripeResponse = StripePaymentIntentResponse(status: "success", clientSecret: clientSecret, msg: nil)
                        successCallBack(stripeResponse)
                    } else if let errorObj = json["error"] as? [String: Any], let msg = errorObj["message"] as? String {
                        errorCallBack(msg)
                    } else {
                        errorCallBack("Failed to get client secret from Stripe")
                    }
                }
            } catch {
                errorCallBack("Failed to parse Stripe response")
            }
        }
        task.resume()
    }
    
    func confirmStripePayment(successCallBack: @escaping (GeneralResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        guard let tripId = self.rideIdInProgress else {
            errorCallBack("Trip ID not found")
            return
        }
        
        let payload = StripeConfirmPaymentPayload(tripId: tripId)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(payload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let response = try jsonDecoder.decode(GeneralResponse.self, from: responseData)
                    successCallBack(response)
                } catch let error {
                    print(error)
                    errorCallBack("Failed to parse the response")
                }
            } error: { errorMsg, isNetworkError in
                errorCallBack(errorMsg)
            }
        } catch {
            errorCallBack("Failed to encode data")
        }
    }
}
