//
//  HelpTopicDetailsViewController.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 25/02/23.
//

import UIKit
import WebKit

class HelpTopicDetailsViewController: UIViewController {

    @IBOutlet weak var headerTitleLbl: UILabel!
    @IBOutlet weak var web: WKWebView!
    
    var topic : String!
    var url : String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerTitleLbl.text = self.topic
        web.navigationDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        if (self.topic == "Terms and Conditions") {
            url = "https://register.axxyl.com/terms_n_condition.html"
        } else if (self.topic == "Direct Deposit Terms and Conditions") {
            url = "https://register.axxyl.com/terms_n_condition_direct_deposit.html"
        }else {
            url = "https://register.axxyl.com/contact_support.html"
        }
        loadURL(url: url)
    }

    func loadURL(url: String) {
        guard let url = URL(string: url) else {
            AlertManager.showErrorAlert(message: "The link provided is not valid.")
            return
        }
        let request = URLRequest(url: url)
        web.load(request)
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension HelpTopicDetailsViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        LoadingSpinner.manager.hideLoadingAnimation()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        LoadingSpinner.manager.hideLoadingAnimation()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        LoadingSpinner.manager.hideLoadingAnimation()
    }
}
