//
//  LoadingSpinner.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 26/09/22.
//

import UIKit

class LoadingSpinner: NSObject {

    weak var delegate : UIViewController?
    
    var loadingAnimationView : UIView?
    
    static let manager = LoadingSpinner()
    
    private override init() {
        super.init()
    }
    
    var animationView : UIActivityIndicatorView {
        get {

            let animationView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
            animationView.color = .white
            animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            let screenFrame = UIScreen.main.bounds
            animationView.center = CGPoint(x: screenFrame.width / 2, y: screenFrame.height / 2)
            
            return animationView
        }
    }

    func showLoadingAnimation(delegate : UIViewController) {
        if self.delegate != nil && self.delegate == delegate {
            return
        }else if self.delegate != nil && delegate != self.delegate {
            self.loadingAnimationView?.removeFromSuperview()
        }
        self.delegate = delegate
        
        let loadingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: delegate.view.frame.size.width, height: delegate.view.frame.size.height))
        loadingView.backgroundColor =
            UIColor.gray.withAlphaComponent(0.4)
        
        //make sure the view is always on top
        loadingView.layer.zPosition = 666
        
        let animView = self.animationView
        
        let delCenter = delegate.view.center
        
        if delegate.isKind(of: UINavigationController.classForCoder()) {
            animView.center = delCenter
        }else{
            let delViewFrame = CGPoint(x: delCenter.x, y: delCenter.y - 49)
            animView.center = delViewFrame
        }
        
        loadingView.addSubview(animView)
        
        animView.startAnimating()
        
        self.loadingAnimationView = loadingView
        
        delegate.view.addSubview(loadingView)
    }
    
    func hideLoadingAnimation(_ callback : @escaping () -> ()) {
        DispatchQueue.main.async(execute: {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.loadingAnimationView?.alpha = 0
                }, completion: { (done) -> Void in
                    self.delegate = nil
                    self.loadingAnimationView?.removeFromSuperview()
                    callback()
            })
        })
    }
    
    func hideLoadingAnimation(){
        DispatchQueue.main.async(execute: {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.loadingAnimationView?.alpha = 0
                }, completion: { (done) -> Void in
                    self.delegate = nil
                    self.loadingAnimationView?.removeFromSuperview()
            })
        })
    }

}
