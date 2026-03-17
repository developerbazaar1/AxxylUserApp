//
//  ForgotPasswordViewController.swift
//  axxyl
//
//  Created by Mangesh Kondaskar on 19/09/22.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var headerView: NewHeaderView!
    @IBOutlet weak var email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerView.delegate = self
        self.headerView.setConfiguration()
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func requestNewPassword(_ sender: Any) {
        
        guard let emailId = self.email.text, !emailId.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter email")
            return
        }
        
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        LoginService.instance.forgotPassword(email: emailId) {[weak self] response in
            LoadingSpinner.manager.hideLoadingAnimation()
            
            if response.isSuccess() {
                AlertManager.showInfoAlert(message: response.msg)
                DispatchQueue.main.async {
                    self?.back(UIButton())
                }
            }else{
                AlertManager.showErrorAlert(message: response.msg)
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }

    }

}

extension ForgotPasswordViewController : NewHeaderViewProtocol {
    var headerTitle: String {
        return "Forgot Password"
    }
    
    func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    var isBackEnabled: Bool {
        return true
    }
}
