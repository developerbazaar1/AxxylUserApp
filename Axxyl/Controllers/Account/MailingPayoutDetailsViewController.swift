//
//  MailingPayoutDetailsViewController.swift
//  Axxyl
//
//  Created by Mangesh on 11/16/25.
//

import UIKit

class MailingPayoutDetailsViewController: UIViewController {
    
    @IBOutlet weak var mail_firstNameTxtField: UITextField!
    @IBOutlet weak var mail_lastNameTxtField: UITextField!
    @IBOutlet weak var mail_addressTxtField: UITextField!
    @IBOutlet weak var mail_countryTxtField: UITextField!
    @IBOutlet weak var mail_cityTxtField: UITextField!
    @IBOutlet weak var mail_zipcodeTxtField: UITextField!
    @IBOutlet weak var mail_stateTxtField: UITextField!
    @IBOutlet weak var continueBtn: GradientButton!
    @IBOutlet weak var useDirectDeposit: UIButton!
    @IBOutlet weak var editMailingAddressButton: UIStackView!
    
    var driverRegistrationData : DriverRegistrationPayload!
    var physicalAddressData : PhysicalAddressData!
    var payoutDetails: BankAccount!
    var screenMode: MailingPayoutDetaisScreenMode = MailingPayoutDetaisScreenMode.registerDriverMailingPayoutDetails
    
    private var countries: [String] = []
    private var states: [String] = []
    private var cities: [String] = []
    private var selectedCountry: String = ""
    private var selectedState: String = ""
    private var selectedCity: String = ""
    var selectedStateRow = 0
    var selectedCountryRow = 0
    var selectedCityRow = 0
    
