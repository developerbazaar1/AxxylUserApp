//
//  MailingAccountDetailsViewController.swift
//  Axxyl
//
//  Created by Mangesh on 12/8/25.
//

import UIKit

class MailingAccountDetailsViewController: UIViewController {

    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var zipcode: UILabel!
    
    var mailingDetails: BankAccount!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPayoutDetails()
    }
    

    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
   
     
    @IBAction func editButtonClicked(_ sender: Any) {
        let sb = UIStoryboard(name: "Account", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "MailingPayoutDetailsViewController") as! MailingPayoutDetailsViewController
        vcToOpen.payoutDetails = mailingDetails
        vcToOpen.screenMode = MailingPayoutDetaisScreenMode.editMailingPayoutDetails
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    func getPayoutDetails() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.getDriverPayoutDataDetails {[weak self] payoutDetailsResponse in
            LoadingSpinner.manager.hideLoadingAnimation()
            guard let weakSelf = self else { return }
            if (payoutDetailsResponse.isSuccess()){
                if let payoutArray = payoutDetailsResponse.PayoutDetails {
                    weakSelf.mailingDetails = payoutArray[0]
                }
                DispatchQueue.main.async {
                    self?.updateUI()
                }
            }else{
                AlertManager.showErrorAlert(message: payoutDetailsResponse.msg ?? "No Mailing details found.")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    func updateUI() {
        if mailingDetails != nil {
            firstName.text = mailingDetails.firstName
            lastName.text = mailingDetails.lastName
            address.text = mailingDetails.address
            country.text = mailingDetails.country
            state.text = mailingDetails.state
            city.text = mailingDetails.city
            zipcode.text = mailingDetails.zipcode
            
//            if accountDetails.email != "" {
//                accountHolderEmailId.text = accountDetails.email
//            } else {
//                emailStackView.isHidden = true
//               // detailsHeightConstraint.constant = 278
//            }
        } else {
            AlertManager.showErrorAlert(message:"No Mailing details found.")
        }
    }
    
}
