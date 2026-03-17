//
//  AlertManager.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 27/09/22.
//

import UIKit

class AlertManager: NSObject {
    
    private override init() {
    }
    
    @objc class func showInfoAlert(_ title: String? = "Information", message: String, controller: UIViewController? = UIApplication.getTopMostViewController()){
        self.showCustomAlertWith(title, message: message, actions: nil, controller: controller)
    }
    
    @objc class func showErrorAlert(_ title: String? = "Error", message: String, controller: UIViewController? = UIApplication.getTopMostViewController()) {
        self.showCustomAlertWith(title, message: message, actions: nil, controller: controller)
    }
    
    @objc @discardableResult class func showCustomAlertWith(_ title: String?, message: String, actions: [UIAlertAction]?, controller: UIViewController? = UIApplication.getTopMostViewController()) -> UIAlertController? {
        guard let presenterVC = controller else { return nil }
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        
        let allActions = actions ?? [okAction]
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        //add all actions
        allActions.forEach{ alert.addAction($0) }
        
        // show the alert
        presenterVC.present(alert, animated: true, completion: nil)
        
        return alert
    }

}
