//
//  UIKitExtensions.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 27/09/22.
//

import UIKit

extension UIApplication {
    class func getTopMostViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopMostViewController(base: nav.visibleViewController)
        }
        if let presented = base?.presentedViewController {
            return getTopMostViewController(base: presented)
        }
        return base
    }
}




@IBDesignable extension UIView {
    @IBInspectable var shadowRadius: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }

    @IBInspectable var shadowOpacity: CGFloat {
        get { return CGFloat(layer.shadowOpacity) }
        set { layer.shadowOpacity = Float(newValue) }
    }

    @IBInspectable var shadowOffset: CGSize {
        get { return layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }

    @IBInspectable var shadowColor: UIColor? {
        get {
            guard let cgColor = layer.shadowColor else {
                return nil
            }
            return UIColor(cgColor: cgColor)
        }
        set { layer.shadowColor = newValue?.cgColor }
    }
}

enum buttonImageDirection: Int {
                    case left = 0
                    case right
                    case top
                    case bottom
    }

extension UIButton{
     func setButtonWithTitleAndImage(fontSize : CGFloat = 15, fontType : String = "Poppins-Medium", textColor: UIColor, tintColor : UIColor, bgColor:UIColor = .clear, buttonImage: UIImage?, imagePosition:buttonImageDirection = .left, imageSizeHW: CGFloat = 30){
            if imageView != nil {
                let image = buttonImage?.withRenderingMode(.alwaysTemplate)
                self.setImage(image, for: .normal)
                self.titleLabel?.font = UIFont(name: fontType, size: fontSize)
                self.setTitleColor(textColor, for: .normal)
                self.tintColor = tintColor
                self.backgroundColor = bgColor
                
                switch imagePosition{
                case .left:
                    imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: (bounds.width - (imageSizeHW + 5)))
                    titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (imageView?.frame.width)!)
                case .right:
                    imageEdgeInsets = UIEdgeInsets(top: 5, left: (bounds.width - (imageSizeHW + 5)), bottom: 5, right: 5)
                    titleEdgeInsets = UIEdgeInsets(top: 0, left: (imageView?.frame.width)!, bottom: 0, right: 0)
                case .top:
                    imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: (bounds.width - (imageSizeHW + 5)), right: 5)
                    titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: (imageView?.frame.height)!, right: 0)
                case .bottom:
                    imageEdgeInsets = UIEdgeInsets(top: (bounds.width - (imageSizeHW + 5)), left: 5, bottom: 5, right: 5)
                    titleEdgeInsets = UIEdgeInsets(top: (imageView?.frame.height)!, left: 0, bottom: 0, right: 0)
                }
            }
            self.layoutIfNeeded()
        }
}

extension UINavigationController {

    var rootViewController: UIViewController? {
        return viewControllers.first
    }

}

@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
