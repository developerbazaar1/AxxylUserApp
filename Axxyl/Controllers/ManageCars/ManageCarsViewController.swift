//
//  ManageCarsViewController.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 30/11/22.
//

import UIKit

class ManageCarsViewController: UIViewController {

    @IBOutlet weak var carsTableView: UITableView!
    @IBOutlet weak var headerView: NewHeaderView!
    
    var carItems: [DriverCar] = [] //[Car(number: "ABC-1234", color: "White", model: "Audi Q2", type: "AXS", wheelChairCapable: false, isSelected: false), Car(number: "XYZ-54321", color: "Red", model: "Honda City", type: "AXM", wheelChairCapable: true, isSelected: true), Car(number: "PQR-3214", color: "Blue", model: "Mercedes-Benz C Class", type: "AXM", wheelChairCapable: true, isSelected: false)];
    
    var selectedCarRow: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerView.delegate = self;
        self.headerView.setConfiguration()
        self.navigationController?.isNavigationBarHidden = true
        getCarList()
    }
    
    func getCarList() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.getDriverCarList { [weak self] driverCarsResponse in
            LoadingSpinner.manager.hideLoadingAnimation()
            guard let weakSelf = self else { return }
            if (driverCarsResponse.isSuccess()){
                weakSelf.carItems = driverCarsResponse.carDetails ?? []
                DispatchQueue.main.async {
                    weakSelf.carsTableView.reloadData()
                }
            }else{
                AlertManager.showErrorAlert(message: driverCarsResponse.msg ?? "Error while fetching car list")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    func selectDriverCar(car: DriverCar) {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.selectDriverCar(car: car) { [weak self] driverCarsResponse in
            LoadingSpinner.manager.hideLoadingAnimation()
            guard let weakSelf = self else { return }
            if (driverCarsResponse.isSuccess()){
                weakSelf.carItems = driverCarsResponse.carDetails ?? []
                DispatchQueue.main.async {
                    weakSelf.carsTableView.reloadData()
                }
            }else{
                AlertManager.showErrorAlert(message: driverCarsResponse.msg ?? "Error while fetching car list")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }

}

extension ManageCarsViewController : NewHeaderViewProtocol {
    var headerTitle: String {
        return "Manage Cars";
    }
    
    var isBackEnabled: Bool {
        return true
    }
    
    func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ManageCarsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carItems.count + 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == carItems.count {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AddCarCellIdentifier", for: indexPath) as? AddCarTableViewCell {
                return cell
            }
            
            return UITableViewCell()
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CarCellIdentifier", for: indexPath) as? CarTableViewCell {
                let car = carItems[indexPath.row]
                cell.carNameLbl.text = "\(DriverService.instance.getCarTypeFor(id: car.category_id)) - \(car.carModel)" //"\(car.type) - \(car.model)"
                cell.carColorLbl.text = "\(car.car_number) (\(car.carColor))"
                cell.carSelectRadioBtn.isChecked = car.isActive()
//                cell.carSelectRadioBtn.isChecked = false
//                if selectedCarRow == nil && car.isActive() {
//                    selectedCarRow = indexPath.row
//                }
//                if let selectedRow = selectedCarRow, selectedRow == indexPath.row {
//                    cell.carSelectRadioBtn.isChecked = true
//                }
                cell.editBtn.tag = indexPath.row
                cell.delegate = self
                return cell
            }
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == carItems.count {
            return 50
        } else {
            return 84
        }
    }
    
}

extension ManageCarsViewController : UITableViewDelegate, CarCellDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == carItems.count {
            print("Add New Car")
            let sb = UIStoryboard(name: "Signup", bundle: nil)
            let vcToOpen = sb.instantiateViewController(withIdentifier: "VehicleDetailsViewController") as! VehicleDetailsViewController
            vcToOpen.screenMode = VehicleScreenMode.AddCar
            vcToOpen.vehicleUpdateOrDeleteDelegate = self
            self.navigationController?.pushViewController(vcToOpen, animated: true)
            
        } else {
            let currentCell = tableView.cellForRow(at: indexPath) as! CarTableViewCell
            selectedCarRow = indexPath.row
            selectDriverCar(car: carItems[indexPath.row])
        }
    }
    
    func didTapEditButtonInCell(_ cell: CarTableViewCell) {
        print("Edit Car: \(String(describing: cell.carNameLbl.text))")
        let sb = UIStoryboard(name: "Signup", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "VehicleDetailsViewController") as! VehicleDetailsViewController
        vcToOpen.screenMode = VehicleScreenMode.EditCar
        vcToOpen.car = carItems[cell.editBtn.tag]
        vcToOpen.vehicleUpdateOrDeleteDelegate = self
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
}

extension ManageCarsViewController : VehicleUpdateOrDeleteProtocol {
    func VehicleUpdateOrDeleteSuccess(car: DriverCar, isDeleted: Bool) {
        if isDeleted {
            if let index = carItems.firstIndex(where: {$0.car_number == car.car_number})  {
                carItems.remove(at: index)
                if index < self.selectedCarRow ?? 0 {
                    self.selectedCarRow = self.selectedCarRow! - 1
                }
                self.carsTableView.reloadData()
            }
        } else {
            guard let index = carItems.firstIndex(where: {$0.car_number == car.car_number}) else {
                carItems.append(car)
                self.carsTableView.reloadData()
                return
            }
           
        }
    }
}
