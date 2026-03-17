//
//  PaymentsViewController.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 25/09/22.
//

import UIKit

class PaymentsViewController: UIViewController {

    @IBOutlet weak var headerView: NewHeaderView!
    @IBOutlet weak var useCardBtn: UIButton!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var userCardData : [UserCard]?
    var selectionMode : Bool = false
    var footerView : UIView?
    var previousSelectedIndex : IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController?.isNavigationBarHidden = true
        if selectionMode {
            self.useCardBtn.isHidden = false
        }
        
        self.headerView.delegate = self
        self.headerView.setConfiguration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getUserCards()
    }
    
    func getFooterButton() -> UIView {
        if self.footerView == nil {
            let footView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 45))
            let footerbtn = UIButton(frame: CGRect(x: 0, y: 0, width: 220, height: 45))
            footerbtn.setTitle("  Add payment method", for: UIControl.State.normal)
            footerbtn.setButtonWithTitleAndImage(fontSize : 15, fontType : "Helvetica Neue Medium", textColor: UIColor.systemBlue, tintColor : UIColor.systemBlue, bgColor: UIColor.white, buttonImage: UIImage(named: "Add_Payment_Method"), imagePosition: .left, imageSizeHW: 30)

            footerbtn.addTarget(self, action: #selector(showAddPaymentScreen), for: UIControl.Event.touchUpInside)
            footView.addSubview(footerbtn)
            self.footerView = footView
        }
        return self.footerView!
    }
    
    @IBAction func useSelectedPaymentBtnPressed(_ sender: Any) {
        guard let cardData =  BookingService.instance.currentPaymentMethod else {
            AlertManager.showErrorAlert(message: "Please select card to use")
            return
        }
        
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        LoginService.instance.selectUserCardData(cardNum: cardData.cardnum) {[weak self] response in
            LoadingSpinner.manager.hideLoadingAnimation()
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    func getUserCards() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        LoginService.instance.getCardData {[weak self] cardResponse in
            LoadingSpinner.manager.hideLoadingAnimation()
            if cardResponse.isSuccess() {
                if cardResponse.carDetails != nil {
                    self?.userCardData = cardResponse.carDetails;
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }else{
                    // TODO : show cards found yet
                }
            }else{
                AlertManager.showErrorAlert(message: cardResponse.msg ?? "Error occurred!!!")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }

    @IBAction func backbtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func showAddPaymentScreen() {
        self.addPaymentBtn(UIButton())
    }
    
    @IBAction func addPaymentBtn(_ sender: Any) {
        let sb = UIStoryboard(name: "Payment", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "AddPaymentViewController") as! AddPaymentViewController
        vcToOpen.titleString = "Add payment method"
        if selectionMode {
            vcToOpen.screenMode = CreditCardPaymentScreenMode.addPaymentMethod
        } else {
            vcToOpen.screenMode = CreditCardPaymentScreenMode.addCard
        }
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
}

extension PaymentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userCardData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Payment_Cell", for: indexPath) as? PaymentsTableViewCell {
            if let cardDat = self.userCardData {
                cell.setValuesToUI(cardDetails: cardDat[indexPath.row])
            }else{
                cell.cardNumber.text = "No card added yet."
                cell.cardImage.image = nil
                cell.accessoryType = .none
            }
            if self.selectionMode {
                if let selectedCardData =  BookingService.instance.currentPaymentMethod, selectedCardData.cardnum == userCardData![indexPath.row].cardnum {
                    cell.accessoryType = .checkmark
                    previousSelectedIndex = indexPath
                }else{
                    cell.accessoryType = .none
                }
            }else{
                cell.accessoryType = .disclosureIndicator
            }
            return cell
        } else {
            return PaymentsTableViewCell();
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectionMode {
            if let preIndex = previousSelectedIndex {
                tableView.cellForRow(at: preIndex)?.accessoryType = .none
                previousSelectedIndex = nil
            }
            
            previousSelectedIndex = indexPath
            BookingService.instance.currentPaymentMethod = userCardData![indexPath.row]
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }else{
            let sb = UIStoryboard(name: "Payment", bundle: nil)
            let vcToOpen = sb.instantiateViewController(withIdentifier: "PaymentCardDetailsViewController") as! PaymentCardDetailsViewController
            vcToOpen.card = userCardData![indexPath.row]
            self.navigationController?.pushViewController(vcToOpen, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.getFooterButton()
    }
}

extension PaymentsViewController : NewHeaderViewProtocol {
    var headerTitle: String {
        return "Payments"
    }
    
    func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    var isBackEnabled: Bool {
        return true
    }
}
