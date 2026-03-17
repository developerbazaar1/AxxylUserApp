//
//  ProfileViewController.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 29/09/22.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController {

    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    
    @IBOutlet weak var zipcodeLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUIWithValues()
    }
    
    func updateUIWithValues() {
        if let currentUser = LoginService.instance.getCurrentUser() {
            self.fullNameLbl.text = currentUser.name
            self.phoneNumberLbl.text = currentUser.phone
            self.emailLbl.text = currentUser.emailId
            self.profileImgView.kf.setImage(with: URL(string: currentUser.profile_image))
            self.addressLbl.text = currentUser.pa_address
            self.countryLbl.text = currentUser.pa_country
            self.stateLbl.text = currentUser.pa_state
            self.cityLbl.text = currentUser.pa_city
            self.zipcodeLbl.text = currentUser.pa_zipcode
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
