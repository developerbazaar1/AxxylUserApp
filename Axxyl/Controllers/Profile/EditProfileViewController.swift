//
//  EditProfileViewController.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 30/09/22.
//

import UIKit
import Kingfisher
import AVFoundation
import Photos

class EditProfileViewController: UIViewController {

    @IBOutlet weak var headerView: NewHeaderView!
    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var countryCodeTxtField: UILabel!
    @IBOutlet weak var phoneNumberTxtField: UITextField!
    @IBOutlet weak var saveChangesBtnPressed: GradientButton!
    @IBOutlet weak var profileImgView: UIImageView!
    
    @IBOutlet weak var pa_addressTxtField: UITextField!
    @IBOutlet weak var pa_countryTxtField: UITextField!
    @IBOutlet weak var pa_stateTxtField: UITextField!
    @IBOutlet weak var pa_cityTxtField: UITextField!
    @IBOutlet weak var pa_zipcodeTxtField: UITextField!
    
    private var countries: [String] = []
    private var states: [String] = []
    private var cities: [String] = []
    private var pa_selectedCountry: String = ""
    private var pa_selectedState: String = ""
    private var pa_selectedCity: String = ""
    var selectedStateRow = 0
    var selectedCountryRow = 0
    var selectedCityRow = 0
    
    var currentPickerView : UIPickerView!
    
