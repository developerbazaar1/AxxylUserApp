//
//  CheckBoxButton.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 28/09/22.
//

import UIKit

class CheckBoxButton: UIButton {
    
    @IBInspectable var isChecked : Bool = false {
        didSet {
            if (isChecked) {
                self.setImage(UIImage(named: "Checked_Box.png"), for: UIControl.State.normal)
            }else{
                self.setImage(UIImage(named: "Unchecked_Box.png"), for: UIControl.State.normal)
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
