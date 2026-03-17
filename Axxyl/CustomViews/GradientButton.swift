//
//  GradientButton.swift
//  axxyl
//
//  Created by Mangesh Kondaskar on 17/09/22.
//

import UIKit

@IBDesignable
class GradientButton: UIButton {
    
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
    
    @IBInspectable var isSegamentControlType: Bool = false {
       didSet {
           updateView()
       }
    }
    
    @IBInspectable var isSegmentSelected: Bool = false {
       didSet {
           updateView()
       }
    }
    
    @IBInspectable var angle: CGFloat = 0 {
       didSet {
           // use this for angaled gradient and pass dynamic start end
           // calculatePoints(for: angle)
           updateView()
       }
    }
    
    private var startPoint = CGPoint(x: 0, y: 0.5)
    private var endPoint = CGPoint(x: 1, y: 0.5)
    
    override class var layerClass: AnyClass {
       get {
          return CAGradientLayer.self
       }
    }
        
    func updateView() {
       let layer = self.layer as! CAGradientLayer
        layer.cornerRadius = 10
        if isSegamentControlType {
            if isSegmentSelected {
                layer.colors = [firstColor, secondColor].map{$0.cgColor}
                if (isHorizontal) {
                    layer.startPoint = CGPoint(x: 0, y: 0.2)
                    layer.endPoint = CGPoint (x:0.6, y: 0.5)
                } else {
                    layer.startPoint = CGPoint(x: 0.5, y: 0)
                    layer.endPoint = CGPoint (x: 0.5, y: 1)
                }
                self.setTitleColor(.white, for: .normal)
            } else {
                layer.colors = [UIColor.clear]
               // layer.colors = [UIColor(red: 231.0/255.0, green: 235.0/255.0, blue: 244.0/255.0, alpha: 1.0)].map{$0.cgColor}
                self.setTitleColor(UIColor(red: 130.0/255.0, green: 130.0/255.0, blue: 130.0/255.0, alpha: 1.0), for: .normal)
            }
           
        } else {
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

    
    public func calculatePoints(for angle: CGFloat) {


        var ang = (-angle).truncatingRemainder(dividingBy: 360)

        if ang < 0 { ang = 360 + ang }

        let n: CGFloat = 0.5

        switch ang {

        case 0...45, 315...360:
            let a = CGPoint(x: 0, y: n * tanx(ang) + n)
            let b = CGPoint(x: 1, y: n * tanx(-ang) + n)
            startPoint = a
            endPoint = b

        case 45...135:
            let a = CGPoint(x: n * tanx(ang - 90) + n, y: 1)
            let b = CGPoint(x: n * tanx(-ang - 90) + n, y: 0)
            startPoint = a
            endPoint = b

        case 135...225:
            let a = CGPoint(x: 1, y: n * tanx(-ang) + n)
            let b = CGPoint(x: 0, y: n * tanx(ang) + n)
           startPoint = a
            endPoint = b

        case 225...315:
            let a = CGPoint(x: n * tanx(-ang - 90) + n, y: 0)
            let b = CGPoint(x: n * tanx(ang - 90) + n, y: 1)
            startPoint = a
            endPoint = b

        default:
            let a = CGPoint(x: 0, y: n)
            let b = CGPoint(x: 1, y: n)
            startPoint = a
            endPoint = b

        }
    }
    
    private func tanx(_ 𝜽: CGFloat) -> CGFloat {
        return tan(𝜽 * CGFloat.pi / 180)
    }
}