    var imagePicker = UIImagePickerController()
    let myuser = LoginService.instance.getCurrentUser()
    var profileImage: UIImage!
    var isImageChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialValues()
        //self.saveChangesBtnPressed.addTarget(self, action: #selector(EditProfileViewController.saveChangesBtnClicked), for: UIControl.Event.touchUpInside)
        self.headerView.delegate = self
        self.headerView.setConfiguration()
        setupTextFields()
        fetchCountries()
    }
    
    func setInitialValues() {
        if let currentUser = LoginService.instance.getCurrentUser() {
            var nameComponents = currentUser.name.components(separatedBy: " ")
            self.firstNameTxtField.text = nameComponents.removeFirst()
            self.lastNameTxtField.text = nameComponents.joined(separator: " ")
            self.countryCodeTxtField.text = currentUser.country
            self.phoneNumberTxtField.text = currentUser.phone
            self.emailTxtField.text = currentUser.emailId
            self.profileImgView.kf.setImage(with: URL(string: currentUser.profile_image))
            self.profileImage = self.profileImgView.image
            self.pa_addressTxtField.text = currentUser.pa_address
            self.pa_countryTxtField.text = currentUser.pa_country
            self.pa_selectedCountry = currentUser.pa_country
            self.pa_stateTxtField.text = currentUser.pa_state
            self.pa_selectedState = currentUser.pa_state
            self.pa_cityTxtField.text = currentUser.pa_city
            self.pa_selectedCity = currentUser.pa_city
            self.pa_zipcodeTxtField.text = currentUser.pa_zipcode
        }
    }
    
    func openImageSelectionActionSheet() {
        let actionMenu = UIAlertController(title: "Choose User's Photo", message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { (UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                DispatchQueue.main.async {
                    self.checkCameraPermission()
                }
            }
        })
        let chooseLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { (UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                DispatchQueue.main.async {
                    self.checkPhotoLibraryPermission()
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
            self.dismiss(animated: true)
        })
        
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            actionMenu.addAction(takePhotoAction)
        }
        actionMenu.addAction(chooseLibraryAction)
        actionMenu.addAction(cancelAction)
        self.present(actionMenu, animated: true, completion: nil)
    }
    
    @IBAction func uploadImageClicked(_ sender: Any) {
        openImageSelectionActionSheet()
    }
    
    @IBAction func countryCodeSelectionClicked(_ sender: Any) {
        guard let userType = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype), userType !=  UserType.driver.rawValue else {
            AlertManager.showInfoAlert(message: "Sorry, you can not modify your prifile through app. If there are any changes to your profile please connect with Axxyl support team.")
            return 
        }
        
        let countryCodeVC = CountryListViewController()
        countryCodeVC.delegate = self
        let navController = UINavigationController(rootViewController: countryCodeVC)
        self.present(navController, animated: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveChangesBtnClicked(_ sender : GradientButton) {
        guard let firstName_ = self.firstNameTxtField.text, !firstName_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter first name")
            return
        }
        
        guard let lastName_ = self.lastNameTxtField.text, !lastName_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter last name")
            return
        }
        
        guard let countryCode_ = self.countryCodeTxtField.text, !countryCode_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please select valid country code")
            return
        }
        
        guard let phoneNumber_ = self.phoneNumberTxtField.text, !phoneNumber_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter phone number")
            return
        }
        
        guard let emailId = self.emailTxtField.text, !emailId.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter email")
            return
        }
        
        if !emailId.validateEmail() {
            AlertManager.showErrorAlert(message: "Please enter valid email id")
            return
        }
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            AlertManager.showErrorAlert(message: "Failed to load profile")
            return
        }
        
        guard let address = self.pa_addressTxtField.text, !address.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter physical address")
            return
        }
        
        guard !self.pa_selectedCountry.isEmpty else {
            AlertManager.showErrorAlert(message: "Please select physical address - Country")
            return
        }
        
        guard !self.pa_selectedState.isEmpty else {
            AlertManager.showErrorAlert(message: "Please select physical address - State")
            return
        }
        
        guard !self.pa_selectedCity.isEmpty else {
            AlertManager.showErrorAlert(message: "Please select physical address - City")
            return
        }
        
        guard let zip = self.pa_zipcodeTxtField.text, !zip.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter physical address zip code")
            return
        }
        
        let username = currentUser.name.components(separatedBy: " ")
        
        if let imageData = profileImgView.image, profileImage == nil || imageData.pngData() != profileImage.pngData() {
            isImageChanged = true
        }
        
        if (firstName_ != username[0] || lastName_ != username[1] || countryCode_ != currentUser.country || phoneNumber_ != currentUser.phone || emailId != currentUser.emailId) || isImageChanged || pa_selectedCountry != currentUser.pa_country || pa_selectedState != currentUser.pa_state || pa_selectedCity != currentUser.pa_city || address != currentUser.pa_address || zip != currentUser.pa_zipcode {
            let editedProfile = EditProfilePayload(userId: currentUser.id, fname: firstName_, lname: lastName_, phone: phoneNumber_, countryCode: countryCode_, handicapped: currentUser.handicapped, profile_image: Media(withImage: profileImgView.image, forKey: "profile_image"), pa_address: address, pa_country: self.pa_selectedCountry, pa_state: self.pa_selectedState, pa_city: self.pa_selectedCity, pa_zipcode: zip)

            LoadingSpinner.manager.showLoadingAnimation(delegate: self)
            //LoginService.instance.editProfile(updatedProfile: editedProfile) { [weak self] updatedLoginResponse in
            DriverService.instance.updateDriver(data: editedProfile) { [weak self] updatedLoginResponse in
                LoadingSpinner.manager.hideLoadingAnimation()
                if updatedLoginResponse.isSuccess() {
                    LoginService.instance.setCurrentUser(user: updatedLoginResponse.user)
                    DispatchQueue.main.async {
                        self?.backAction(UIButton())
                    }
                }else{
                    AlertManager.showErrorAlert(message: updatedLoginResponse.msg)
                }

            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        } else {
            AlertManager.showInfoAlert(message: "No data changed to update the profile")
        }
    }

    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Camera access granted.")
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = false
            
            self.present(self.imagePicker, animated: true, completion: nil)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { response in
                if response {
                    DispatchQueue.main.async {
                        self.imagePicker.delegate = self
                        self.imagePicker.sourceType = .camera
                        self.imagePicker.allowsEditing = false
                        
                        self.present(self.imagePicker, animated: true, completion: nil)
                    }
                } else {
                    print("Camera access denied after request.")
                    // Show settings alert if denied
                    DispatchQueue.main.async {
                        self.showSettingsAlert(for: "Camera")
                    }
                }
            }
        case .denied, .restricted:
            print("Camera access denied.")
            // Show settings alert if denied
            self.showSettingsAlert(for: "Camera")
        @unknown default:
            print("Unknown camera authorization status.")
        }
    }

    func checkPhotoLibraryPermission() {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized:
            print("Photo library access granted.")
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = false
            
            self.present(self.imagePicker, animated: true, completion: nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        self.imagePicker.delegate = self
                        self.imagePicker.sourceType = .savedPhotosAlbum
                        self.imagePicker.allowsEditing = false
                        
                        self.present(self.imagePicker, animated: true, completion: nil)
                    }
                case .denied, .restricted:
                    print("Photo library access denied after request.")
                    // Show settings alert if denied
                    DispatchQueue.main.async {
                        self.showSettingsAlert(for: "Photo Library")
                    }
                default:
                    break
                }
            }
        case .denied, .restricted:
            print("Photo library access denied.")
            // Show settings alert if denied
            self.showSettingsAlert(for: "Photo Library")
        case .limited:
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = false
            
            self.present(self.imagePicker, animated: true, completion: nil)
        @unknown default:
            print("Unknown photo library authorization status.")
        }
    }

    func showSettingsAlert(for type: String) {
        var msg = ""
        if (type == "Photo Library") {
            msg = "You’ve denied \(type.lowercased()) access. To update your profile photo, we need access to your photo library. This allows you to upload your profile photo from your gallery. You can enable it by following this path:\n\nSettings → Axxyl → Photos → Select 'Full Access' or 'Limited Access'."
        } else {
            msg = "You’ve denied \(type.lowercased()) access. To update your profile photo, we need access to your camera. This allows you to upload your profile photo by capturing your selfie. You can enable it by following this path:\n\nSettings → Axxyl → Camera → Select 'Allows'."
        }
        let alertController = UIAlertController(
            title: "\(type) Access Denied",
            message: msg,
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { action in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
        }))

        self.present(alertController, animated: true, completion: nil)
    }
    
