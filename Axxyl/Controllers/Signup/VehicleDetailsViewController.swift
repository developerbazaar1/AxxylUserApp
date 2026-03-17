//
//  VehicleDetailsViewController.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 02/10/22.
//

import UIKit

protocol VehicleUpdateOrDeleteProtocol : AnyObject {
    func VehicleUpdateOrDeleteSuccess(car : DriverCar, isDeleted: Bool)
}

class VehicleDetailsViewController: UIViewController {

    @IBOutlet weak var plateNumberTxtFld: UITextField!
    @IBOutlet weak var vehileColorTxtFld: UITextField!
    @IBOutlet weak var vehicleModelTxtFld: UITextField!
    @IBOutlet weak var carTypeTxtFld: PickerTextField!
    @IBOutlet weak var wheelchairFacilityCBBtn: CheckBoxButton!
    @IBOutlet weak var submitReqBtn: UIButton!
    @IBOutlet weak var registerCarFlowHeader: UIView!
    @IBOutlet weak var editCarHeader: UIView!
    @IBOutlet weak var addCarHeader: NewHeaderView!
    @IBOutlet weak var manageCarStackView: UIView!
    @IBOutlet weak var continueBtn: UIButton!
    
    var screenMode: VehicleScreenMode = VehicleScreenMode.AddCar
    var car: DriverCar?
    var carTypePickerView : UIPickerView!
    var carTypes : [CarType]?
    weak var vehicleUpdateOrDeleteDelegate : VehicleUpdateOrDeleteProtocol?
    //var carTypeData = ["AXS", "AXL", "AXM", "AXC"]
    
