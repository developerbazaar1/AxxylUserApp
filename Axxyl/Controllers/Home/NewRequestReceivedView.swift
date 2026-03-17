//
//  NewRequestReceivedView.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 28/01/23.
//

import UIKit
protocol DriverRideAcceptRejectProtocol : NSObject {
    func declinedRide()
    func acceptedRide()
}


class NewRequestReceivedView: UIView {
    
    @IBOutlet weak var dateLbl : UILabel!
    @IBOutlet weak var pickupAddressLbl : UILabel!
    weak var delegate : DriverRideAcceptRejectProtocol?
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    var currentRideId : String = ""
    var userId : String = ""
    
    @IBAction func declineRideBtnPressed(sender : UIButton) {
        self.delegate?.declinedRide()
    }
    
    @IBAction func acceptRideBtnPressed(sender : UIButton) {
        self.delegate?.acceptedRide()
    }
    
    func attachData(data : DriverReceivedRideRequestNotificationData) {
        self.dateLbl.text = Date.getCurrentDate()
        self.pickupAddressLbl.text = data.pickupLocation
        self.currentRideId = data.reqId
        self.userId = data.userId
    }
}
