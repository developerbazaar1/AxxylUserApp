//
//  PaymentViewController.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 25/09/22.
//

import UIKit

protocol CardEditProtocol : AnyObject {
    func editCardSuccess(cardDt : UserCard)
}

class AddPaymentViewController: UIViewController {

    weak var editDelegate : CardEditProtocol?
    @IBOutlet weak var cardNumberTxtField: UITextField!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var cardCVVTxtField: UITextField!
    @IBOutlet weak var cardHolderNameTxtField: UITextField!
    @IBOutlet weak var cancelPayment: GradientButton!
    @IBOutlet weak var savePayment: GradientButton!
    @IBOutlet weak var cardExpiryDateTxtField: UITextField!
    @IBOutlet weak var axxylFeeStackView: UIStackView!
    @IBOutlet weak var headerStepLblTxt: UILabel!
    @IBOutlet weak var editPaymentBtnStackView: UIStackView!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var addPaymentBtn: UIButton!
    @IBOutlet weak var onboardingButtonsStackView: UIStackView!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var addressTxtField: UITextField!
    @IBOutlet weak var countryTxtField: UITextField!
    @IBOutlet weak var stateTxtField: UITextField!
    @IBOutlet weak var cityTxtField: UITextField!
    @IBOutlet weak var zipcodeTxtField: UITextField!
    
    @IBOutlet weak var sameAddressCheckBox: CheckBoxButton!
    @IBOutlet weak var submitButtonTop: NSLayoutConstraint!
    
    //     MARK: - Properties
    private var countries: [String] = []
    private var states: [String] = []
    private var cities: [String] = []
    private var selectedCountry: String = ""
    private var selectedState: String = ""
    private var selectedCity: String = ""
    
    var userRegistrationData : UserRegistrationPayload!
    var driverRegistrationData : DriverRegistrationPayload!
    var physicalAddress : PhysicalAddressData!
    var card: UserCard!
    var isOnboarding:  Bool = false
    var screenMode: CreditCardPaymentScreenMode = CreditCardPaymentScreenMode.addCard
    var titleString = "Payment method"
    var updatedCardData : UserCard?
    var updatedCCDataWithBillingAddress : CrediCardWithBillingAddressData?
    var currentPickerView : UIPickerView!
    let months = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    var years : [String]?
    var selectedMonthRow = 0
    var selectedYearRow = 0
    var selectedStateRow = 0
    var selectedCountryRow = 0
    var selectedCityRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (isOnboarding){
            self.onboardingButtonsStackView.isHidden = false
            self.addPaymentBtn.isHidden = true
            self.backBtn.isHidden = true
        }else{
            self.onboardingButtonsStackView.isHidden = true
            self.addPaymentBtn.isHidden = false
            self.backBtn.isHidden = false
        }
        
        if screenMode == CreditCardPaymentScreenMode.registerPassangerCard || screenMode == CreditCardPaymentScreenMode.registerDriverCard {
            if physicalAddress == nil {
                guard let user = LoginService.instance.getCurrentUser() else {
                    return }
                
                physicalAddress = PhysicalAddressData(firstName: user.pa_firstName, lastName: user.pa_lastName, country: user.pa_country, state: user.pa_state, city: user.pa_city, address: user.pa_address, zipcode: user.pa_zipcode)
            }
            prefillBillingDetails()
        }
        
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
        self.headerLbl.text = titleString
        setupTextFields()
        fetchCountries()
        
        sameAddressCheckBox.addTarget(self, action: #selector(checkBoxTapped), for: .touchUpInside)
    }
    