//    func uploadImage() {
//        let urlPath = "Your URL"
//        guard let endpoint = URL(string: "https://axxyl.com/webservices_android") else {
//            print("Error creating endpoint")
//            return
//        }
//        var request = URLRequest(url: endpoint)
//        request.httpMethod = "POST"
//        let boundary = "Boundary-\(UUID().uuidString)"
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        let mimeType = "image/jpg"
//        let body = NSMutableData()
//        let boundaryPrefix = " — \(boundary)\r\n"
//        body.append(boundaryPrefix.data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"\("action")\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\(Actions.editprofile.rawValue)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"\("userId")\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\("1271")\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"\("fname")\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\("Mike")\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"\("lname")\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\("Hussy")\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"\("phone")\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\("1234567890")\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"\("handicapped")\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\("0")\r\n".data(using: .utf8)!)
//        let imageData = profileImgView.image!.jpegData(compressionQuality: 1.0)!
//        var filename = "MKTestImage"
//        body.append("Content-Disposition: form-data; name=\"\("profile_image")\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\("1271")\r\n".data(using: .utf8)!)
//
//        body.append(boundaryPrefix.data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
//        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
//        body.append(imageData)
//        body.append("\r\n".data(using: .utf8)!)
//        let str = " — ".appending(boundary.appending(" — "))
//        body.append(str.data(using: .utf8)!)
//        request.httpBody = body.base64EncodedData()
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            do {
//                LoadingSpinner.manager.hideLoadingAnimation()
//                print("\(String(describing: response))")
//                print("\(String(describing: error))")
//            }
//        }
//    }
//
//    func uploadImageToServer() {
//       let parameters = Parameters(name: "MyTestFile123321", id: "1271")// ["name": "MyTestFile123321","id": "12345"]
//        guard let mediaImage = Media(withImage: profileImgView.image!, forKey: "profile_image") else { return }
//       guard let url = URL(string: "https://axxyl.com/webservices_android") else { return }
//       var request = URLRequest(url: url)
//       request.httpMethod = "POST"
//       //create boundary
//       let boundary = generateBoundary()
//       //set content type
//       request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//       //call createDataBody method
//       let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
//       request.httpBody = dataBody
//       let session = URLSession.shared
//       session.dataTask(with: request) { (data, response, error) in
//          if let response = response {
//             print(response)
//          }
//          if let data = data {
//             do {
//                let json = try JSONSerialization.jsonObject(with: data, options: [])
//                print(json)
//                 LoadingSpinner.manager.hideLoadingAnimation()
//             } catch {
//                print(error)
//             }
//          }
//       }.resume()
//    }
//
//    func createDataBody(withParameters params: Parameters?, media: [Media]?, boundary: String) -> Data {
//       let lineBreak = "\r\n"
//       var body = Data()
//       if let parameters = params {
//           // driver document upload
////           body.append("--\(boundary + lineBreak)")
////           body.append("Content-Disposition: form-data; name=\"\("action")\"\(lineBreak + lineBreak)")
////           body.append("\("uploadDoc" + lineBreak)")
////
////           body.append("--\(boundary + lineBreak)")
////           body.append("Content-Disposition: form-data; name=\"\("userId")\"\(lineBreak + lineBreak)")
////           body.append("\("1337" + lineBreak)") //1239
//
//
//           body.append("--\(boundary + lineBreak)")
//           body.append("Content-Disposition: form-data; name=\"\("action")\"\(lineBreak + lineBreak)")
//           body.append("\("editprofile" + lineBreak)") //1239
//
//           body.append("--\(boundary + lineBreak)")
//           body.append("Content-Disposition: form-data; name=\"\("userId")\"\(lineBreak + lineBreak)")
//           body.append("\("1239" + lineBreak)") //1239
//
//           body.append("--\(boundary + lineBreak)")
//           body.append("Content-Disposition: form-data; name=\"\("fname")\"\(lineBreak + lineBreak)")
//           body.append("\("max" + lineBreak)") //1239
//
//           body.append("--\(boundary + lineBreak)")
//           body.append("Content-Disposition: form-data; name=\"\("lname")\"\(lineBreak + lineBreak)")
//           body.append("\("payne" + lineBreak)") //1239
//
//           body.append("--\(boundary + lineBreak)")
//           body.append("Content-Disposition: form-data; name=\"\("phone")\"\(lineBreak + lineBreak)")
//           body.append("\("123456789" + lineBreak)") //1239
//
//           body.append("--\(boundary + lineBreak)")
//           body.append("Content-Disposition: form-data; name=\"\("handicapped")\"\(lineBreak + lineBreak)")
//           body.append("\("0" + lineBreak)") //1239
//
//           body.append("--\(boundary + lineBreak)")
//           body.append("Content-Disposition: form-data; name=\"\("car_number")\"\(lineBreak + lineBreak)")
//           body.append("\("GB16879" + lineBreak)") //1239
//
//           body.append("--\(boundary + lineBreak)")
//           body.append("Content-Disposition: form-data; name=\"\("carTypeId")\"\(lineBreak + lineBreak)")
//           body.append("\("22" + lineBreak)") //1239
//       }
//       if let media = media {
//          for photo in media {
//             body.append("--\(boundary + lineBreak)")
//             body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
//             body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
//             body.append(photo.data)
//             body.append(lineBreak)
//          }
//       }
//       body.append("--\(boundary)--\(lineBreak)")
//       return body
//    }
    
    func setupPickerViewfor(_ textField : UITextField, tag: Int){

        let pickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        pickerView.tag = tag
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.white
        textField.inputView = pickerView
        self.currentPickerView = pickerView
        // ToolBar
       // let toolBar = UIToolbar()
        let toolBar: UIToolbar = {
            let v = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 44.0)))
            return v
        }()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92.0/255.0, green: 216.0/255.0, blue: 255.0/255.0, alpha: 1)
        toolBar.sizeToFit()

        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.pickerDoneClicked))
        doneButton.tintColor = .black
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.pickerCancelClicked))
        cancelButton.tintColor = .black
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar

    }
    
    @objc func pickerDoneClicked() {
        print("resign first responder", self.currentPickerView.tag)
        if (self.currentPickerView.tag == 1) { // state
            if (states.count != 0) {
                self.pa_selectedState = self.states[self.selectedStateRow]
                self.pa_stateTxtField.text = pa_selectedState
                self.resetCity()
                self.fetchCities(for: self.pa_selectedCountry, state: self.pa_selectedState)
                pa_stateTxtField.resignFirstResponder()
            }
        }else if (self.currentPickerView.tag == 2) { // city
            if (cities.count != 0) {
                pa_selectedCity = self.cities[self.selectedCityRow]
                self.pa_cityTxtField.text = pa_selectedCity
                pa_cityTxtField.resignFirstResponder()
            }
        }else if (self.currentPickerView.tag == 4) { // country
            if (countries.count != 0) {
                pa_selectedCountry = self.countries[self.selectedCountryRow]
                self.pa_countryTxtField.text = pa_selectedCountry
                self.resetStateAndCity()
                self.fetchStates(for: self.pa_selectedCountry)
                pa_countryTxtField.resignFirstResponder()
            }
        }
    }
    
    @objc func pickerCancelClicked(textField: UITextField) {
        print("resign first responder")
        pa_countryTxtField.resignFirstResponder()
        pa_stateTxtField.resignFirstResponder()
        pa_cityTxtField.resignFirstResponder()
    }
}

