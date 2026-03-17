//
//  WelcomeDriverView.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 26/01/23.
//

import UIKit

protocol DriverStatusProtocol : NSObject {
    func driverStatusChanged(online:Bool)
}

class WelcomeDriverView: UIView {
    
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var onlineStatusLbl: UILabel!
    @IBOutlet weak var onlineStatusSubLbl: UILabel!
    @IBOutlet weak var goStatusLbl: UILabel!
    @IBOutlet weak var onlineOfflineSwitch: UISwitch!
    
    weak var delegate : DriverStatusProtocol?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.headerView.backgroundColor = UIColor(patternImage: UIImage(named: "button_bg_larger")!)
    }
    
    @IBAction func switchValueChanged(sender : UISwitch) {
//        if sender.isOn {
//            self.goStatusLbl.text = "Go Offline"
//            self.onlineStatusLbl.text = "You're on duty now"
//            self.onlineStatusSubLbl.text = "We're finding trips for you..."
//        }else{
//            self.goStatusLbl.text = "Go Online"
//            self.onlineStatusLbl.text = "You're offline"
//            self.onlineStatusSubLbl.text = "You won't receive any ride requests."
//        }
        self.updateView(isOn: sender.isOn)
        
        self.delegate?.driverStatusChanged(online: sender.isOn)
    }
    
    func updateView(isOn : Bool) {
        if isOn {
            self.goStatusLbl.text = "Go Offline"
            self.onlineStatusLbl.text = "You're on duty now"
            self.onlineStatusSubLbl.text = "We're finding trips for you..."
        }else{
            self.goStatusLbl.text = "Go Online"
            self.onlineStatusLbl.text = "You're offline"
            self.onlineStatusSubLbl.text = "You won't receive any ride requests."
        }
    }
    
    func changeOnlineStatus(isOn : Bool) {
        self.onlineOfflineSwitch.setOn(isOn, animated: true)
        self.updateView(isOn: isOn)
    }
    
    func resetSwitchStatus(isOn : Bool) {
        self.onlineOfflineSwitch.setOn(isOn, animated: true)
    }
}
