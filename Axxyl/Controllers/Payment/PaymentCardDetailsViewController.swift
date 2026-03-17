//
//  PaymentCardDetailsViewController.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 28/09/22.
//

import UIKit

class PaymentCardDetailsViewController: UIViewController {

    @IBOutlet weak var cardNumberLbl: UILabel!
    @IBOutlet weak var cardExpiryDateLbl: UILabel!
    @IBOutlet weak var cardNameLbl: UILabel!
    
    var card: UserCard!
    override func viewDidLoad() {
        super.viewDidLoad()
        if (card != nil) {
            self.updateValues()
        }
    }
    
    func updateValues() {
        cardNumberLbl.text = card.cardnum.getMaskedCardNum(longLength: true)//card.cardnum
        cardExpiryDateLbl.text = "\(card.cardexpmonth)/\(card.cardexpyear)"
        cardNameLbl.text = card.cardname
    }
    
    @IBAction func editCardBtn(_ sender: Any) {
        let sb = UIStoryboard(name: "Payment", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "AddPaymentViewController") as! AddPaymentViewController
        vcToOpen.card = card
        vcToOpen.editDelegate = self
        vcToOpen.screenMode = CreditCardPaymentScreenMode.editCard
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    
    func navigateBack() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func confirmDeleteCard() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        LoginService.instance.deletePaymentMethod(cardnum: card.cardnum) { [weak self] cardResponse in
            LoadingSpinner.manager.hideLoadingAnimation()
            if cardResponse.isSuccess() {
                self?.navigateBack()
//                AlertManager.showInfoAlert(message: cardResponse.msg ?? "Card deleted successfully")
            }else{
                AlertManager.showErrorAlert(message: cardResponse.msg ?? "Error occured while deleting the card")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }

    }
    
    @IBAction func deleteCardBtn(_ sender: Any) {
        
        let actionMenu = UIAlertController(title: "Are you sure you want to delete the car?", message: "You will not able to make payment for your booking from this card unless you add it again in app.", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Yes, Delete", style: .destructive, handler: { (UIAlertAction) in
            self.confirmDeleteCard()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (UIAlertAction) in
            print("Cancel clicked")
        })
        
        actionMenu.addAction(cancelAction)
        actionMenu.addAction(deleteAction)
        
        self.present(actionMenu, animated: true, completion: nil)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PaymentCardDetailsViewController : CardEditProtocol {
    func editCardSuccess(cardDt updatedDt : UserCard) {
        self.card = updatedDt
        self.updateValues()
    }
}
