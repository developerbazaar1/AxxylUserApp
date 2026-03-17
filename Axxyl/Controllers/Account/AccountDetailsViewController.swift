//
//  AccountDetailsViewController.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 24/01/23.
//

import UIKit

class AccountDetailsViewController: UIViewController {

    @IBOutlet weak var accountHolderName: UILabel!
    @IBOutlet weak var bankName: UILabel!
    @IBOutlet weak var routingNumber: UILabel!
    @IBOutlet weak var accountNumber: UILabel!
    @IBOutlet weak var accountHolderEmailId: UILabel!
    
    @IBOutlet weak var detailsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailStackView: UIStackView!
    var accountDetails: BankAccount!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPayoutDetails()
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editPayoutDetails(_ sender: Any) {
        let sb = UIStoryboard(name: "Account", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "PayoutDetailsViewController") as! PayoutDetailsViewController
        vcToOpen.payoutDetails = accountDetails
        vcToOpen.screenMode = PayoutDetaisScreenMode.editPayoutDetails
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    func getPayoutDetails() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.getDriverPayoutDataDetails {[weak self] payoutDetailsResponse in
            LoadingSpinner.manager.hideLoadingAnimation()
            guard let weakSelf = self else { return }
            if (payoutDetailsResponse.isSuccess()){
                if let payoutArray = payoutDetailsResponse.PayoutDetails {
                    weakSelf.accountDetails = payoutArray[0]
                }
                DispatchQueue.main.async {
                    self?.updateUI()
                }
            }else{
                AlertManager.showErrorAlert(message: payoutDetailsResponse.msg ?? "No payout details found.")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    func updateUI() {
        if accountDetails != nil {
            accountHolderName.text = accountDetails.name
            accountNumber.text = accountDetails.account_number
            bankName.text = accountDetails.bankname
            routingNumber.text = accountDetails.routing_number
            
            if accountDetails.email != "" {
                accountHolderEmailId.text = accountDetails.email
            } else {
                emailStackView.isHidden = true
               // detailsHeightConstraint.constant = 278
            }
        } else {
            AlertManager.showErrorAlert(message:"No payout details found.")
        }
    }
}
