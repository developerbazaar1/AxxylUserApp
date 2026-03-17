//
//  MenuViewController.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 29/09/22.
//

import UIKit
import Kingfisher

class MenuViewController: UIViewController {
    
    @IBOutlet weak var headerView: NewHeaderView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userEmailLbl: UILabel!
    @IBOutlet weak var userPhoneNumLbl: UILabel!
 //   @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
   // @IBOutlet weak var menuViewHeight: NSLayoutConstraint!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileTapableBtn: UIButton!
    @IBOutlet weak var appVersionBuildLbl: UILabel!
    
    
    var menus: [Dictionary<String, String>] {
//        if let userType = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype), userType ==  UserType.passenger.rawValue {
        if LoginService.instance.currentUserType ==  UserType.passenger {
            return [["Booking History":"Booking History"], ["Credit Cards":"Payments / Credit Cards"], ["Help":"Help"], ["Invite a Friend":"Invite a Friend"], ["Rate Us!":"Rate Us!"], ["Delete Account": "Delete Account"], ["Logs": "Logs"]]
        } else {
            return [["Booking History" : "Booking History"], ["Manage Car" : "Manage Car"], ["Account Payout Details" : "Account / Payout Details"], ["Payment Summary" : "Payment Summary"], ["Monthly Fee" : "Monthly Fee"], ["Credit Cards" : "Credit Cards"], ["Document" : "Document"], ["Help" : "Help"], ["Invite a Friend" : "Invite a Friend"], ["Rate Us!" : "Rate Us!"], ["Delete Account": "Delete Account"], ["Logs": "Logs"]]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appVersionBuildLbl.text = AppDelegate.appVersionBuild()
        self.navigationController?.isNavigationBarHidden = true
     //   tableViewHeight.constant = CGFloat(menus.count * 44)
     //   menuViewHeight.constant = CGFloat(tableViewHeight.constant + 141)
        self.headerView.delegate = self
        self.headerView.setConfiguration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIWithValues()
    }
    
    func updateUIWithValues() {
        if let currentUser = LoginService.instance.getCurrentUser() {
            self.userNameLbl.text = currentUser.name
            self.userPhoneNumLbl.text = currentUser.phone
            self.userEmailLbl.text = currentUser.emailId
            self.userImage.kf.setImage(with: URL(string: currentUser.profile_image))
        }
    }
    
    @IBAction func showProfileScreen(_ sender: Any) {
        let sb = UIStoryboard(name: "Profile", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "ProfileViewController")
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    func logoutAndRedirect() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            appDelegate.loadLanding()
        }
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        LoginService.instance.logoutFromBackend {[weak self] response in
            LoadingSpinner.manager.hideLoadingAnimation()
            LoginService.instance.logoutCurrentUser()
            self?.logoutAndRedirect()
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: "Failed to logout. Please retry after sometime.")
        }
    }
    
    @objc func deleteUserAccountPressed() {
        print("here it is coming");
        let alert = UIAlertController(title: "Confirm", message: "Are you sure, do you want to delete the account?", preferredStyle: UIAlertController.Style.alert);
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            UIAlertAction in
            LoadingSpinner.manager.showLoadingAnimation(delegate: self)
            LoginService.instance.deleteUserAccount {[weak self] response in
                LoadingSpinner.manager.hideLoadingAnimation()
                LoginService.instance.logoutCurrentUser()
                self?.logoutAndRedirect();
            } errorCallBack: { errMsg in 
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        }
        
        let yesDriverAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            UIAlertAction in
            LoadingSpinner.manager.showLoadingAnimation(delegate: self)
            LoginService.instance.deleteUserAccount {[weak self] response in
                LoadingSpinner.manager.hideLoadingAnimation()
                LoginService.instance.logoutCurrentUser()
                self?.logoutAndRedirect();
            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        }
        
        let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        
        if LoginService.instance.currentUserType == UserType.passenger {
            alert.addAction(yesAction)
        }else{
            alert.addAction(yesDriverAction)
        }
        
        alert.addAction(noAction)
        self.present(alert, animated: true)
    }
}

