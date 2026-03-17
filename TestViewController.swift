//
//  TestViewController.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 17/10/22.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var headerView: NewHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.delegate = self
        headerView.setConfiguration()
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        headerView.delegat
//    }
}

extension TestViewController : NewHeaderViewProtocol {
    var headerTitle: String {
        return "Something funky"
    }
    
    func backAction() {
        print("backaction being called")
    }
    
    var isBackEnabled: Bool {
        return false
    }
    
    
}