    @objc func checkBoxTapped() {
        if let userType = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype), userType ==  UserType.passenger.rawValue {
            sameAddressCheckBox.isChecked.toggle()
            if sameAddressCheckBox.isChecked {
                prefillBillingDetails()
            } else {
                self.firstNameTxtField.isUserInteractionEnabled = true
                self.lastNameTxtField.isUserInteractionEnabled = true
                self.addressTxtField.isUserInteractionEnabled = true
                self.countryTxtField.isUserInteractionEnabled = true
                self.stateTxtField.isUserInteractionEnabled = true
                self.cityTxtField.isUserInteractionEnabled = true
                self.zipcodeTxtField.isUserInteractionEnabled = true
                self.firstNameTxtField.text = ""
                self.lastNameTxtField.text = ""
                self.addressTxtField.text = ""
                self.countryTxtField.text = ""
                self.stateTxtField.text = ""
                self.cityTxtField.text = ""
                self.zipcodeTxtField.text = ""
            }
        } else {
            prefillBillingDetails()
            AlertManager.showInfoAlert(message: "Sorry, you can not modify billing address. Your billing address should be same as physical address.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getYearsData()
        updateScreen()
    }
    
    func updateScreen() {
        self.headerStepLblTxt.isHidden = true
        self.axxylFeeStackView.isHidden = true
        switch screenMode {
        case .addCard:
            self.cancelPayment.setTitle("Cancel", for: .normal)
            self.savePayment.setTitle("Save", for: .normal)
            self.onboardingButtonsStackView.isHidden = false
            self.addPaymentBtn.isHidden = true
            self.backBtn.isHidden = false
            guard let user = LoginService.instance.getCurrentUser() else {
                return }
            physicalAddress = PhysicalAddressData(firstName: user.pa_firstName, lastName: user.pa_lastName, country: user.pa_country, state: user.pa_state, city: user.pa_city, address: user.pa_address, zipcode: user.pa_zipcode)
            prefillBillingDetails()
        case .editCard:
            self.cancelPayment.setTitle("Cancel", for: .normal)
            self.savePayment.setTitle("Save", for: .normal)
            if (card != nil) { // Edit Mode
                cardNumberTxtField.text = card.cardnum;
                cardHolderNameTxtField.text = card.cardname
                cardExpiryDateTxtField.text = "\(card.cardexpmonth)/\(card.cardexpyear)"
                selectedMonthRow = months.firstIndex(of: card.cardexpmonth) ?? 0
                selectedYearRow = years?.firstIndex(of: card.cardexpyear) ?? 0
                cardCVVTxtField.text = ""
                
                self.countryTxtField.text = card.country
                self.stateTxtField.text = card.state
                self.cityTxtField.text = card.city
                self.zipcodeTxtField.text = card.zipcode
                self.addressTxtField.text = card.address
                
                self.editPaymentBtnStackView.isHidden = false
                self.backBtn.isHidden = true
                self.onboardingButtonsStackView.isHidden = true
                self.addPaymentBtn.isHidden = true
                self.view.layoutIfNeeded()
                
                self.preloadEditCardInfo(country: card.country, state: card.state)
            }

        case .registerPassangerCard:
            self.onboardingButtonsStackView.isHidden = false
            self.addPaymentBtn.isHidden = true
            self.backBtn.isHidden = false // to go back, as UX never showed up on updated sceeens as discusssed long back ago
        //    self.submitButtonTop.constant = 10
            if physicalAddress == nil {
                guard let user = LoginService.instance.getCurrentUser() else {
                    return }
                physicalAddress = PhysicalAddressData(firstName: user.pa_firstName, lastName: user.pa_lastName, country: user.pa_country, state: user.pa_state, city: user.pa_city, address: user.pa_address, zipcode: user.pa_zipcode)
            }
            prefillBillingDetails()
            
        case .registerDriverCard:
            self.backBtn.isHidden = false // to go back, as UX never showed up on updated sceeens as discusssed long back ago
            self.onboardingButtonsStackView.isHidden = true
            self.headerLbl.text = "Credit Card Details"
            self.headerStepLblTxt.isHidden = false
            self.addPaymentBtn.setTitle("Submit", for: .normal)
            self.addPaymentBtn.isHidden = false
         //   self.submitButtonTop.constant = self.axxylFeeStackView.frame.height + 40
            self.axxylFeeStackView.isHidden = true
            if physicalAddress == nil {
                guard let user = LoginService.instance.getCurrentUser() else {
                    return }
                physicalAddress = PhysicalAddressData(firstName: user.pa_firstName, lastName: user.pa_lastName, country: user.pa_country, state: user.pa_state, city: user.pa_city, address: user.pa_address, zipcode: user.pa_zipcode)
            }
            prefillBillingDetails()
            
        case .addPaymentMethod:
            self.onboardingButtonsStackView.isHidden = true
            self.addPaymentBtn.isHidden = false
            self.backBtn.isHidden = true
        }
    }
    
    
    func preloadEditCardInfo(country: String, state: String) {
        if (!country.isEmpty) {
            self.fetchStates(for: country)
        }
        
        if (!country.isEmpty && !state.isEmpty) {
            self.fetchCities(for: country, state: state)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func expiryDateInfoBtn(_ sender: Any) {
        AlertManager.showInfoAlert(message: "Please enter expiry date mentioned on your card")
    }
    
    @IBAction func cvvInfoBtn(_ sender: Any) {
        AlertManager.showInfoAlert(message: "Please enter CVV number mentioned on the back side of your card")
    }
    
    @IBAction func skipStepBtn(_ sender: Any) {
        if screenMode == CreditCardPaymentScreenMode.registerPassangerCard {
            self.userRegistrationData.cardcvv = ""
            self.userRegistrationData.cardnum = ""
            self.userRegistrationData.cardname = ""
            self.userRegistrationData.cardexpyear = ""
            self.userRegistrationData.cardexpmonth = ""
  //          self.sendRegistrationRequest()
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func addPaymentBtnPressed(_ sender: Any) {
        guard let cardDataWithBA = validateBillingAddress() else {
            return
        }
        
//        guard let cardData = validateForm() else {
//            return
//        }
//        
        if screenMode == CreditCardPaymentScreenMode.registerDriverCard {
            self.driverRegistrationData.cardcvv = cardDataWithBA.card_code
            self.driverRegistrationData.cardnum = cardDataWithBA.card_number
            self.driverRegistrationData.cardname = self.cardHolderNameTxtField.text ?? ""
            let expiration_date = cardDataWithBA.expiration_date.split(separator: "-")
            self.driverRegistrationData.cardexpyear = String(expiration_date[1])
            self.driverRegistrationData.cardexpmonth = String(expiration_date[0])
            self.driverRegistrationData.fName = cardDataWithBA.firstName
            self.driverRegistrationData.lName = cardDataWithBA.lastName
            self.driverRegistrationData.address = cardDataWithBA.address
            self.driverRegistrationData.country = cardDataWithBA.country
            self.driverRegistrationData.state = cardDataWithBA.state
            self.driverRegistrationData.city = cardDataWithBA.city
            self.driverRegistrationData.zipcode = cardDataWithBA.zipcode
            self.sendRegistrationRequest()
        } else {
            LoadingSpinner.manager.showLoadingAnimation(delegate: self)
            LoginService.instance.addPaymentMethod(cardData: cardDataWithBA, name: self.cardHolderNameTxtField.text ?? "") {[weak self] cardResponse in
                LoadingSpinner.manager.hideLoadingAnimation()
                if cardResponse.isSuccess() {
//                    self?.updatedCardData = cardData
                    self?.updatedCCDataWithBillingAddress = cardDataWithBA
                    self?.navigateBack()
                }else{
                    AlertManager.showErrorAlert(message: cardResponse.msg ?? "Error while adding payment method")
                }
            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        }
    }
    
    func loadHome() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            appDelegate.loadHome()
        }
    }
    
    func loadLanding() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            appDelegate.loadLanding()
        }
    }
    
    func getYearsData() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let endYear = currentYear + 10;
        years = (currentYear...endYear).map { String($0) }
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
                self.stateTxtField.text = selectedState
                self.resetCity()
                self.fetchCities(for: self.selectedCountry, state: self.selectedState)
                stateTxtField.resignFirstResponder()
            }
        }else if (self.currentPickerView.tag == 2) { // city
            if (cities.count != 0) {
                selectedCity = self.cities[self.selectedCityRow]
                self.cityTxtField.text = selectedCity
                cityTxtField.resignFirstResponder()
            }
        }else if (self.currentPickerView.tag == 3) {
            cardExpiryDateTxtField.resignFirstResponder()
        }else if (self.currentPickerView.tag == 4) { // country
            if (countries.count != 0) {
                selectedCountry = self.countries[self.selectedCountryRow]
                self.countryTxtField.text = selectedCountry
                self.resetStateAndCity()
                self.fetchStates(for: self.selectedCountry)
                countryTxtField.resignFirstResponder()
            }
        }
    }
    
    @objc func pickerCancelClicked(textField: UITextField) {
        print("resign first responder")
        cardExpiryDateTxtField.resignFirstResponder()
        countryTxtField.resignFirstResponder()
        stateTxtField.resignFirstResponder()
        cityTxtField.resignFirstResponder()
    }
    
    
    func sendRegistrationRequest() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        if let userType = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype), userType ==  UserType.passenger.rawValue {
//        if LoginService.instance.currentUserType ==  UserType.passenger {
            print("")
            LoginService.instance.registerNewUser(data: userRegistrationData) {[weak self] signupResponse in
                LoadingSpinner.manager.hideLoadingAnimation()
                if signupResponse.isSuccess() {
                    LoginService.instance.setCurrentUser(user: signupResponse.user)
                    self?.loadHome()
                }else{
                    AlertManager.showErrorAlert(message: signupResponse.msg)
                }
            } errorCallBack: { errMg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMg)
            }
        } else {
            DriverService.instance.registerNewUser(data: driverRegistrationData) {[weak self] signupResponse in
                LoadingSpinner.manager.hideLoadingAnimation()
                if signupResponse.isSuccess() {
                    if signupResponse.user != nil{
                        LoginService.instance.setCurrentUser(user: signupResponse.user)
                        self?.loadHome()
                    } else {
                        let cancleAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel) { action in
                            self?.loadLanding()
                        }
                        AlertManager.showCustomAlertWith("Information", message: "Registration has been successful.\("\n")Please wait for admin approval.", actions: [cancleAction])
                    }
                   
                }else{
                    AlertManager.showErrorAlert(message: signupResponse.msg)
                }
            } errorCallBack: { errMg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMg)
            }
        }
    }
    
    func getUserCardUpdated() -> UserCard? {
        guard let cardData = self.updatedCCDataWithBillingAddress else { return nil }
        
        let expiration_date = cardData.expiration_date.split(separator: "-")
        
        return UserCard(cardname: cardData.name, cardnum: cardData.card_number, cardcvv: cardData.card_code, cardexpmonth: String(expiration_date[1]), cardexpyear: String(expiration_date[0]), firstName: cardData.firstName, lastName: cardData.lastName, country: cardData.country, state: cardData.state, city: cardData.city, address: cardData.address, zipcode: cardData.zipcode, active: "yes")
    }
    
    func navigateBack() {
        
        if editDelegate != nil {
            editDelegate?.editCardSuccess(cardDt: getUserCardUpdated()!)
        }
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    
    @IBAction func updatePaymentMethodBtnPressed(_ sender: Any) {
        if let cardData = validateBillingAddress() {
            
            let expiration_date = cardData.expiration_date.split(separator: "-")
            
            LoadingSpinner.manager.showLoadingAnimation(delegate: self)
            let userUdpatedCard = UserCard(cardname: cardData.name, cardnum: cardData.card_number, cardcvv: cardData.card_code, cardexpmonth: String(expiration_date[1]), cardexpyear: String(expiration_date[0]), firstName: cardData.firstName, lastName: cardData.lastName, country: cardData.country, state: cardData.state, city: cardData.city, address: cardData.address, zipcode: cardData.zipcode, active: "yes")
            
            LoginService.instance.updatePaymentMethod(cardData: userUdpatedCard, oldCardNum: card.cardnum) {[weak self] cardResponse in
                LoadingSpinner.manager.hideLoadingAnimation()
                if cardResponse.isSuccess() {
//                    self?.updatedCardData = cardData
                    self?.updatedCCDataWithBillingAddress = cardData
                    self?.navigateBack()
                }else{
                    AlertManager.showErrorAlert(message: cardResponse.msg ?? "Error while updating payment method")
                }
            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        }
    }
    
    
    @IBAction func onSameAddressCheckBoxClicked(_ sender: Any) {
        
    }
    
    
    // save card details - save button action
    @IBAction func submitBtn(_ sender: Any) {
        if let cardData = validateBillingAddress() {
            if screenMode == CreditCardPaymentScreenMode.registerPassangerCard {
                self.userRegistrationData.cardcvv = cardData.card_code
                self.userRegistrationData.cardnum = cardData.card_number
                self.userRegistrationData.cardname = self.cardHolderNameTxtField.text ?? (cardData.firstName + " " + cardData.lastName)
                let expiryDate = cardData.expiration_date.split(separator: "-")
                self.userRegistrationData.cardexpyear = String(expiryDate[0])
                self.userRegistrationData.cardexpmonth = String(expiryDate[1])
                self.userRegistrationData.fName = cardData.firstName
                self.userRegistrationData.lName = cardData.lastName
                self.userRegistrationData.address = cardData.address
                self.userRegistrationData.country = cardData.country
                self.userRegistrationData.state = cardData.state
                self.userRegistrationData.city = cardData.city
                self.userRegistrationData.zipcode = cardData.zipcode
                self.userRegistrationData.user_address = physicalAddress.address
                self.userRegistrationData.user_country = physicalAddress.country
                self.userRegistrationData.user_state = physicalAddress.state
                self.userRegistrationData.user_city = physicalAddress.city
                self.userRegistrationData.user_zipcode = physicalAddress.zipcode
                self.sendRegistrationRequest()
            } else {
                LoadingSpinner.manager.showLoadingAnimation(delegate: self)
                
                LoginService.instance.validateCreditCard(cardData: cardData) {[weak self, weak instance = LoginService.instance] validationResponse in
                    if (validationResponse) {
                        instance?.addPaymentMethod(cardData: cardData, name: self?.cardHolderNameTxtField.text ?? "") {[weak self] cardResponse in
                            LoadingSpinner.manager.hideLoadingAnimation()
                            if cardResponse.isSuccess() {
                                self?.updatedCCDataWithBillingAddress = cardData
                                self?.navigateBack()
                            }else{
                                AlertManager.showErrorAlert(message: cardResponse.msg ?? "Error while adding payment method")
                            }
                        } errorCallBack: { errMsg in
                            LoadingSpinner.manager.hideLoadingAnimation()
                            AlertManager.showErrorAlert(message: errMsg)
                        }
                    }else{
                        LoadingSpinner.manager.hideLoadingAnimation()
                        AlertManager.showErrorAlert(message: "Invalid card data")
                    }
                    
                } errorCallBack: { errMsg in
                    LoadingSpinner.manager.hideLoadingAnimation()
                    AlertManager.showErrorAlert(message: errMsg)
                }
                
            }
        }
    }
    
    private func validateBillingAddress() -> CrediCardWithBillingAddressData? {
        
        guard let name = self.cardHolderNameTxtField.text, !name.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter card holder name")
            return nil
        }
        
        guard let cardNumber = self.cardNumberTxtField.text, !cardNumber.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter card number mention on the front side of your card")
            return nil
        }
        
        guard let expiryDt = self.cardExpiryDateTxtField.text, !expiryDt.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter expiry month and year")
            return nil
        }
        
        guard let cvv = self.cardCVVTxtField.text, !cvv.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter cvv")
            return nil
        }
        
        guard let fname = self.firstNameTxtField.text, !fname.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter card holder first name")
            return nil
        }
        
        guard let lname = self.lastNameTxtField.text, !lname.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter card holder last name")
            return nil
        }
        
        guard let address = self.addressTxtField.text, !address.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter billing address")
            return nil
        }
        
        guard !self.selectedCountry.isEmpty else {
            AlertManager.showErrorAlert(message: "Please select billing address - Country")
            return nil
        }
        
        guard !self.selectedState.isEmpty else {
            AlertManager.showErrorAlert(message: "Please select billing address - State")
            return nil
        }
        
        guard !self.selectedCity.isEmpty else {
            AlertManager.showErrorAlert(message: "Please select billing address - City")
            return nil
        }
        
        guard let zip = self.zipcodeTxtField.text, !zip.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter billing address zip code")
            return nil
        }
        
        if let userType = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype), userType ==  UserType.driver.rawValue {
            if !sameAddressCheckBox.isChecked {
                AlertManager.showInfoAlert(message: "Your billing address should be same as physical address.")
                return nil
            }
            
            let nameOnCard = "\(fname) \(lname)";
            
            if (name.uppercased() != nameOnCard.uppercased()) {
                AlertManager.showErrorAlert(message: "Card holder name should match with physical address and billing address name \(nameOnCard)")
                return nil
            }
        }
        
        let expiryData = expiryDt.components(separatedBy: "/")
        
        let finalExpiry = expiryData[1] + "-" + expiryData[0]
        
        let cardData = CrediCardWithBillingAddressData(name: name, firstName: fname, lastName: lname, country: selectedCountry, state: selectedState, city: selectedCity, address: address, zipcode: zip, card_number: cardNumber, card_code: cvv, expiration_date: finalExpiry)
        return cardData
    }
}