    var currentPickerView : UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateScreen()
//        if screenMode == CreditCardPaymentScreenMode.registerPassangerCard || screenMode == CreditCardPaymentScreenMode.registerDriverCard {
//            if physicalAddress == nil {
//                guard let user = LoginService.instance.getCurrentUser() else {
//                    return }
//                
//                physicalAddress = PhysicalAddressData(firstName: user.pa_firstName, lastName: user.pa_lastName, country: user.pa_country, state: user.pa_state, city: user.pa_city, address: user.pa_address, zipcode: user.pa_zipcode)
//            }
        if (screenMode != .editMailingPayoutDetails) {
            prefillBillingDetails()
        }
//        }
        
//        if (card != nil) { // Edit Mode
//            cardNumberTxtField.text = card.cardnum;
////            cardImage.image = UIImage(named: "Visa")
//            cardHolderNameTxtField.text = card.cardname
//            cardExpiryDateTxtField.text = "\(card.cardexpmonth)/\(card.cardexpyear)"
//            cardCVVTxtField.text = ""
//            self.editPaymentBtnStackView.isHidden = false
//            self.backBtn.isHidden = false
//            self.onboardingButtonsStackView.isHidden = true
//            self.addPaymentBtn.isHidden = true
//            self.view.layoutIfNeeded()
//        }
//        self.headerLbl.text = titleString
        setupTextFields()
        fetchCountries()
        preloadAddressData(country: self.selectedCountry, state: self.selectedState)
    }
    
    
    func updateScreen() {
        
        switch screenMode {
        case .registerDriverMailingPayoutDetails:
//            self.headerLblTxt.text = "Mailing Payout details"
//            self.backBtn.isHidden = false
//            self.headerStepLblTxt.isHidden = false
            self.editMailingAddressButton.isHidden = true
            self.continueBtn.isHidden = false
            self.useDirectDeposit.isHidden = false
        case .editMailingPayoutDetails:
//            self.headerLblTxt.text = "Edit payout details"
//            self.backBtn.isHidden = false
//            self.headerStepLblTxt.isHidden = true
            self.editMailingAddressButton.isHidden = false
            self.continueBtn.isHidden = true
            self.useDirectDeposit.isHidden = true
            if (payoutDetails != nil) { // Edit Mode
                self.mail_firstNameTxtField.text = payoutDetails.firstName
                self.mail_lastNameTxtField.text = payoutDetails.lastName
                self.mail_addressTxtField.text = payoutDetails.address
                self.mail_countryTxtField.text = payoutDetails.country
                self.mail_stateTxtField.text = payoutDetails.state
                self.mail_cityTxtField.text = payoutDetails.city
                self.mail_zipcodeTxtField.text = payoutDetails.zipcode
                self.selectedCountry = self.mail_countryTxtField.text ?? ""
                self.selectedState = self.mail_stateTxtField.text ?? ""
                self.selectedCity = self.mail_cityTxtField.text ?? ""
            }
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        guard let bankAccount = validateForm() else {
            return
        }
        if bankAccount != payoutDetails {
            LoadingSpinner.manager.showLoadingAnimation(delegate: self)
            DriverService.instance.editDriverPayoutDetails(accountData: bankAccount) {[weak self] payoutDetailsResponse in
                LoadingSpinner.manager.hideLoadingAnimation()
                if payoutDetailsResponse.isSuccess() {
                    let cancleAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel) { action in
                        self?.navigationController?.popViewController(animated: true)
                    }
                    AlertManager.showCustomAlertWith("Success", message: payoutDetailsResponse.msg ?? "Driver payout details updated successfully.", actions: [cancleAction])
                }else{
                    AlertManager.showErrorAlert(message: payoutDetailsResponse.msg ?? "Error while adding car")
                }
            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        } else {
            print("send update request")
        }
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
                self.selectedState = self.states[self.selectedStateRow]
                self.mail_stateTxtField.text = selectedState
                self.resetCity()
                self.fetchCities(for: self.selectedCountry, state: self.selectedState)
                mail_stateTxtField.resignFirstResponder()
            }
        }else if (self.currentPickerView.tag == 2) { // city
            if (cities.count != 0) {
                selectedCity = self.cities[self.selectedCityRow]
                self.mail_cityTxtField.text = selectedCity
                mail_cityTxtField.resignFirstResponder()
            }
        }else if (self.currentPickerView.tag == 4) { // country
            if (countries.count != 0) {
                selectedCountry = self.countries[self.selectedCountryRow]
                self.mail_countryTxtField.text = selectedCountry
                self.resetStateAndCity()
                self.fetchStates(for: self.selectedCountry)
                mail_countryTxtField.resignFirstResponder()
            }
        }
    }
    
    @objc func pickerCancelClicked(textField: UITextField) {
        print("resign first responder")
        mail_countryTxtField.resignFirstResponder()
        mail_stateTxtField.resignFirstResponder()
        mail_cityTxtField.resignFirstResponder()
    }
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueClicked(_ sender: Any) {
        guard let bankAccount = validateForm() else {
            return
        }
        driverRegistrationData.firstName_mail = mail_firstNameTxtField.text ?? ""
        driverRegistrationData.lastName_mail = mail_lastNameTxtField.text ?? ""
        driverRegistrationData.address_mail = mail_addressTxtField.text ?? ""
        driverRegistrationData.country_mail = mail_countryTxtField.text ?? ""
        driverRegistrationData.state_mail = mail_stateTxtField.text ?? ""
        driverRegistrationData.city_mail = mail_cityTxtField.text ?? ""
        driverRegistrationData.zipcode_mail = mail_zipcodeTxtField.text ?? ""
        driverRegistrationData.payout_type = "Mail"
    
        let sb = UIStoryboard(name: "Payment", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "AddPaymentViewController") as! AddPaymentViewController
        vcToOpen.driverRegistrationData = driverRegistrationData
        vcToOpen.physicalAddress = physicalAddressData
        vcToOpen.screenMode = CreditCardPaymentScreenMode.registerDriverCard
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    @IBAction func useDirectDeposit(_ sender: Any) {
//        let bankAccountPayoutDetails = BankAccount(bankname: "", name: "", account_number: "", routing_number: "", email: "", active: "", firstName: driverRegistrationData.firstName_mail, lastName: driverRegistrationData.lastName_mail, address: driverRegistrationData.address_mail, country: driverRegistrationData.country_mail, state: driverRegistrationData.state_mail, city: driverRegistrationData.city_mail, zipcode: driverRegistrationData.zipcode_mail)
        let sb = UIStoryboard(name: "Account", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "PayoutDetailsViewController") as! PayoutDetailsViewController
        vcToOpen.driverRegistrationData = driverRegistrationData
        vcToOpen.physicalAddressData = physicalAddressData
//        vcToOpen.payoutDetails = bankAccountPayoutDetails
        vcToOpen.screenMode = PayoutDetaisScreenMode.registerDriverPayoutDetails
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    private func validateForm() -> BankAccount? {
        
        
        guard let fname = self.mail_firstNameTxtField.text, !fname.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter first name under mailing address")
            return nil
        }

        guard let lname = self.mail_lastNameTxtField.text, !lname.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter last name under mailing address")
            return nil
        }
        
        guard let address = self.mail_addressTxtField.text, !address.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter mailing address")
            return nil
        }
        
        guard !self.selectedCountry.isEmpty else {
            AlertManager.showErrorAlert(message: "Please select mailing address - Country")
            return nil
        }
        
        guard !self.selectedState.isEmpty else {
            AlertManager.showErrorAlert(message: "Please select mailing address - State")
            return nil
        }
        
        guard !self.selectedCity.isEmpty else {
            AlertManager.showErrorAlert(message: "Please select mailing address - City")
            return nil
        }
        
        guard let zip = self.mail_zipcodeTxtField.text, !zip.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter physical address zip code")
            return nil
        }
        if (screenMode == .editMailingPayoutDetails) {
            return BankAccount(bankname: "", name: "", account_number: "", routing_number: "", email: "", active: "", firstName: fname, lastName: lname, address: address, country: self.selectedCountry, state: self.selectedState, city: self.selectedCity, zipcode: zip, payout_type: "")
        
        } else {
            return BankAccount(bankname: driverRegistrationData.bankname, name: driverRegistrationData.account_name, account_number: driverRegistrationData.account_number, routing_number: driverRegistrationData.routing_number, email: driverRegistrationData.emailId, active: "Yes", firstName: driverRegistrationData.firstName_mail, lastName: driverRegistrationData.lastName_mail, address: driverRegistrationData.address_mail, country: driverRegistrationData.country_mail, state: driverRegistrationData.state_mail, city: driverRegistrationData.city_mail, zipcode: driverRegistrationData.zipcode_mail, payout_type: "Direct")
        }
    }
    
    
}



