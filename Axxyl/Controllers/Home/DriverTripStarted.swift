//
//  DriverTripStarted.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 28/01/23.
//

import UIKit

protocol DriverTripStartProtocol : NSObject {
    func driverEndsRide()
}

class DriverTripStarted: UIView {

    @IBOutlet weak var estimatedCostLbl : UILabel!
    @IBOutlet weak var dropAddressLbl : UILabel!
    weak var delegate : DriverTripStartProtocol?
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    var userId : String = ""
    @IBOutlet weak var etaBtn: UIButton!
    
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
    
    @IBAction func endRideBtnPressed(sender : UIButton) {
        self.delegate?.driverEndsRide()
    }
    
    func attachData(data : DriverReceivedRideRequestNotificationData) {
        self.estimatedCostLbl.text = data.userPrice
        self.dropAddressLbl.text = data.dropLocation
        self.userId = data.userId
    }
}
