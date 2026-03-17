//
//  DriverArrivingView.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 28/01/23.
//

import UIKit

protocol DriverArrivingProtocol : NSObject {
    func ihavearrived()
    func callPassenger()
    func smsPassenger()
}

class DriverArrivingView: UIView {
    @IBOutlet weak var userNameLbl : UILabel!
    @IBOutlet weak var userPhoneNoLbl : UILabel!
    @IBOutlet weak var pickupAddressLbl : UILabel!
    @IBOutlet weak var userProfileBtn : UIButton!
    @IBOutlet weak var etaBtn : UIButton!
    weak var delegate : DriverArrivingProtocol?
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    var userId : String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        styleEtaButton()
    }
    
    private func styleEtaButton() {
        etaBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        etaBtn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        etaBtn.layer.cornerRadius = 8
        etaBtn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    }
    
    @IBAction func arrivedBtnPressed(sender : UIButton) {
        self.delegate?.ihavearrived()
    }
    
    @IBAction func smsBtnPressed(sender : UIButton) {
        self.delegate?.smsPassenger()
    }
    
    @IBAction func callBtnPressed(sender : UIButton) {
        self.delegate?.callPassenger()
    }
    
    func attachData(data : DriverReceivedRideRequestNotificationData) {
        self.userNameLbl.text = data.UserName
        self.userPhoneNoLbl.text = data.UserPhone
        self.pickupAddressLbl.text = data.pickupLocation
        self.userId = data.userId
        if let imgURL = URL(string: data.UserImage) {
            self.userProfileBtn.kf.setImage(with: imgURL, for: .normal)
        }
    }
}