extension MailingPayoutDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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

extension MailingPayoutDetailsViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case mail_stateTxtField:
//            if states.isEmpty {
//                showAlert(message: "Please enter a country first")
//                return false
//            }
            return true
        case mail_cityTxtField:
//            if cities.isEmpty {
//                showAlert(message: "Please select a state first")
//                return false
//            }
            return true
        case mail_countryTxtField:
            return true
        default:
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        if textField == mail_stateTxtField {
            if (self.states.count != 0) {
                setupPickerViewfor(mail_stateTxtField, tag: 1)
            } else {
                let cancleAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel) { action in
                    self.mail_stateTxtField.resignFirstResponder()
                }
                AlertManager.showCustomAlertWith("Information", message: "Sorry, currently we are not providing service in your Country!", actions: [cancleAction])
            }
        }
        if textField == mail_cityTxtField {
            if (self.cities.count != 0) {
                setupPickerViewfor(mail_cityTxtField, tag: 2)
            } else {
                let cancleAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel) { action in
                    self.mail_stateTxtField.resignFirstResponder()
                }
                AlertManager.showCustomAlertWith("Information", message: "Sorry, currently we are not providing service in your State!", actions: [cancleAction])
            }
        }
        if (textField == mail_countryTxtField) {
            setupPickerViewfor(mail_countryTxtField, tag: 4)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}


//struct State {
//    let name: String
//    let code: String
//}

//struct City {
//    let name: String
//    let code: String
//}

// MARK: - API Response Models
//struct StatesResponse: Codable {
//    let states: [StateData]
//}
//
//struct CitiesResponse: Codable {
//    let cities: [CityData]
//}
//
//struct StateData: Codable {
//    let name: String
//    let code: String
//}
//
//struct CityData: Codable {
//    let name: String
//    let code: String
//}


extension MailingPayoutDetailsViewController {
    
    // MARK: - Prefill
    private func prefillBillingDetails() {
//        self.mail_firstNameTxtField.isUserInteractionEnabled = false
//        self.mail_lastNameTxtField.isUserInteractionEnabled = false
//        self.mail_addressTxtField.isUserInteractionEnabled = false
//        self.mail_countryTxtField.isUserInteractionEnabled = false
//        self.mail_stateTxtField.isUserInteractionEnabled = false
//        self.mail_cityTxtField.isUserInteractionEnabled = false
//        self.mail_zipcodeTxtField.isUserInteractionEnabled = false
        self.mail_firstNameTxtField.text = physicalAddressData.firstName
        self.mail_lastNameTxtField.text = physicalAddressData.lastName
        self.mail_addressTxtField.text = physicalAddressData.address
        self.mail_countryTxtField.text = physicalAddressData.country
        self.selectedCountry = physicalAddressData.country
        self.mail_stateTxtField.text = physicalAddressData.state
        self.selectedState = physicalAddressData.state
        self.mail_cityTxtField.text = physicalAddressData.city
        self.selectedCity = physicalAddressData.city
        self.mail_zipcodeTxtField.text = physicalAddressData.zipcode
    }
    
    
    // MARK: - Setup
    private func setupTextFields() {
        mail_countryTxtField.delegate = self
        mail_stateTxtField.delegate = self
        mail_cityTxtField.delegate = self
        
        // Disable state and city fields initially
//        stateTxtField.isEnabled = false
//        cityTxtField.isEnabled = false
        
        // Add target for country text field changes
//        countryTxtField.addTarget(self, action: #selector(countryTextChanged), for: .editingChanged)
    }
    
    @objc private func fetchStatesForCountry() {
        guard let countryText = mail_countryTxtField.text, !countryText.isEmpty else { return }
        
        selectedCountry = countryText
        fetchStates(for: countryText)
    }
    
    private func resetStateAndCity() {
        mail_stateTxtField.text = ""
        mail_cityTxtField.text = ""
//        stateTxtField.isEnabled = false
//        cityTxtField.isEnabled = false
        states.removeAll()
        cities.removeAll()
        selectedState = ""
        selectedCity = ""
    }
    
    private func resetCity() {
        mail_cityTxtField.text = ""
//        cityTxtField.isEnabled = false
        cities.removeAll()
        selectedCity = ""
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
    
    func preloadAddressData(country: String, state: String) {
        if (!country.isEmpty) {
            self.fetchStates(for: country)
        }
        
        if (!country.isEmpty && !state.isEmpty) {
            self.fetchCities(for: country, state: state)
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


struct MailingPayoutDetailsData: Codable {
    var firstName:String
    var lastName:String
    var country:String
    var state:String
    var city:String
    var address:String
    var zipcode:String
}

