//
//  ChangePasswordViewController.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 01/10/22.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var submitBtn: GradientButton!
    
    @IBOutlet weak var headerView: NewHeaderView!
    @IBOutlet weak var reEnterNewPasswordTxtField: UITextField!
    @IBOutlet weak var newPasswordTxtField: UITextField!
    @IBOutlet weak var oldPasswordTxtField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.submitBtn.addTarget(self, action: #selector(ChangePasswordViewController.submitBtnPressed), for: UIControl.Event.touchUpInside)
        self.headerView.delegate = self
        self.headerView.setConfiguration()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func submitBtnPressed() {
     
        guard let oldPassword = self.oldPasswordTxtField.text, !oldPassword.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter old password")
            return
        }
        
        guard let newPassword = self.newPasswordTxtField.text, !newPassword.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter new password")
            return
        }
        
        guard let repeatNewPassword = self.reEnterNewPasswordTxtField.text, !repeatNewPassword.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter re-enter new password")
            return
        }
        
        if (newPassword != repeatNewPassword) {
            AlertManager.showErrorAlert(message: "New password does not match")
            return
        }
        
        guard let currentUser = LoginService.instance.getCurrentUser() else {
            AlertManager.showErrorAlert(message: "Failed to load profile")
            return
        }
        
        let payload = ChangePasswordPayload(oldPassword: oldPassword, newPassword: newPassword, userId: currentUser.id)
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        LoginService.instance.changePassword(payload: payload) { [weak self]loginResponse in
            LoadingSpinner.manager.hideLoadingAnimation()
            if loginResponse.isSuccess() {
                LoginService.instance.setCurrentUser(user: loginResponse.user)
                DispatchQueue.main.async {
                    self?.backAction(UIButton())
                }
            }else{
                AlertManager.showErrorAlert(message: loginResponse.msg)
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }

    }
}


extension ChangePasswordViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension ChangePasswordViewController : NewHeaderViewProtocol {
    var headerTitle: String {
        return "Change password"
    }
    
    func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    var isBackEnabled: Bool {
        return true
    }
    
}