extension AddPaymentViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerView.tag == 3 ? 2 : 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1: // State picker
            return states.count
        case 2: // City picker
            return cities.count
        case 3: // Expiry date picker
            return component == 0 ? months.count : years?.count ?? 0
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
        case 3: // expirty date picker
            return component == 0 ? months[row] : years?[row] ?? ""
        case 4: // country picker
            return row < countries.count ? countries[row] : nil
        default:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 3: // expiry date picker
            if component == 0 {
                self.selectedMonthRow = row
            } else if component == 1 {
                self.selectedYearRow = row
            }
            
            cardExpiryDateTxtField.text = "\(months[selectedMonthRow])/\(years![selectedYearRow])"
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

extension AddPaymentViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case stateTxtField:
//            if states.isEmpty {
//                showAlert(message: "Please enter a country first")
//                return false
//            }
            return true
        case cityTxtField:
//            if cities.isEmpty {
//                showAlert(message: "Please select a state first")
//                return false
//            }
            return true
        case countryTxtField:
            return true
        default:
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == cardExpiryDateTxtField {
            setupPickerViewfor(cardExpiryDateTxtField, tag: 3)
        }
        if textField == stateTxtField {
            if (self.states.count != 0) {
                setupPickerViewfor(stateTxtField, tag: 1)
            } else {
                let cancleAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel) { action in
                    self.stateTxtField.resignFirstResponder()
                }
                AlertManager.showCustomAlertWith("Information", message: "Sorry, currently we are not providing service in your Country!", actions: [cancleAction])
            }
        }
        if textField == cityTxtField {
            if (self.cities.count != 0) {
                setupPickerViewfor(cityTxtField, tag: 2)
            } else {
                let cancleAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel) { action in
                    self.stateTxtField.resignFirstResponder()
                }
                AlertManager.showCustomAlertWith("Information", message: "Sorry, currently we are not providing service in your State!", actions: [cancleAction])
            }
        }
        if (textField == countryTxtField) {
            setupPickerViewfor(countryTxtField, tag: 4)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == cardExpiryDateTxtField {
            cardExpiryDateTxtField.text = "\(String(months[selectedMonthRow]))/\(String(years![selectedYearRow]))"
            return false
        }
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
struct StatesResponse: Codable {
    let states: [StateData]
}

struct CitiesResponse: Codable {
    let cities: [CityData]
}

struct StateData: Codable {
    let name: String
    let code: String
}

struct CityData: Codable {
    let name: String
    let code: String
}


extension AddPaymentViewController {
    
    // MARK: - Prefill
    private func prefillBillingDetails() {
        self.firstNameTxtField.isUserInteractionEnabled = false
        self.lastNameTxtField.isUserInteractionEnabled = false
        self.addressTxtField.isUserInteractionEnabled = false
        self.countryTxtField.isUserInteractionEnabled = false
        self.stateTxtField.isUserInteractionEnabled = false
        self.cityTxtField.isUserInteractionEnabled = false
        self.zipcodeTxtField.isUserInteractionEnabled = false
        self.firstNameTxtField.text = physicalAddress.firstName
        self.lastNameTxtField.text = physicalAddress.lastName
        self.addressTxtField.text = physicalAddress.address
        self.countryTxtField.text = physicalAddress.country
        self.selectedCountry = physicalAddress.country
        self.stateTxtField.text = physicalAddress.state
        self.selectedState = physicalAddress.state
        self.cityTxtField.text = physicalAddress.city
        self.selectedCity = physicalAddress.city
        self.zipcodeTxtField.text = physicalAddress.zipcode
    }
    
    
    // MARK: - Setup
    private func setupTextFields() {
        countryTxtField.delegate = self
        stateTxtField.delegate = self
        cityTxtField.delegate = self
        
        // Disable state and city fields initially
//        stateTxtField.isEnabled = false
//        cityTxtField.isEnabled = false
        
        // Add target for country text field changes
//        countryTxtField.addTarget(self, action: #selector(countryTextChanged), for: .editingChanged)
    }
    
    @objc private func fetchStatesForCountry() {
        guard let countryText = countryTxtField.text, !countryText.isEmpty else { return }
        
        selectedCountry = countryText
        fetchStates(for: countryText)
    }
    
    private func resetStateAndCity() {
        stateTxtField.text = ""
        cityTxtField.text = ""
//        stateTxtField.isEnabled = false
//        cityTxtField.isEnabled = false
        states.removeAll()
        cities.removeAll()
        selectedState = ""
        selectedCity = ""
    }
    
    private func resetCity() {
        cityTxtField.text = ""
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


struct AddressCountryPayload : Encodable {
    var action:String = "countryData"
    var country:String
    var state:String
    var city:String
}

struct CrediCardWithBillingAddressData: Codable {
    var name: String
    var firstName:String
    var lastName:String
    var country:String
    
    var state:String
    var city:String
    var address:String
    
    var zipcode:String
    var card_number:String
    var card_code:String
    var expiration_date: String
}

struct StateResponse: Codable {
    let status: String
    let data: [String]
}
