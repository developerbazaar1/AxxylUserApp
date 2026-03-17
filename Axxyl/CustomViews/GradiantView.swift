//
//  GradiantView.swift
//  axxyl
//
//  Created by Mangesh Kondaskar on 17/09/22.
//

import UIKit

@IBDesignable
class GradiantView: UIView {

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
    
    override class var layerClass: AnyClass {
       get {
          return CAGradientLayer.self
       }
    }
        
    func updateView() {
        let layer = self.layer as! CAGradientLayer
         layer.cornerRadius = 10
         layer.colors = [firstColor, secondColor].map{$0.cgColor}
         if (isHorizontal) {
             layer.startPoint = CGPoint(x: 0, y: 0.2)
             layer.endPoint = CGPoint (x:0.6, y: 0.5)
         } else {
            layer.startPoint = CGPoint(x: 0.5, y: 0)
            layer.endPoint = CGPoint (x: 0.5, y: 1)
         }
     }
}