extension EditProfileViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        guard let userType = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype), userType !=  UserType.driver.rawValue else {
            AlertManager.showInfoAlert(message: "Sorry, you can not modify your prifile through app. If there are any changes to your profile please connect with Axxyl support team.")
            return true
        }
        
        switch textField {
        case pa_stateTxtField:
            //            if states.isEmpty {
            //                showAlert(message: "Please enter a country first")
            //                return false
            //            }
            return true
        case pa_cityTxtField:
            //            if cities.isEmpty {
            //                showAlert(message: "Please select a state first")
            //                return false
            //            }
            return true
        case pa_countryTxtField:
            return true
        default:
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
        if textField == pa_stateTxtField {
            if (self.states.count != 0) {
                setupPickerViewfor(pa_stateTxtField, tag: 1)
            } else {
                let cancleAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel) { action in
                    self.pa_stateTxtField.resignFirstResponder()
                }
                AlertManager.showCustomAlertWith("Information", message: "Sorry, currently we are not providing service in your Country!", actions: [cancleAction])
            }
        }
        if textField == pa_cityTxtField {
            if (self.cities.count != 0) {
                setupPickerViewfor(pa_cityTxtField, tag: 2)
            } else {
                let cancleAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel) { action in
                    self.pa_stateTxtField.resignFirstResponder()
                }
                AlertManager.showCustomAlertWith("Information", message: "Sorry, currently we are not providing service in your State!", actions: [cancleAction])
            }
        }
        if (textField == pa_countryTxtField) {
            setupPickerViewfor(pa_countryTxtField, tag: 4)
        }
    }
    
}

