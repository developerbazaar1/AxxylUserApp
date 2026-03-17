//
//  TipsViewController.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 08/11/22.
//

import UIKit

protocol TipsSelectionDelegate {
    func skipTip()
    func addTipWithPercentage(percentage : Int)
    func addTipAsAmount(amount : String)
}

class TipsViewController: UIViewController {

    @IBOutlet var tipBtns: [UIButton]!
    @IBOutlet weak var addCustomTipBtn: UIButton!
    
    @IBOutlet weak var customTipTxtField: UITextField!
    @IBOutlet weak var customTipStackView: UIStackView!
    
    weak var selectedTipBtn : UIButton?
    var customTipEnabled = false
    var delegate : TipsSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presentationController?.delegate = self
    }

    @IBAction func customTipBtnClicked(_ sender: Any) {
        self.resetTipBtns()
        if customTipEnabled { // remove custom tip
            addCustomTipBtn.setImage(UIImage(named: "Add_Payment_Method"), for: UIControl.State.normal)
            addCustomTipBtn.setTitle("Add Custom Amount", for: UIControl.State.normal)
            addCustomTipBtn.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        }else{
            addCustomTipBtn.setImage(UIImage(named: "Delete_Card"), for: UIControl.State.normal)
            addCustomTipBtn.setTitle("Remove Custom Amount", for: UIControl.State.normal)
            addCustomTipBtn.setTitleColor(UIColor.red, for: UIControl.State.normal)
        }
        customTipStackView.isHidden = !customTipStackView.isHidden
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        customTipEnabled = !customTipEnabled
    }
    
    func selectBtn(btn : UIButton) {
        btn.backgroundColor = .black
        btn.tintColor = .white
    }
    
    func deSelectBtn(btn : UIButton) {
        btn.backgroundColor = .white
        btn.tintColor = .black
    }
    
    func resetTipBtns() {
        self.tipBtns.forEach { btn in
            deSelectBtn(btn: btn)
        }
        
        self.selectedTipBtn = nil
    }
    
    @IBAction func tipBtnPressed(_ sender: Any) {
        
        if customTipEnabled {
            customTipBtnClicked(UIButton())
        }
        
        if (selectedTipBtn != nil &&  selectedTipBtn == (sender as! UIButton) ) {
            deSelectBtn(btn: sender as! UIButton)
            self.selectedTipBtn = nil
            return
        }
        
        self.resetTipBtns()
        
        selectBtn(btn: sender as! UIButton)
        self.selectedTipBtn = sender as? UIButton
    }
    
    @IBAction func skipBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
        self.delegate?.skipTip()
    }
    
    @IBAction func addTipBtnPressed(_ sender: Any) {
        if customTipEnabled {
            guard let tip = self.customTipTxtField.text, !tip.isEmpty else {
                AlertManager.showErrorAlert(message: "Please Enter tip")
                return
            }
            print("tip amount \(tip)$" )
            self.dismiss(animated: true)
            self.delegate?.addTipAsAmount(amount: tip)
        }else {
            if let selTipBtn = self.selectedTipBtn {
                print("tip selected \(selTipBtn.tag)%" )
                self.dismiss(animated: true)
                self.delegate?.addTipWithPercentage(percentage: selTipBtn.tag)
            }else{
                AlertManager.showErrorAlert(message: "Please select tip")
            }
        }
    }
}

extension TipsViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension TipsViewController : UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
}
