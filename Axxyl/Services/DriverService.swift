//
//  DriverService.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 22/01/23.
//

import Foundation
import CoreLocation


class DriverService : NSObject {
    
    static let instance = DriverService()

    var currentVehicleType : CarCategory?
    var currentPaymentMethod : UserCard?
    var routeLocations: [MapLocation]?
    var driverRideIdInProgress : String?
    var tipAmount : String = ""
    
    var isOnline : Bool = false
    
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
    
    func loginUser(email:String, password:String, success : @escaping (UserLoginResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        var payloadDict = GenericDictionary();
        payloadDict.updateValue(Actions.login.rawValue as AnyObject, forKey: "action");
        payloadDict.updateValue(email as AnyObject, forKey: "emailId")
        payloadDict.updateValue(password as AnyObject, forKey: "password")
        payloadDict.updateValue("ios" as AnyObject, forKey: "device")
        payloadDict.updateValue("version: 1" as AnyObject, forKey: "updatemobile")
        
        guard let devToken = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.deviceToken) else {
            errorCallBack("Notification not enabled, please allow notifications from Settings.")
            return
        }
        payloadDict.updateValue(devToken as AnyObject, forKey: "deviceToken")
        
        print("Login with User Info \(payloadDict)")
        
        let networkManager = NetworkManager()
        networkManager.post(AppURLS.baseURL, data: payloadDict as AnyObject) { responseData in
            do {
                let jsonDecoder = JSONDecoder()
                let decodedResponse = try jsonDecoder.decode(UserLoginResponse.self,
                                                             from: responseData)
                
                print(decodedResponse)
                success(decodedResponse)
            } catch let error {
                print(error)
                errorCallBack("Failed to parse the login response")
            }
            
        } error: { errorMsg, isNetworkError in
            errorCallBack(errorMsg)
        }
        
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
        
        let carTypePayload = CarTypePayload(handicapped: "0")
        
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
                    self.storeCarTyprData(carTypeArray: decodedResponse.carType)
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
  
    func declineRide(rideId:String, successCallBack: @escaping (GeneralResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        self.driverRideIdInProgress = rideId
        self.cancelRideInProgress(successCallBack: successCallBack, errorCallBack: errorCallBack)
    }
    
    func cancelRideInProgress(successCallBack: @escaping (GeneralResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }

        guard let reqstId = self.driverRideIdInProgress else {
            errorCallBack("ReqId Not found")
            return
        }

        let payload = CancelRideRequestPayload(userId: currentUser.id, reqId: reqstId)

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

    func addDriverCar(cardata:Car, successCallBack: @escaping (DriverCarsResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        let addCar = AddMoreDriverCarsPayload(userId: currentUser.id, carTypeId: getCarTypeIdFor(carType: cardata.type), car_number: cardata.number, carColor: cardata.color, carModel: cardata.model, accomodateWheelChair: cardata.wheelChairCapable ? "1" : "0", carType: cardata.type)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(addCar)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(DriverCarsResponse.self,
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
    
    func getDriverCarList(successCallBack: @escaping (DriverCarsResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let driverCarsPayload = GetDriverCarsPayload(userId: currentUser.id)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(driverCarsPayload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(DriverCarsResponse.self,
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
    
    func getDriverPayoutDataDetails(successCallBack: @escaping (PayoutDetailsResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let payoutDetailsPayload = PayoutDetailsPaylaod(userId: currentUser.id)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(payoutDetailsPayload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(PayoutDetailsResponse.self,
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
    
    func editDriverPayoutDetails(accountData:BankAccount, successCallBack: @escaping (EditDriverPayoutDetailseResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        let addCar = EditDriverPayoutDetails(userId: currentUser.id, name: accountData.name, bankname: accountData.bankname, routing_number: accountData.routing_number, account_number: accountData.account_number, email: accountData.email, firstName: accountData.firstName, lastName: accountData.lastName, address: accountData.address, country: accountData.country, state: accountData.state, city: accountData.city, zipcode: accountData.zipcode, payout_type: accountData.payout_type)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(addCar)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(EditDriverPayoutDetailseResponse.self,
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
    
    func selectDriverCar(car:DriverCar, successCallBack: @escaping (DriverCarsResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let driverCarsPayload = SelectDriverCarPayload(carTypeId: car.category_id, userId: currentUser.id, car_number: car.car_number, carColor: car.carColor, carModel: car.carModel)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(driverCarsPayload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(DriverCarsResponse.self,
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
    
    func deleteDriverCar(car:DriverCar, successCallBack: @escaping (DeleteDriverCarResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let driverCarsPayload = DeleteDriverCarDetailsPayload(userId: currentUser.id, carTypeId: car.category_id, car_number: car.car_number)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(driverCarsPayload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(DeleteDriverCarResponse.self,
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
    
    func registerNewUser(data : DriverRegistrationPayload, successCallBack: @escaping (UserLoginResponse) -> (), errorCallBack: @escaping (String) -> ()) {
     //   guard let mediaImage = Media(withImage: profileImage, forKey: "profile_image") else { return }
       guard let url = URL(string: AppURLS.baseURL) else { return }
       var request = URLRequest(url: url)
       request.httpMethod = "POST"
       //create boundary
       let boundary = generateBoundary()
       //set content type
       request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
       //call createDataBody method
       let dataBody = createRegisterDriverDataBody(userData: data, boundary: boundary)
       request.httpBody = dataBody
       let session = URLSession.shared
       session.dataTask(with: request) { (data, response, error) in
           
           let networkError = error as NSError?
           
           if (data == nil) {
               print("Server call failed. Nil Data Received.")
               DispatchQueue.main.async(execute: { () -> Void in
                   
                   if networkError != nil {
                       if let errorDescription = networkError!.userInfo["NSLocalizedDescription"] as? String {
                           errorCallBack(errorDescription)
                       }else{
                           errorCallBack("Unknown Error")
                       }
                   }else{
                       //data is nil but no network error is returned
                       errorCallBack("Unknown Error")
                   }
               })
               return
               
           }
           
           if let data = data {
               DispatchQueue.main.async(execute: { () -> Void in
                   do {
                       let jsonDecoder = JSONDecoder()
                       let decodedResponse = try jsonDecoder.decode(UserLoginResponse.self,
                                                                    from: data)
                       
                       print(decodedResponse)
                       successCallBack(decodedResponse)
                   } catch let error {
                       print(error)
                       errorCallBack("Failed to parse the response")
                   }
               })
           }
       }.resume()
    }
    
    private func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
     }
    
    private func createRegisterDriverDataBody(userData: DriverRegistrationPayload, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        /* Fixed Device Data */
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("action")\"\(lineBreak + lineBreak)")
        body.append("\(userData.action.rawValue + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("device")\"\(lineBreak + lineBreak)")
        body.append("\(userData.device + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("deviceToken")\"\(lineBreak + lineBreak)")
        body.append("\(userData.deviceToken + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("updatemobile")\"\(lineBreak + lineBreak)")
        body.append("\(userData.updatemobile + lineBreak)")
        
        /* User Data */
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("fname")\"\(lineBreak + lineBreak)")
        body.append("\(userData.firstName + lineBreak)") //1239
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("lname")\"\(lineBreak + lineBreak)")
        body.append("\(userData.lastName + lineBreak)") //1239
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("phone")\"\(lineBreak + lineBreak)")
        body.append("\(userData.phoneNumber + lineBreak)") //1239
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("usertype")\"\(lineBreak + lineBreak)")
        body.append("\(userData.usertype.rawValue + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("emailId")\"\(lineBreak + lineBreak)")
        body.append("\(userData.emailId + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("password")\"\(lineBreak + lineBreak)")
        body.append("\(userData.password + lineBreak)")
        
        /* User Card Data */
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("cardname")\"\(lineBreak + lineBreak)")
        body.append("\(userData.cardname + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("cardnum")\"\(lineBreak + lineBreak)")
        body.append("\(userData.cardnum + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("cardcvv")\"\(lineBreak + lineBreak)")
        body.append("\(userData.cardcvv + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("cardexpmonth")\"\(lineBreak + lineBreak)")
        body.append("\(userData.cardexpmonth + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("cardexpyear")\"\(lineBreak + lineBreak)")
        body.append("\(userData.cardexpyear + lineBreak)")
        
        /* card Addreess */
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("firstName")\"\(lineBreak + lineBreak)")
        body.append("\(userData.firstName + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("lastName")\"\(lineBreak + lineBreak)")
        body.append("\(userData.lastName + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("country")\"\(lineBreak + lineBreak)")
        body.append("\(userData.country + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("state")\"\(lineBreak + lineBreak)")
        body.append("\(userData.state + lineBreak)") //1239
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("city")\"\(lineBreak + lineBreak)")
        body.append("\(userData.city + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("address")\"\(lineBreak + lineBreak)")
        body.append("\(userData.address + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("zipcode")\"\(lineBreak + lineBreak)")
        body.append("\(userData.zipcode + lineBreak)")
        
        /* User Addreess */
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("user_country")\"\(lineBreak + lineBreak)")
        body.append("\(userData.country + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("user_state")\"\(lineBreak + lineBreak)")
        body.append("\(userData.state + lineBreak)") //1239
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("user_city")\"\(lineBreak + lineBreak)")
        body.append("\(userData.city + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("user_address")\"\(lineBreak + lineBreak)")
        body.append("\(userData.address + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("user_zipcode")\"\(lineBreak + lineBreak)")
        body.append("\(userData.zipcode + lineBreak)")
        
        /* User Car Data */
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("carColor")\"\(lineBreak + lineBreak)")
        body.append("\(userData.carColor + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("carModel")\"\(lineBreak + lineBreak)")
        body.append("\(userData.carModel + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("carType")\"\(lineBreak + lineBreak)")
        body.append("\(userData.carType + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("car_number")\"\(lineBreak + lineBreak)")
        body.append("\(userData.car_number + lineBreak)") //1239
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("carTypeId")\"\(lineBreak + lineBreak)")
        body.append("\(userData.carTypeId + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("handicapped")\"\(lineBreak + lineBreak)")
        body.append("\(userData.handicapped ? "1" : "0")")
        body.append(lineBreak)
        
        /* User Bank Data */
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("bankname")\"\(lineBreak + lineBreak)")
        body.append("\(userData.bankname + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("account_name")\"\(lineBreak + lineBreak)")
        body.append("\(userData.account_name + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("account_number")\"\(lineBreak + lineBreak)")
        body.append("\(userData.account_number + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("routing_number")\"\(lineBreak + lineBreak)")
        body.append("\(userData.routing_number + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("account_emailId")\"\(lineBreak + lineBreak)")
        body.append("\(userData.account_emailId + lineBreak)")
        
        /* mailing Addreess */
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("firstName_mail")\"\(lineBreak + lineBreak)")
        body.append("\(userData.firstName_mail + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("lastName_mail")\"\(lineBreak + lineBreak)")
        body.append("\(userData.lastName_mail + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("country_mail")\"\(lineBreak + lineBreak)")
        body.append("\(userData.country_mail + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("state_mail")\"\(lineBreak + lineBreak)")
        body.append("\(userData.state_mail + lineBreak)") //1239
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("city_mail")\"\(lineBreak + lineBreak)")
        body.append("\(userData.city_mail + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("address_mail")\"\(lineBreak + lineBreak)")
        body.append("\(userData.address_mail + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("zipcode_mail")\"\(lineBreak + lineBreak)")
        body.append("\(userData.zipcode_mail + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("payout_type")\"\(lineBreak + lineBreak)")
        body.append("\(userData.payout_type + lineBreak)")
        
        if let image = userData.profile_image {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(image.key)\"; filename=\"\(image.filename)\"\(lineBreak)")
            body.append("Content-Type: \(image.mimeType + lineBreak + lineBreak)")
            body.append(image.data)
            body.append(lineBreak)
        }
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
    
    func updateDriver(data : EditProfilePayload, successCallBack: @escaping (UserLoginResponse) -> (), errorCallBack: @escaping (String) -> ()) {
     //   guard let mediaImage = Media(withImage: profileImage, forKey: "profile_image") else { return }
       guard let url = URL(string: AppURLS.baseURL) else { return }
       var request = URLRequest(url: url)
       request.httpMethod = "POST"
       //create boundary
       let boundary = generateBoundary()
       //set content type
       request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
       //call createDataBody method
       let dataBody = createUpdateDriverDataBody(userData: data, boundary: boundary)
       request.httpBody = dataBody
       let session = URLSession.shared
       session.dataTask(with: request) { (data, response, error) in
           
           let networkError = error as NSError?
           
           if (data == nil) {
               print("Server call failed. Nil Data Received.")
               DispatchQueue.main.async(execute: { () -> Void in
                   
                   if networkError != nil {
                       if let errorDescription = networkError!.userInfo["NSLocalizedDescription"] as? String {
                           errorCallBack(errorDescription)
                       }else{
                           errorCallBack("Unknown Error")
                       }
                   }else{
                       //data is nil but no network error is returned
                       errorCallBack("Unknown Error")
                   }
               })
               return
               
           }
           
           if let data = data {
               let dataAsString : NSString? = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
               if dataAsString != nil {
                   print("Edit Profile: \(dataAsString!)")
               }
               DispatchQueue.main.async(execute: { () -> Void in
                   do {
                       let jsonDecoder = JSONDecoder()
                       let decodedResponse = try jsonDecoder.decode(UserLoginResponse.self,
                                                                    from: data)
                       
                       print(decodedResponse)
                       successCallBack(decodedResponse)
                   } catch let error {
                       print(error)
                       errorCallBack("Failed to parse the response")
                   }
               })
           }
       }.resume()
    }
    
    private func createUpdateDriverDataBody(userData: EditProfilePayload, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        /* Fixed Device Data */
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("action")\"\(lineBreak + lineBreak)")
        body.append("\(userData.action + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("userId")\"\(lineBreak + lineBreak)")
        body.append("\(userData.userId + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("fname")\"\(lineBreak + lineBreak)")
        body.append("\(userData.fname + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("lname")\"\(lineBreak + lineBreak)")
        body.append("\(userData.lname + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("country_code")\"\(lineBreak + lineBreak)")
        body.append("\(userData.countryCode + lineBreak)")
        
        /* User Data */
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("phone")\"\(lineBreak + lineBreak)")
        body.append("\(userData.phone + lineBreak)") //1239
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("handicapped")\"\(lineBreak + lineBreak)")
        body.append("\(userData.handicapped + lineBreak)") //1239
        
        /* User Addreess */
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("user_country")\"\(lineBreak + lineBreak)")
        body.append("\(userData.pa_country + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("user_state")\"\(lineBreak + lineBreak)")
        body.append("\(userData.pa_state + lineBreak)") //1239
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("user_city")\"\(lineBreak + lineBreak)")
        body.append("\(userData.pa_city + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("user_address")\"\(lineBreak + lineBreak)")
        body.append("\(userData.pa_address + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("user_zipcode")\"\(lineBreak + lineBreak)")
        body.append("\(userData.pa_zipcode + lineBreak)")
    
        if let image = userData.profile_image {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(image.key)\"; filename=\"\(image.filename)\"\(lineBreak)")
            body.append("Content-Type: \(image.mimeType + lineBreak + lineBreak)")
            body.append(image.data)
            body.append(lineBreak)
        }
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
    
    func uploadDriverDocument(documents : [Media], emailId: String, mode: DocumentsUploadScreenMode, successCallBack: @escaping (UploadDriverDocumentResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        var email = ""
        if (mode == DocumentsUploadScreenMode.menuMode) {
            guard let currentUser = LoginService.instance.getCurrentUser() else {
                errorCallBack("Could not load user info")
                return
            }
            email = currentUser.emailId
        } else {
            email = emailId
        }
        
        guard let url = URL(string: AppURLS.baseURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        //create boundary
        let boundary = generateBoundary()
        //set content type
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        //call createDataBody method
        //let dataBody = createRegisterDriverDataBody(userData: data, boundary: boundary)
        let lineBreak = "\r\n"
        var body = Data()
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("action")\"\(lineBreak + lineBreak)")
        body.append("\("uploadDoc_prev_working" + lineBreak)")
        
//        body.append("--\(boundary + lineBreak)")
//        body.append("Content-Disposition: form-data; name=\"\("userId")\"\(lineBreak + lineBreak)")
//        body.append("\(currentUser.id + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\("emailId")\"\(lineBreak + lineBreak)")
        body.append("\(email + lineBreak)")
        
        for doc in documents {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(doc.key)\"; filename=\"\(doc.filename)\"\(lineBreak)")
            body.append("Content-Type: \(doc.mimeType + lineBreak + lineBreak)")
            body.append(doc.data)
            body.append(lineBreak)
        }
        body.append("--\(boundary + lineBreak)")
        request.httpBody = body
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            let networkError = error as NSError?
            
            if (data == nil) {
                print("Server call failed. Nil Data Received.")
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    if networkError != nil {
                        if let errorDescription = networkError!.userInfo["NSLocalizedDescription"] as? String {
                            errorCallBack(errorDescription)
                        }else{
                            errorCallBack("Unknown Error")
                        }
                    }else{
                        //data is nil but no network error is returned
                        errorCallBack("Unknown Error")
                    }
                })
                return
                
            }
            
            if let data = data {
                DispatchQueue.main.async(execute: { () -> Void in
                    do {
                        let jsonDecoder = JSONDecoder()
                        let decodedResponse = try jsonDecoder.decode(UploadDriverDocumentResponse.self,
                                                                     from: data)
                        
                        print(decodedResponse)
                        successCallBack(decodedResponse)
                    } catch let error {
                        print(error)
                        errorCallBack("Failed to parse the response")
                    }
                })
            }
        }.resume()
    }
    
    func getDriverDocuments(successCallBack: @escaping (GetDriverDocumentResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let driverDocumentPayload = GetDriverDocuments(emailId: currentUser.emailId)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(driverDocumentPayload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(GetDriverDocumentResponse.self,
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
    
    // local store Array
    private func storeCarTyprData(carTypeArray: [CarType]?) {
        if let carArray = carTypeArray {
            var cars = [[String:String]]()
            for car in carArray {
                cars.append([car.name:car.carTypeId])
            }
            UserDefaults.standard.set(cars, forKey: "carTypeData")
        }
       
    }
    
    func getCarTypeIdFor(carType: String) -> String {
        if let carsArray = UserDefaults.standard.array(forKey: "carTypeData") {
            let dict = carsArray.first(where: {($0 as! [String : String]).keys.contains(carType)}) as! [String:String]
            return dict[carType] ?? ""
        }
        return ""
    }
    
    func getCarTypeFor(id: String) -> String {
        if let carsTypesArray = UserDefaults.standard.array(forKey: "carTypeData") {
            let dictNew = carsTypesArray.first(where: {($0 as! [String : String]).values.contains(id)}) as! [String:String]
            return dictNew.keys.first ?? ""
        }
        return ""
    }
    
    func updateDriverStatus(isOnline:Bool, successCallBack: @escaping (DriverStatusResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let statusPayload = DriverStatusPayload(userId: currentUser.id, bookingOn: isOnline ? "1" : "0")
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(statusPayload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(DriverStatusResponse.self,
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
    
    func updateDriverLocation(cordinates : CLLocationCoordinate2D, successCallBack: @escaping (GeneralResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let locationPayload = DriverLocationPayload(userId: currentUser.id, lat: cordinates.latitude, long: cordinates.longitude)
       // let locationPayload = DriverLocationPayload(userId: currentUser.id, lat: 16.706561, long: 74.153207)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(locationPayload)
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
    
    func getDriverStatus(successCallBack: @escaping (GetDriverStatusResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let statusPayload = GetDriverStatusPayload(userId: currentUser.id)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(statusPayload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(GetDriverStatusResponse.self,
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
    
    func acceptRideRequest(reqId:String, userId:String, coordinates : CLLocationCoordinate2D,  successCallBack: @escaping (GeneralResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        self.driverRideIdInProgress = reqId
        let acceptReqPayload = AcceptServiceRequestPayload(userId: userId, loginId: currentUser.id, reqId: reqId, lat: coordinates.latitude, long: coordinates.longitude)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(acceptReqPayload)
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
    
    func driverArrivedAtUserLocationRequest(userId:String, coordinates : CLLocationCoordinate2D,  successCallBack: @escaping (GeneralResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        guard let reqId = self.driverRideIdInProgress else {
           // fatalError("current driver ride id is nil.. this should not happen")
            print("current driver ride id is nil.. this should not happen")
            return
        }
        
        let arrivedPayload = ArrivedAtUserLocationRequestPayload(userId: userId, loginId: currentUser.id, reqId: reqId)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(arrivedPayload)
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
    
    func driverArrivedAtUserLocationSendNotificationRequest(userId:String, coordinates : CLLocationCoordinate2D,  successCallBack: @escaping (GeneralResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        guard let reqId = self.driverRideIdInProgress else {
           // fatalError("current driver ride id is nil.. this should not happen")
            print("current driver ride id is nil.. this should not happen")
            return
        }
        
        let arrivedPayload = ArrivedAtUserLocationNotifyRequestPayload(userId: userId, loginId: currentUser.id, reqId: reqId, buffer: "500")
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(arrivedPayload)
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
    
    func startServiceRequest(vendorId:String, pickup:String, successCallBack: @escaping (GeneralResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        guard let reqId = self.driverRideIdInProgress else {
            //fatalError("current driver ride id is nil.. this should not happen")
            print("current driver ride id is nil.. this should not happen")
            return
        }
        
        let startRidePayload = StartServiceRequestPayload(vendorId: currentUser.id, pickuplatLong: pickup, vehicle_number: currentUser.car_number, reqId: reqId, uid: UUID().uuidString)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(startRidePayload)
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
    
    func driverEndRide(vendorId:String, pickuplatLong:String, droplatLong:String, dropLocation:String, pickupLocation:String, successCallBack: @escaping (DriverTripEndResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        guard let reqId = self.driverRideIdInProgress else {
           // fatalError("current driver ride id is nil.. this should not happen")
            print("current driver ride id is nil.. this should not happen")
            return
        }
    
        let endRideRequest = DriverTripEndPayload(vendorId: vendorId, reqId: reqId, pickuplatLong: pickuplatLong, droplatLong: droplatLong, dropLocation: dropLocation, pickupLocation: pickupLocation, vehicle_number: currentUser.car_number, uid: UUID().uuidString)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(endRideRequest)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(DriverTripEndResponse.self,
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
    
    func getDriverPaymentSummary(successCallBack: @escaping (DriverPaymentSummaryResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let payoutDetailsPayload = DriverPaymentSummaryPayload(userId: currentUser.id)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(payoutDetailsPayload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) { responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(DriverPaymentSummaryResponse.self,
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
    
    func updateDriverWaitTimeStart(reqId: String, successCallBack: @escaping (GeneralResponse) -> (), errorCallBack: @escaping (String) -> ()) {
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            errorCallBack("Could not load user info")
            return
        }
        
        let updateWaitTimePayload = DriverUpdateWaitTimePayload(reqId: reqId, vendorId: currentUser.id)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(updateWaitTimePayload)
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

}