    var driverRegistrationData : DriverRegistrationPayload!
    var physicalAddressData : PhysicalAddressData!
    var card: UserCard!
    //svar isOnboarding:  Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCarHeader.delegate = self;
        addCarHeader.setConfiguration()
        getCarTypes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateScreen()
    }
    
    func updateScreen() {
        plateNumberTxtFld.isEnabled = true
        vehicleModelTxtFld.isEnabled = true
        carTypeTxtFld.isEnabled = true
        
        switch screenMode {
        case .AddCar:
            addCarHeader.isHidden = false
            submitReqBtn.setTitle("Add Car", for: .normal)
            manageCarStackView.isHidden = false
            
        case .EditCar:
            editCarHeader.isHidden = false
            submitReqBtn.setTitle("Save Changes", for: .normal)
            manageCarStackView.isHidden = false
            plateNumberTxtFld.isEnabled = false
            vehicleModelTxtFld.isEnabled = false
            carTypeTxtFld.isEnabled = false
            if car != nil {
                plateNumberTxtFld.text = car?.car_number
                vehileColorTxtFld.text = car?.carColor
                vehicleModelTxtFld.text = car?.carModel
                carTypeTxtFld.text = DriverService.instance.getCarTypeFor(id: car?.category_id ?? "")
            }

        case .RegisterCar:
            registerCarFlowHeader.isHidden = false
            continueBtn.isHidden = false

        }
    }
    
    func setupPickerViewfor(_ textField : UITextField){

       carTypePickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        carTypePickerView.delegate = self
        carTypePickerView.dataSource = self
        carTypePickerView.backgroundColor = UIColor.white
        carTypeTxtFld.inputView = carTypePickerView

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
        carTypeTxtFld.inputAccessoryView = toolBar

    }
    
    @objc func pickerDoneClicked() {
        carTypeTxtFld.resignFirstResponder()
    }
    
    @objc func pickerCancelClicked() {
        carTypeTxtFld.resignFirstResponder()
    }
    
    @IBAction func wheelChairCBPressed(_ sender: CheckBoxButton) {
        sender.isChecked = !(sender as AnyObject).isChecked
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
     @IBAction func continueButtonClicked(_ sender: Any) {
         guard let car = validateForm() else {
             return
         }
         driverRegistrationData.car_number = car.number
         driverRegistrationData.carColor = car.color
         driverRegistrationData.carModel = car.model
         driverRegistrationData.handicapped = car.wheelChairCapable
         driverRegistrationData.carTypeId = DriverService.instance.getCarTypeIdFor(carType: car.type)
         driverRegistrationData.carType = car.type

         let sb = UIStoryboard(name: "Document", bundle: nil)
         let vcToOpen = sb.instantiateViewController(withIdentifier: "DriverDocumentsViewController") as! DriverDocumentsViewController
         vcToOpen.driverRegistrationData = driverRegistrationData
         vcToOpen.physicalAddressData = physicalAddressData
         vcToOpen.screenMode = DocumentsUploadScreenMode.signupMode
         self.navigationController?.pushViewController(vcToOpen, animated: true)
         /* for time being flow as changed */
         
         // TODO: Chnaged from payout to mailing
//         let sb = UIStoryboard(name: "Account", bundle: nil)
//         let vcToOpen = sb.instantiateViewController(withIdentifier: "PayoutDetailsViewController") as! PayoutDetailsViewController
//         vcToOpen.driverRegistrationData = driverRegistrationData
//         vcToOpen.physicalAddressData = physicalAddressData
//         vcToOpen.screenMode = PayoutDetaisScreenMode.registerDriverPayoutDetails
//         let sb = UIStoryboard(name: "Account", bundle: nil)
//         let vcToOpen = sb.instantiateViewController(withIdentifier: "MailingPayoutDetailsViewController") as! MailingPayoutDetailsViewController
//         vcToOpen.driverRegistrationData = driverRegistrationData
//         vcToOpen.physicalAddressData = physicalAddressData
//         vcToOpen.screenMode = MailingPayoutDetaisScreenMode.registerDriverMailingPayoutDetails
//         self.navigationController?.pushViewController(vcToOpen, animated: true)
    }

    @IBAction func addOrSaveButtonClicked(_ sender: Any) {
        if let car = validateForm() {
            if screenMode == VehicleScreenMode.AddCar {
                LoadingSpinner.manager.showLoadingAnimation(delegate: self)
                DriverService.instance.addDriverCar(cardata: car) {[weak self] addCarResponse in
                    LoadingSpinner.manager.hideLoadingAnimation()
                    if addCarResponse.isSuccess() {
                        self?.car = DriverCar(category_id: DriverService.instance.getCarTypeIdFor(carType: car.type), car_number: car.number, carColor: car.color, carModel: car.model, active: "0")
                        self?.navigateBack(isDeleted: false) 
                        //self?.navigationController?.popViewController(animated: true)
                    }else{
                        AlertManager.showErrorAlert(message: addCarResponse.msg ?? "Error while adding car")
                    }
                } errorCallBack: { errMsg in
                    LoadingSpinner.manager.hideLoadingAnimation()
                    AlertManager.showErrorAlert(message: errMsg)
                }
            } else {
                LoadingSpinner.manager.showLoadingAnimation(delegate: self)
                DriverService.instance.addDriverCar(cardata: car) {[weak self] addCarResponse in
                    LoadingSpinner.manager.hideLoadingAnimation()
                    if addCarResponse.isSuccess() {
                        self?.navigationController?.popViewController(animated: true)
                    }else{
                        AlertManager.showErrorAlert(message: addCarResponse.msg ?? "Error while adding car")
                    }
                } errorCallBack: { errMsg in
                    LoadingSpinner.manager.hideLoadingAnimation()
                    AlertManager.showErrorAlert(message: errMsg)
                }
            }
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteCarBtnClicked(_ sender: Any) {
        
        let actionMenu = UIAlertController(title: "Are you sure you want to delete the card?", message: "You will not able to use this car for your upcoming rides unless you add it again in app.", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Yes, Delete", style: .destructive, handler: { (UIAlertAction) in
            self.deleteCar()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (UIAlertAction) in
            print("Cancel clicked")
        })
        
        actionMenu.addAction(cancelAction)
        actionMenu.addAction(deleteAction)
        
        self.present(actionMenu, animated: true, completion: nil)
    }
    
    func deleteCar() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.deleteDriverCar(car: car!) {[weak self] deleteCarResponse in
            LoadingSpinner.manager.hideLoadingAnimation()
            if deleteCarResponse.isSuccess() {
                let cancleAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel) { action in
                    self?.navigateBack(isDeleted: true)
                    //self?.navigationController?.popViewController(animated: true)
                }
                AlertManager.showCustomAlertWith("Success", message: deleteCarResponse.msg ?? "User's Car Deleted Successfully.", actions: [cancleAction])
            }else{
                AlertManager.showErrorAlert(message: deleteCarResponse.msg ?? "Error while deleting car")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    private func validateForm() -> Car? {
        guard let plateNumber_ = self.plateNumberTxtFld.text, !plateNumber_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter vehicle plate number")
            return nil
        }

        guard let vehicleColor_ = self.vehileColorTxtFld.text, !vehicleColor_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter vehicle color")
            return nil
        }

        guard let vehicleModel_ = self.vehicleModelTxtFld.text, !vehicleModel_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter vehicle model")
            return nil
        }

        guard let carType_ = self.carTypeTxtFld.text, !carType_.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter car type")
            return nil
        }
        
        let car = Car(number: plateNumber_, color: vehicleColor_, model: vehicleModel_, type: carType_, wheelChairCapable: wheelchairFacilityCBBtn.isChecked, isSelected: false)
        return car
    }
    
    func navigateBack(isDeleted: Bool) {
        
        if vehicleUpdateOrDeleteDelegate != nil {
            vehicleUpdateOrDeleteDelegate?.VehicleUpdateOrDeleteSuccess(car: car!, isDeleted: isDeleted)
        }
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func getCarTypes() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.getCarType { [weak self] carTypeResponse in
            LoadingSpinner.manager.hideLoadingAnimation()
            guard let weakSelf = self else { return }
            if (carTypeResponse.isSuccess()){
                weakSelf.carTypes = carTypeResponse.carType
//                DispatchQueue.main.async {
//                    weakSelf.carTypePickerView.reloadAllComponents()
//                }
            }else{
                AlertManager.showErrorAlert(message: carTypeResponse.msg)
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
}

extension VehicleDetailsViewController : NewHeaderViewProtocol {
    var headerTitle: String {
        return "Add Car"
    }
    
    var isBackEnabled: Bool {
        return true
    }
    
    func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension VehicleDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return carTypes?.count ?? 0//carTypeData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return carTypes?[row].name //carTypeData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        carTypeTxtFld.text = carTypes?[row].name
    }
}

extension VehicleDetailsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == carTypeTxtFld {
            setupPickerViewfor(carTypeTxtFld)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
