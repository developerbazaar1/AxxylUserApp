//
//  PassengerNotifiedView.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 28/01/23.
//

import UIKit

protocol PassengerNotifiedProtocol : NSObject {
    func startRide()
    func driverCancelsRide()
    func pncallPassenger()
    func pnsmsPassenger()
    func updateBackendWithWaitTimeStart()
}

class PassengerNotifiedView: UIView {
    @IBOutlet weak var driverNameLbl : UILabel!
    @IBOutlet weak var driverPhoneNoLbl : UILabel!
    @IBOutlet weak var pickupAddressLbl : UILabel!
    @IBOutlet weak var dropAddressLbl : UILabel!
    @IBOutlet weak var userProfileBtn : UIButton!
    @IBOutlet weak var etaBtn : UIButton!
    weak var delegate : PassengerNotifiedProtocol?
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    var userId : String = ""
    var pickupLatLong : String = ""
    var waitTimer : Timer?
    var remainingWaitTime : TimeInterval = 1 * 60
    
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
    
    @IBAction func startRideBtnPressed(sender : UIButton) {
        self.stopDriverWaitTime()
        self.delegate?.startRide()
    }
    
    @IBAction func noShowBtnPressed(sender : UIButton) {
        self.stopDriverWaitTime()
        self.delegate?.driverCancelsRide()
    }
    
    @IBAction func smsBtnPressed(sender : UIButton) {
        self.delegate?.pnsmsPassenger()
    }
    
    @IBAction func callBtnPressed(sender : UIButton) {
        self.delegate?.pncallPassenger()
    }
    
    func attachData(data : DriverReceivedRideRequestNotificationData) {
        self.driverNameLbl.text = data.UserName
        self.driverPhoneNoLbl.text = data.UserPhone
        self.pickupAddressLbl.text = data.pickupLocation
        self.dropAddressLbl.text = data.dropLocation
        self.userId = data.userId
        self.pickupLatLong = data.pickuplatLong
        if let imgURL = URL(string: data.UserImage) {
            self.userProfileBtn.kf.setImage(with: imgURL, for: .normal)
        }
    }
    
    func stringFromTime(interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter.string(from: interval)!
    }
    
    @objc func updateWaitTime() {
//        if remainingWaitTime > 0 {
//            remainingWaitTime = remainingWaitTime - 1
//            self.etaBtn.text = stringFromTime(interval: remainingWaitTime)
//        }else{
//            self.stopDriverWaitTime()
//        }
        if remainingWaitTime == 0 {
            self.delegate?.updateBackendWithWaitTimeStart()
        }
        remainingWaitTime = remainingWaitTime - 1
        self.etaBtn.setTitle(stringFromTime(interval: remainingWaitTime), for: UIControl.State.normal)
    }
    
    func startDriverWaitTime() {
        if self.waitTimer != nil {
            self.waitTimer?.invalidate()
            self.waitTimer = nil
        }
        
        self.waitTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateWaitTime), userInfo: nil, repeats: true)
    }
    
    func stopDriverWaitTime() {
        if self.waitTimer != nil {
            self.remainingWaitTime = waitTime
            self.waitTimer?.invalidate()
            self.waitTimer = nil
        }
    }
}