extension EditProfileViewController : NewHeaderViewProtocol {
    var headerTitle: String {
        return "Edit Profile"
    }
    
    func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    var isBackEnabled: Bool {
        return true
    }
}

extension EditProfileViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImgView.image = image
        }
        self.dismiss(animated: true)
    }
}

extension EditProfileViewController : CountryCodeSelectionDelegate {
    func didSelectCountry(country: Country) {
        self.countryCodeTxtField.text = country.dial_code
    }
}

extension EditProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerView.tag == 3 ? 2 : 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1: // State picker
            return states.count
        case 2: // City picker
            return cities.count
        case 4: // country picker
            return countries.count
        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1: // State picker
            return row < states.count ? states[row] : nil
        case 2: // City picker
            return row < cities.count ? cities[row] : nil
        case 4: // country picker
            return row < countries.count ? countries[row] : nil
        default:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            self.selectedStateRow = row
//            self.fetchCities(for: self.selectedCountry, state: self.selectedState)
        case 2:
            self.selectedCityRow = row
        case 4:
            self.selectedCountryRow = row
//            self.fetchStates(for: self.selectedCountry)
        default:
            break
        }
        
    }
}

extension EditProfileViewController {
    
    
    // MARK: - Setup
    private func setupTextFields() {
        pa_countryTxtField.delegate = self
        pa_stateTxtField.delegate = self
        pa_cityTxtField.delegate = self
        
        // Disable state and city fields initially
//        stateTxtField.isEnabled = false
//        cityTxtField.isEnabled = false
        
        // Add target for country text field changes
//        countryTxtField.addTarget(self, action: #selector(countryTextChanged), for: .editingChanged)
    }
    
    @objc private func fetchStatesForCountry() {
        guard let countryText = pa_countryTxtField.text, !countryText.isEmpty else { return }
        
        pa_selectedCountry = countryText
        fetchStates(for: countryText)
    }
    
    private func resetStateAndCity() {
        pa_stateTxtField.text = ""
        pa_cityTxtField.text = ""
//        stateTxtField.isEnabled = false
//        cityTxtField.isEnabled = false
        states.removeAll()
        cities.removeAll()
        pa_selectedState = ""
        pa_selectedCity = ""
    }
    
    private func resetCity() {
        pa_cityTxtField.text = ""
//        cityTxtField.isEnabled = false
        cities.removeAll()
        pa_selectedCity = ""
    }
    
