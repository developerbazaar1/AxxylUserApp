//
//  RadioButton.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 03/12/22.
//

import UIKit

class RadioButton: UIButton {
    
    @IBInspectable var isChecked : Bool = false {
        didSet {
            if (isChecked) {
                self.setImage(UIImage(named: "RadioButton_On.png"), for: UIControl.State.normal)
            }else{
                self.setImage(UIImage(named: "RadioButton_Off.png"), for: UIControl.State.normal)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
