//
//  GradientTextField.swift
//  axxyl
//
//  Created by Mangesh Kondaskar on 18/09/22.
//

import UIKit

class GradientTextField: UITextField {

    @IBInspectable var firstColor: UIColor = UIColor.clear {
       didSet {
           updateView()
        }
     }
    
     @IBInspectable var secondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var isHorizontal: Bool = true {
       didSet {
           updateView()
       }
    }
    
    @IBInspectable var borderWidth: Int = 0 {
       didSet {
           updateView()
       }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
       didSet {
           updateView()
       }
    }
    
    override class var layerClass: AnyClass {
       get {
          return CAGradientLayer.self
       }
    }
        
    func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.cornerRadius = 10
        layer.borderWidth = CGFloat(borderWidth)
        layer.borderColor = borderColor.cgColor
         layer.colors = [firstColor, secondColor].map{$0.cgColor}
         if (isHorizontal) {
             layer.startPoint = CGPoint(x: 1, y: 1)
             layer.endPoint = CGPoint (x:0.6, y: 0)
         } else {
            layer.startPoint = CGPoint(x: 0.5, y: 0)
            layer.endPoint = CGPoint (x: 0.5, y: 1)
         }
     }

}