    // MARK: - API Calls
    private func fetchCountries() {
        showLoadingIndicator()
        print("Fetching countries")
        
        let countryPayload = AddressCountryPayload(country: "", state:"", city:"")
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(countryPayload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) {[weak self] responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(StateResponse.self,
                                                                 from: responseData)
                    print(decodedResponse)
                    self?.countries = decodedResponse.data;
                    self?.hideLoadingIndicator()
                    if !(self?.countries.isEmpty ?? true) {
//                        self?.showAlert(message: "Tap on State field to select a state")
                    }else {
                        self?.showAlert(message: "No countries found. Please try again later")
                    }
                } catch let error {
                    print(error)
                    self?.hideLoadingIndicator()
                    self?.showAlert(message: "Error parsing countries data: \(error.localizedDescription)")
                }
                
            } error: {[weak self] errorMsg, isNetworkError in
                self?.showAlert(message: "Error parsing countries data: \(errorMsg)")
                self?.hideLoadingIndicator()
            }
        } catch {
            hideLoadingIndicator()
        }
    }
    
    // MARK: - API Calls
    private func fetchStates(for country: String) {
        showLoadingIndicator()
        print("Fetching states for \(country)")

        let countryPayload = AddressCountryPayload(country: country, state:"", city:"")
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(countryPayload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) {[weak self] responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(StateResponse.self,
                                                                 from: responseData)
                    print(decodedResponse)
                    self?.states = decodedResponse.data;
                    self?.hideLoadingIndicator()
//                    if !(self?.states.isEmpty ?? true) {
//                        self?.stateTxtField.isEnabled = true
//                        self?.showAlert(message: "Tap on State field to select a state")
//                    }else {
//                        self?.showAlert(message: "No states found for this country")
//                    }
                } catch let error {
                    print(error)
                    self?.hideLoadingIndicator()
                    self?.showAlert(message: "Error parsing states data: \(error.localizedDescription)")
//                    errorCallBack("Failed to parse the response")
                }
                
            } error: {[weak self] errorMsg, isNetworkError in
//                errorCallBack(errorMsg)
                self?.showAlert(message: "Error parsing states data: \(errorMsg)")
                self?.hideLoadingIndicator()
            }
        } catch {
            hideLoadingIndicator()
//            errorCallBack("Failed to encode data")
        }
    }
    
    private func fetchCities(for country: String, state: String) {
        showLoadingIndicator()
        
        
        print("Fetching cities for country - \(country) and state - \(state)")
        
        let statePayload = AddressCountryPayload(country: country.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "", state:state.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "", city:"")
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(statePayload)
            let networkManager = NetworkManager()
            networkManager.post(AppURLS.baseURL, data: data as AnyObject) {[weak self] responseData in
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedResponse = try jsonDecoder.decode(StateResponse.self,
                                                                 from: responseData)
                    print(decodedResponse)
                    self?.cities = decodedResponse.data;
                    self?.hideLoadingIndicator()
//                    if !(self?.cities.isEmpty ?? true) {
//                        self?.cityTxtField.isEnabled = true
//                        self?.cityTxtField.text = self?.cities.first ?? ""
//                        self?.selectedCity = self?.cities.first ?? ""
//                        self?.selectedCity = self?.cities.first ?? ""
//                        self?.showAlert(message: "Tap on City field to select a city")
//                    }else {
//                        self?.showAlert(message: "No cities found for this country")
//                    }
                } catch let error {
                    print(error)
                    self?.hideLoadingIndicator()
                    self?.showAlert(message: "Error parsing cities data: \(error.localizedDescription)")
//                    errorCallBack("Failed to parse the response")
                }
                
            } error: {[weak self] errorMsg, isNetworkError in
//                errorCallBack(errorMsg)
                self?.showAlert(message: "Error parsing cities data: \(errorMsg)")
                self?.hideLoadingIndicator()
            }
        } catch {
            hideLoadingIndicator()
//            errorCallBack("Failed to encode data")
        }
        
    }

    // MARK: - Helper Methods
    private func showLoadingIndicator() {
        // You can implement a loading indicator here
        // For example, show an activity indicator
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
    }
    
    private func hideLoadingIndicator() {
        // Hide the loading indicator
        LoadingSpinner.manager.hideLoadingAnimation()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