extension MenuViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let profile_item = menus[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Menu_Cell", for: indexPath) as? MenuTableViewCell {
            cell.menuItemLbl.text = profile_item[Array(profile_item.keys).first!]
            cell.menuItemImage.image = UIImage(named: "\(Array(profile_item.keys).first!).png")
            return cell
        } else {
            return MenuTableViewCell();
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Go to screen:\(menus[indexPath.row])")
        
//        if let userType = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype), userType ==  UserType.passenger.rawValue {
        if LoginService.instance.currentUserType ==  UserType.passenger {
            switch indexPath.row {
            case 0 :
                let sb = UIStoryboard(name: "Menu", bundle: nil)
                let vcToOpen = sb.instantiateViewController(withIdentifier: "BookingHistoryViewController") as! BookingHistoryViewController
                self.navigationController?.pushViewController(vcToOpen, animated: true)
                
            case 1:
                let sb = UIStoryboard(name: "Payment", bundle: nil)
                let vcToOpen = sb.instantiateViewController(withIdentifier: "PaymentsViewController") as! PaymentsViewController
                self.navigationController?.pushViewController(vcToOpen, animated: true)
                
            case 2:
                let sb = UIStoryboard(name: "Help", bundle: nil)
                let vcToOpen = sb.instantiateViewController(withIdentifier: "HelpViewController") as! HelpViewController
                self.navigationController?.pushViewController(vcToOpen, animated: true)
                
            case 3:
                inviteFriendsToUseApp()
            case 5:
                self.deleteUserAccountPressed();
            default:
                print("unhandled case")
            }
        } else {
            switch indexPath.row {
            case 0 :
                let sb = UIStoryboard(name: "Menu", bundle: nil)
                let vcToOpen = sb.instantiateViewController(withIdentifier: "BookingHistoryViewController") as! BookingHistoryViewController
                self.navigationController?.pushViewController(vcToOpen, animated: true)
                
            case 1:
                let sb = UIStoryboard(name: "ManageCars", bundle: nil)
                let vcToOpen = sb.instantiateViewController(withIdentifier: "ManageCarsViewController") as! ManageCarsViewController
                self.navigationController?.pushViewController(vcToOpen, animated: true)
                
            case 2:
                if let currentUser = LoginService.instance.getCurrentUser(), currentUser.payout_type == "Mail" {
                    let sb = UIStoryboard(name: "Account", bundle: nil)
                    let vcToOpen = sb.instantiateViewController(withIdentifier: "MailingAccountDetailsViewController") as! MailingAccountDetailsViewController
                    self.navigationController?.pushViewController(vcToOpen, animated: true)
                } else {
                    let sb = UIStoryboard(name: "Account", bundle: nil)
                    let vcToOpen = sb.instantiateViewController(withIdentifier: "AccountDetailsViewController") as! AccountDetailsViewController
                    self.navigationController?.pushViewController(vcToOpen, animated: true)
                }
                
            case 3:
                let sb = UIStoryboard(name: "Payment", bundle: nil)
                let vcToOpen = sb.instantiateViewController(withIdentifier: "PaymentSummaryViewController") as! PaymentSummaryViewController
                vcToOpen.screenMode = PaymentFeeScreenMode.paymentSummary
                self.navigationController?.pushViewController(vcToOpen, animated: true)
                
            case 4:
                let sb = UIStoryboard(name: "Payment", bundle: nil)
                let vcToOpen = sb.instantiateViewController(withIdentifier: "PaymentSummaryViewController") as! PaymentSummaryViewController
                vcToOpen.screenMode = PaymentFeeScreenMode.monthlyFee
                self.navigationController?.pushViewController(vcToOpen, animated: true)
                
            case 5:
                let sb = UIStoryboard(name: "Payment", bundle: nil)
                let vcToOpen = sb.instantiateViewController(withIdentifier: "PaymentsViewController") as! PaymentsViewController
                self.navigationController?.pushViewController(vcToOpen, animated: true)
                // upper flow seems not for driver need verification
//                let sb = UIStoryboard(name: "Payment", bundle: nil)
//                let vcToOpen = sb.instantiateViewController(withIdentifier: "PaymentCardDetailsViewController") as! PaymentCardDetailsViewController
//                self.navigationController?.pushViewController(vcToOpen, animated: true)
                
            case 6:
                let sb = UIStoryboard(name: "Document", bundle: nil)
                let vcToOpen = sb.instantiateViewController(withIdentifier: "DriverDocumentsViewController") as! DriverDocumentsViewController
               // vcToOpen.screenMode = PaymentFeeScreenMode.monthlyFee
                self.navigationController?.pushViewController(vcToOpen, animated: true)
                
            case 7:
                let sb = UIStoryboard(name: "Help", bundle: nil)
                let vcToOpen = sb.instantiateViewController(withIdentifier: "HelpViewController") as! HelpViewController
                self.navigationController?.pushViewController(vcToOpen, animated: true)
                
            case 8:
                inviteFriendsToUseApp()
                
            default:
                print("unhandled case")
            }
        }
//
//        let cardDetails = cards[indexPath.row]
//        let sb = UIStoryboard(name: "Payment", bundle: nil)
//        let vcToOpen = sb.instantiateViewController(withIdentifier: "PaymentCardDetailsViewController") as! PaymentCardDetailsViewController
//        vcToOpen.card = cardDetails
//        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
}

extension MenuViewController : NewHeaderViewProtocol {
    var headerTitle: String {
        return "Menu"
    }
    
    func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    var isBackEnabled: Bool {
        return true
    }
}

extension MenuViewController {
    
    func inviteFriendsToUseApp() {
        let textToShare = "Axxyl app is awesome! Check out this website about it and book a car for your future commutes!"

            if let myWebsite = NSURL(string: "http://www.axxyl.com") {
                let objectsToShare = [textToShare, myWebsite] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                //New Excluded Activities Code
                activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
                //

                activityVC.popoverPresentationController?.sourceView = self.view
                self.present(activityVC, animated: true, completion: nil)
            }
    }
}
