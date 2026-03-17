//
//  RideTypeViewController.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 17/09/22.
//

import UIKit

class RideTypeViewController: UIViewController {

    @IBOutlet weak var passengerImgView: UIImageView!
    @IBOutlet weak var driverImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestures();
    }
    
    func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(RideTypeViewController.userTypePassenger))
        tap.numberOfTapsRequired = 1
        passengerImgView.addGestureRecognizer(tap)
        passengerImgView.isUserInteractionEnabled = true
        
        let driverTap = UITapGestureRecognizer(target: self, action: #selector(RideTypeViewController.userTypeDriver))
        driverTap.numberOfTapsRequired = 1
        driverImgView.addGestureRecognizer(driverTap)
        
        driverImgView.isUserInteractionEnabled = true

    }
    
    @objc func userTypePassenger()
    {
        UserDefaults.standard.set(UserType.passenger.rawValue, forKey: AppUserDefaultsKeys.usertype)
        showLogin()   
    }
    
    @objc func userTypeDriver()
    {
        UserDefaults.standard.set(UserType.driver.rawValue, forKey: AppUserDefaultsKeys.usertype)
        showLogin()
    }
    
    func showLogin()
    {
        let sb = UIStoryboard(name: "Signup", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "LoginViewController")
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
