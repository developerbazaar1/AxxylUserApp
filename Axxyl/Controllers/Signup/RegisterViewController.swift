//
//  RegisterViewController.swift
//  axxyl
//
//  Created by Mangesh Kondaskar on 19/09/22.
//

import UIKit
import AVFoundation
import Photos

class RegisterViewController: UIViewController {

    
    @IBOutlet weak var headerView: NewHeaderView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var countryCode: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var reEnteredPassword: UITextField!
    @IBOutlet weak var passwordVisibility: UIButton!
    @IBOutlet weak var reEnteredPasswordVisibility: UIButton!
    @IBOutlet weak var tncTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var wheelChairCheckBoxView: UIStackView!
    @IBOutlet weak var tncCheckBoxBtn: CheckBoxButton!
    @IBOutlet weak var isWheelChairCBBtn: CheckBoxButton!
    
    @IBOutlet weak var pa_firstNameTxtField: UITextField!
    @IBOutlet weak var pa_lastNameTxtField: UITextField!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerView.delegate = self;
        headerView.setConfiguration()
        if let userType = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype), userType ==  UserType.driver.rawValue {
            wheelChairCheckBoxView.isHidden = true
           // tncTopConstraints.constant = -wheelChairCheckBoxView.frame.height + 5
        }
        setupTextFields()
        fetchCountries()
    }
    
    @IBAction func editImageBtn(_ sender: Any) {
        openImageSelectionActionSheet()
    }
    
    @IBAction func countryCodesBtn(_ sender: Any) {
        let countryCodeVC = CountryListViewController()
        countryCodeVC.delegate = self
        let navController = UINavigationController(rootViewController: countryCodeVC)
        self.present(navController, animated: true)
    }
    
    
    @IBAction func passwordVisibilityBtn(_ sender: Any) {
        if password.isSecureTextEntry {
            passwordVisibility.setImage(UIImage(named: "Visibility_Off.png"), for: .normal)
            password.isSecureTextEntry = false
        } else {
            passwordVisibility.setImage(UIImage(named: "Visibility.png"), for: .normal)
            password.isSecureTextEntry = true
        }
    }
    
    @IBAction func reEnteredPasswordVisibilityBtn(_ sender: Any) {
        if reEnteredPassword.isSecureTextEntry {
            reEnteredPasswordVisibility.setImage(UIImage(named: "Visibility_Off.png"), for: .normal)
            reEnteredPassword.isSecureTextEntry = false
        } else {
            reEnteredPasswordVisibility.setImage(UIImage(named: "Visibility.png"), for: .normal)
            reEnteredPassword.isSecureTextEntry = true
        }
    }
    
    @IBAction func wheelchairCheckboxBtn(_ sender: CheckBoxButton) {
        sender.isChecked = !sender.isChecked
    }
    
    
    @IBAction func termsCondidtionCheckboxBtn(_ sender: CheckBoxButton) {
        sender.isChecked = !sender.isChecked
    }
    
    @IBAction func continueBtn(_ sender: Any) {
        if let physicalAddressData = validatePhysicalAddress() {
            guard let userInfo = validateForm() else {
                return
            }
            if let userType = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype), userType ==  UserType.passenger.rawValue {
                let sb = UIStoryboard(name: "Payment", bundle: nil)
                let vcToOpen = sb.instantiateViewController(withIdentifier: "AddPaymentViewController") as! AddPaymentViewController
                vcToOpen.userRegistrationData = userInfo
                vcToOpen.physicalAddress = physicalAddressData
                vcToOpen.isOnboarding = true
                vcToOpen.screenMode = CreditCardPaymentScreenMode.registerPassangerCard
                self.navigationController?.pushViewController(vcToOpen, animated: true)
            } else {
                let sb = UIStoryboard(name: "Signup", bundle: nil)
                let vcToOpen = sb.instantiateViewController(withIdentifier: "VehicleDetailsViewController") as! VehicleDetailsViewController
                vcToOpen.screenMode = VehicleScreenMode.RegisterCar
                vcToOpen.physicalAddressData = physicalAddressData
                vcToOpen.driverRegistrationData = (userInfo as! DriverRegistrationPayload)
                self.navigationController?.pushViewController(vcToOpen, animated: true)
            }
        }
    }

    @IBAction func openTermsAndConditionsBtn(_ sender: Any) {
        let sb = UIStoryboard(name: "Help", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "HelpTopicDetailsViewController") as! HelpTopicDetailsViewController
        vcToOpen.topic = "Terms and Conditions"
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    private func validateForm() -> UserRegistrationPayload? {
        guard let firstName_ = self.firstName.text, !firstName_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter first name")
            return nil
        }
        
        guard let lastName_ = self.lastName.text, !lastName_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter last name")
            return nil
        }
        
        guard let phoneNumber_ = self.phoneNumber.text, !phoneNumber_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter phone number")
            return nil
        }
        
        guard let emailId = self.email.text, !emailId.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter email")
            return nil
        }
        
        if !emailId.validateEmail() {
            AlertManager.showErrorAlert(message: "Please enter valid email id")
            return nil
        }
        
        guard let password_ = self.password.text, !password_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter password")
            return nil
        }
        
        guard let confirmPassword = self.reEnteredPassword.text, !confirmPassword.isEmpty else {
            AlertManager.showErrorAlert(message: "Please re-enter password")
            return nil
        }
        
        if password_ != confirmPassword {
            AlertManager.showErrorAlert(message: "Password does not match")
            return nil
        }
    
        if !tncCheckBoxBtn.isChecked {
            AlertManager.showInfoAlert(message: "Please accept AXXYL's Term and Conditions by tapping on checkbox.")
            return nil
        }
        
        /* Commented as it is optional field*/
