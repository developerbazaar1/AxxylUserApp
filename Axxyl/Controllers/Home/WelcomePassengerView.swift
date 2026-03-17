//
//  WelcomePassengerView.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 07/10/22.
//

import UIKit

protocol WelcomePassengerViewDelegate : AnyObject {
    func viewPastTrips()
    func searchTxtFieldDidBeginEditing()
}

class WelcomePassengerView: UIView {

    weak var delegate : WelcomePassengerViewDelegate?
    @IBOutlet weak var headerTitleLbl: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var searchTxtField: UITextField!
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    
    @IBAction func viewPastTripsButtonClicked(_ sender: Any) {
        delegate?.viewPastTrips()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        self.headerView.backgroundColor = UIColor(patternImage: UIImage(named: "button_bg_larger")!)
    }
    
}


extension WelcomePassengerView : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.delegate?.searchTxtFieldDidBeginEditing()
        return false
    }
}
