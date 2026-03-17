//
//  LoginViewController.swift
//  axxyl
//
//  Created by Mangesh Kondaskar on 18/09/22.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var passwordVisibility: UIButton!
    
    @IBOutlet weak var headerView: NewHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.addSubview(headerViewNew)
//        self.headerView.addSubview(Bundle.main.loadNibNamed("HeaderView", owner: self)?.first as! HeaderView)
        self.headerView.delegate = self;
        self.headerView.setConfiguration()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func showPassword(_ sender: Any) {
        if passwordTxtField.isSecureTextEntry {
            passwordVisibility.setImage(UIImage(named: "Visibility_Off.png"), for: .normal)
            passwordTxtField.isSecureTextEntry = false
        } else {
            passwordVisibility.setImage(UIImage(named: "Visibility.png"), for: .normal)
            passwordTxtField.isSecureTextEntry = true
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        
    }
    
    func loadHome() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            appDelegate.loadHome()
        }
    }
    
    @IBAction func login(_ sender: Any) {
        
        guard let emailId = self.emailTxtField.text, !emailId.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter email")
            return
        }
        
        if !emailId.validateEmail() {
            AlertManager.showErrorAlert(message: "Please enter valid email id.")
            return
        }
        
        guard let password = self.passwordTxtField.text, !password.isEmpty else {
            AlertManager.showErrorAlert(message: "Please enter password")
            return
        }
        
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        if let userType = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype), userType ==  UserType.passenger.rawValue {
            LoginService.instance.loginUser(email: emailId, password: password) {[weak self] userInfoResponse in
                LoadingSpinner.manager.hideLoadingAnimation()
                if userInfoResponse.isSuccess() {
                    LoginService.instance.setCurrentUser(user: userInfoResponse.user)
                    self?.loadHome()
                }else{
                    AlertManager.showErrorAlert(message: userInfoResponse.msg)
                }
            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        } else {
            DriverService.instance.loginUser(email: emailId, password: password) {[weak self] userInfoResponse in
                LoadingSpinner.manager.hideLoadingAnimation()
                if userInfoResponse.user != nil{
                    LoginService.instance.setCurrentUser(user: userInfoResponse.user)
                    DriverService.instance.isOnline = userInfoResponse.user!.bookingOn == "1" ? true : false
                    self?.loadHome()
                } else {
                    AlertManager.showErrorAlert(message: userInfoResponse.msg)
                }
            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        }
    }
    
    @IBAction func facebookLogin(_ sender: Any) {
    }
    
    @IBAction func register(_ sender: Any) {
        let sb = UIStoryboard(name: "Signup", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
}


extension LoginViewController : NewHeaderViewProtocol {
    var headerTitle: String {
        return "Login to account"
    }
    
    var isBackEnabled: Bool {
        return true
    }
    
    func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