//        guard let image_ = self.profileImage.image else {
//            AlertManager.showErrorAlert(message: "Please upload image")
//            return nil
//        }
        
        let imageObj = Media(withImage: self.profileImage.image, forKey: "profile_image")
        
        let registrationDt: UserRegistrationPayload!
        if let userType = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype), userType ==  UserType.passenger.rawValue {
            registrationDt = UserRegistrationPayload()
            registrationDt.handicapped = isWheelChairCBBtn.isChecked
            registrationDt.usertype = UserType(rawValue: UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype) ?? UserType.passenger.rawValue)
        } else {
            registrationDt = DriverRegistrationPayload()
            registrationDt.usertype = UserType(rawValue: UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype) ?? UserType.driver.rawValue)
        }
        registrationDt.emailId = emailId
        registrationDt.firstName = firstName_
        registrationDt.lastName = lastName_
        registrationDt.password = password_
        registrationDt.countryCode = self.countryCode.text ?? "+1"
        registrationDt.phoneNumber = phoneNumber_
        registrationDt.profile_image = imageObj

        return registrationDt
    }
    
    private func validatePhysicalAddress() -> PhysicalAddressData? {
        
        
//        guard let fname = self.pa_firstNameTxtField.text, !fname.isEmpty else {
//            AlertManager.showErrorAlert(message: "Please enter first name under physical address")
//            return nil
//        }
//        
//        guard let lname = self.pa_lastNameTxtField.text, !lname.isEmpty else {
//            AlertManager.showErrorAlert(message: "Please enter last name under physical address")
//            return nil
//        }
        
        guard let address = self.pa_addressTxtField.text, !address.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter physical address")
            return nil
        }
        
        guard !self.pa_selectedCountry.isEmpty else {
            AlertManager.showErrorAlert(message: "Please select physical address - Country")
            return nil
        }
        
        guard !self.pa_selectedState.isEmpty else {
            AlertManager.showErrorAlert(message: "Please select physical address - State")
            return nil
        }
        
        guard !self.pa_selectedCity.isEmpty else {
            AlertManager.showErrorAlert(message: "Please select physical address - City")
            return nil
        }
        
        guard let zip = self.pa_zipcodeTxtField.text, !zip.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter physical address zip code")
            return nil
        }
        
//        if (fname.uppercased() != self.firstName.text?.uppercased() || lname.uppercased() != self.lastName.text?.uppercased()) {
//            AlertManager.showErrorAlert(message: "Physical address first name and last name should match with profile first name and last name")
//            return nil
//        }
        let fname = self.firstName.text ?? "";
        let lname = self.lastName.text ?? "";
        
        return PhysicalAddressData(firstName: fname, lastName: lname, country: pa_selectedCountry, state: pa_selectedState, city: pa_selectedCity, address: address, zipcode: zip)
    }
    
    private func openImageSelectionActionSheet() {
        let actionMenu = UIAlertController(title: "Choose User's Photo", message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { (UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                DispatchQueue.main.async {
                    self.checkCameraPermission()
                }
//                self.imagePicker.delegate = self
//                self.imagePicker.sourceType = .camera
//                self.imagePicker.allowsEditing = false
//                
//                self.present(self.imagePicker, animated: true, completion: nil)
            }
        })
        let chooseLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { (UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                DispatchQueue.main.async {
                    self.checkPhotoLibraryPermission()
                }
//                self.imagePicker.delegate = self
//                self.imagePicker.sourceType = .savedPhotosAlbum
//                self.imagePicker.allowsEditing = false
//                
//                self.present(self.imagePicker, animated: true, completion: nil)
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
            DispatchQueue.main.async {
                self.showSettingsAlert(for: "Camera")
            }
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
            DispatchQueue.main.async {
                self.showSettingsAlert(for: "Photo Library")
            }
        case .limited:
            DispatchQueue.main.async {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .savedPhotosAlbum
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
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

extension RegisterViewController : NewHeaderViewProtocol {
    var headerTitle: String {
        return "Create an account"
    }
    
    var isBackEnabled: Bool {
        return true
    }
    
    func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension RegisterViewController: UIPickerViewDelegate, UIPickerViewDataSource {

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



extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
 //       textField.resignFirstResponder()
        return true
    }
}

extension RegisterViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage.image = image
        }
        self.dismiss(animated: true)
    }
}


extension RegisterViewController : CountryCodeSelectionDelegate {
    func didSelectCountry(country: Country) {
        self.countryCode.text = country.dial_code
    }
}

extension RegisterViewController {
    
    
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

struct PhysicalAddressData: Codable {
    var firstName:String
    var lastName:String
    
    var country:String
    var state:String
    var city:String
    var address:String
    var zipcode:String
}
