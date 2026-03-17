//
//  PaymentSuccessfulViewController.swift
//  Axxyl
//
//  Created by kondaskar_m on 17/04/24.
//

import UIKit

class PaymentSuccessfulViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func goToHome(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true);
    }

}
