//
//  PassengerTripPaymentViewController.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 10/12/22.
//

import UIKit
import StripePaymentSheet
import Stripe

protocol PassengerTripEnd : NSObject {
    func tripEndedForPassengerAfterPayment()
}

class PassengerTripPaymentViewController: UIViewController {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var carModelLbl: UILabel!
    @IBOutlet weak var mapsSnapshotImgView: UIImageView!
    @IBOutlet weak var driverProfileImgView: UIImageView!
    @IBOutlet weak var startAddressLbl: UILabel!
    @IBOutlet weak var endAddressLbl: UILabel!
    @IBOutlet weak var totalAmountLbl: UILabel!
    @IBOutlet weak var cardNumberLbl: UILabel!
    var rideStatus : RideStatusResponse?
    var selectedCard : UserCard?
    var allCards: [UserCard] = []
    var isUseSavedCard: Bool = true
    weak var delegate : PassengerTripEnd?
    var paymentSheet: PaymentSheet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getRideStatus()
        self.getUserCards()
        if let imgDt = UserDefaults.standard.data(forKey: "SNAPSHOT_IMAGE") {
            self.mapsSnapshotImgView.image = UIImage(data: imgDt)
        }
        setupChangeCardButton()
    }
    
    private func setupChangeCardButton() {
        let changeBtn = UIButton(type: .system)
        changeBtn.setTitle("Change", for: .normal)
        changeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        changeBtn.addTarget(self, action: #selector(changeCardBtnClicked(_:)), for: .touchUpInside)
        
        changeBtn.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(changeBtn)
        
        NSLayoutConstraint.activate([
            changeBtn.leadingAnchor.constraint(equalTo: cardNumberLbl.trailingAnchor, constant: 10),
            changeBtn.centerYAnchor.constraint(equalTo: cardNumberLbl.centerYAnchor),
            changeBtn.heightAnchor.constraint(equalToConstant: 30),
            changeBtn.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func getRideStatus() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        BookingService.instance.getRideStatus(user_type: "rider", rideId: BookingService.instance.rideIdInProgress!) { [weak self] rideStatus in
            LoadingSpinner.manager.hideLoadingAnimation()
            self?.rideStatus = rideStatus
            DispatchQueue.main.async {
                self?.updateUI()
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
        }
    }
    
    func updateUICardInfo(cards : [UserCard]?){
        guard let allCards = cards else {
            return
        }
        self.allCards = allCards
        
        for card in allCards {
            if card.isActive() {
                self.selectedCard = card
                self.cardNumberLbl.text = card.cardnum.getMaskedCardNum(longLength: false)
                break
            }
        }
    }
    
    func getUserCards() {
        LoginService.instance.getCardData {[weak self] cardResponse in
            if cardResponse.isSuccess() {
                if cardResponse.carDetails != nil {
                    DispatchQueue.main.async {
                        self?.updateUICardInfo(cards: cardResponse.carDetails)
                    }
                }else{
                    // TODO : show cards found yet
                }
            }else{
                AlertManager.showErrorAlert(message: cardResponse.msg ?? "Error occurred!!!")
            }
        } errorCallBack: { errMsg in
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    func updateUI() {
        
        guard let rStatus = self.rideStatus else {
            AlertManager.showErrorAlert(message: "Failed to laod Ride Status")
            return
        }
        
        // Data used from getrideStatus API
        self.carModelLbl.text = (rStatus.Car?.carModel ?? "") + "(" + (rStatus.Car?.car_number ?? "") + ")"
        self.driverProfileImgView.kf.setImage(with: URL(string: rStatus.User!.profile_image))
        
        if let rideinfo = rStatus.Ride {
            self.startAddressLbl.text = rideinfo.pickupLocation
            self.endAddressLbl.text = rideinfo.dropLocation
        }else{
            //fatalError("Ride info not found in ride status api")
            print("Ride info not found in ride status api")
            return
        }
        
//        // from arriveEnd notification
//        guard let arriveEndNotiData = APNNotificationService.instance.getNotificationData(notificationType: PushNotificationTypes.ariveEnd) as? ArrivedEndNotificationData else {
//            //fatalError("Should not come to this screen if no arrive END is being received")
//            print("Should not come to this screen if no arrive END is being received")
//            return
//        }
//        
//        self.dateLbl.text = arriveEndNotiData.dropTime
//
        
        
        
//        self.totalAmountLbl.text = self.getTotalAmount(totalPrice: arriveEndNotiData.totalPrice,  waitingCharge: arriveEndNotiData.waitingCost, airportCharge: arriveEndNotiData.geoDropCharge != "0.00" ? arriveEndNotiData.geoDropCharge : arriveEndNotiData.geoPickupCharge != "0.0" ? arriveEndNotiData.geoPickupCharge : "0.00")
        self.totalAmountLbl.text = self.getTotalAmountFromArriveNotification();
    }
    
    func getTotalAmountFromArriveNotification() -> String {
        guard let arriveEndNotiData = APNNotificationService.instance.getNotificationData(notificationType: PushNotificationTypes.ariveEnd) as? ArrivedEndNotificationData else {
            //fatalError("Should not come to this screen if no arrive END is being received")
            print("Should not come to this screen if no arrive END is being received")
            return ""
        }
        
        self.dateLbl.text = arriveEndNotiData.dropTime
        
        return self.getTotalAmount(totalPrice: arriveEndNotiData.totalPrice,  waitingCharge: arriveEndNotiData.waitingCost, airportCharge: arriveEndNotiData.geoDropCharge != "0.00" ? arriveEndNotiData.geoDropCharge : arriveEndNotiData.geoPickupCharge != "0.0" ? arriveEndNotiData.geoPickupCharge : "0.00")
    }
    
    func getTotalAmount(totalPrice : String,  waitingCharge: String, airportCharge: String) -> String {
        let total : Double = Double(totalPrice) ?? 0.0
        let tip : Double = Double(BookingService.instance.tipAmount) ?? 0.0
        let waitingCharge : Double = Double(waitingCharge) ?? 0.0
        let airportCharges : Double = Double(airportCharge) ?? 0.0
        let final = total + tip + waitingCharge + airportCharges
        return String(format: "$%.2f", final)
    }
    
    @IBAction func showFareDetailsBtnPressed(_ sender: Any) {
        let sb = UIStoryboard(name: "Home", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "FareDetailsViewController") as! FareDetailsViewController
        
        var airportCharges = "0.00"
        if let rStatus = self.rideStatus, let rideDt = rStatus.Ride {
            if rideDt.geoDropCharge != "0.00" {
                vcToOpen.airportCharges = "$" + rideDt.geoDropCharge
                airportCharges = rideDt.geoDropCharge
            }
            
            if rideDt.geoPickupCharge != "0.00" {
                vcToOpen.airportCharges = "$" + rideDt.geoPickupCharge
                airportCharges = rideDt.geoPickupCharge
            }
        }
        
        if let arriveEndNotiData = APNNotificationService.instance.getNotificationData(notificationType: PushNotificationTypes.ariveEnd) as? ArrivedEndNotificationData {
            vcToOpen.fareAmount = arriveEndNotiData.totalPrice
            vcToOpen.totalAmount = self.getTotalAmount(totalPrice: arriveEndNotiData.totalPrice, waitingCharge: arriveEndNotiData.waitingCost, airportCharge: airportCharges)
            vcToOpen.tipAmount = BookingService.instance.tipAmount
        }
        
        vcToOpen.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = vcToOpen.sheetPresentationController {
                sheet.detents = [.medium()]
            }
        } else {
            // Fallback on earlier versions
        }
        present(vcToOpen,animated: true)
    }
    
    
    @IBAction func makePaymentBtnClicked(_ sender: Any) {
        if isUseSavedCard {
            if let card = selectedCard {
                processPaymentWithSavedCard(card: card)
            } else {
                // If no saved card but isUseSavedCard is true, fall back to adding a new card
                processPaymentWithNewCard()
            }
        } else {
            processPaymentWithNewCard()
        }
    }
    
    func processPaymentWithSavedCard(card: UserCard) {
        let totalAmount = self.getTotalAmountFromArriveNotification();
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        
        // In a real scenario, we'd use Stripe to create a PaymentMethod from these details
        // and then pass that ID to our backend. For now, since we're using direct integration
        // and the backend might expect a PaymentIntent created with these details:
        
        // 1. Create Payment Intent
        BookingService.instance.createStripePaymentIntent(amount: totalAmount) { [weak self] response in
            guard let self = self else { return }
            
            if response.isSuccess(), let clientSecret = response.clientSecret {
                // 2. Confirm the PaymentIntent with the saved card details
                self.confirmPaymentIntentWithCard(clientSecret: clientSecret, card: card)
            } else {
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: response.msg ?? "Failed to initialize payment")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    func confirmPaymentIntentWithCard(clientSecret: String, card: UserCard) {
        let cardParams = STPPaymentMethodCardParams()
        cardParams.number = card.cardnum
        cardParams.cvc = card.cardcvv
        cardParams.expMonth = NSNumber(value: Int(card.cardexpmonth) ?? 1)
        cardParams.expYear = NSNumber(value: Int(card.cardexpyear) ?? 2025)
        
        let billingDetails = STPPaymentMethodBillingDetails()
        billingDetails.name = card.cardname
        
        let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: billingDetails, metadata: nil)
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
        paymentIntentParams.paymentMethodParams = paymentMethodParams
        
        STPPaymentHandler.shared().confirmPayment(paymentIntentParams, with: self) { [weak self] status, paymentIntent, error in
            guard let self = self else { return }
            LoadingSpinner.manager.hideLoadingAnimation()
            
            switch status {
            case .succeeded:
                print("✅ Saved Card Payment Success")
                self.confirmPaymentOnBackend()
            case .failed:
                print("❌ Saved Card Payment Failed: \(String(describing: error))")
                AlertManager.showErrorAlert(message: "Payment failed: \(error?.localizedDescription ?? "Unknown error")")
            case .canceled:
                print("❌ Saved Card Payment Canceled")
            @unknown default:
                break
            }
        }
    }
    
    func processPaymentWithNewCard() {
        let totalAmount = self.getTotalAmountFromArriveNotification();
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        
        // 1. Create Payment Intent on our backend
        BookingService.instance.createStripePaymentIntent(amount: totalAmount) { [weak self] response in
            guard let self = self else { return }
            
            if response.isSuccess(), let clientSecret = response.clientSecret {
                // 2. Initialize and Present Stripe Payment Sheet
                var configuration = PaymentSheet.Configuration()
                configuration.merchantDisplayName = "Axxyl"
                
                self.paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
                
                DispatchQueue.main.async {
                    LoadingSpinner.manager.hideLoadingAnimation()
                    self.presentStripePaymentSheet()
                }
            } else {
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: response.msg ?? "Failed to initialize payment")
            }
            
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    @IBAction func changeCardBtnClicked(_ sender: Any) {
        // Option 1: Show an action sheet to select from saved cards or add new
        let actionSheet = UIAlertController(title: "Select Payment Method", message: nil, preferredStyle: .actionSheet)
        
        for card in allCards {
            let maskedNum = card.cardnum.getMaskedCardNum(longLength: false)
            actionSheet.addAction(UIAlertAction(title: "Use \(maskedNum)", style: .default, handler: { _ in
                self.selectedCard = card
                self.cardNumberLbl.text = maskedNum
                self.isUseSavedCard = true
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Add New Card", style: .default, handler: { _ in
            self.isUseSavedCard = false
            self.cardNumberLbl.text = "New Card"
            self.processPaymentWithNewCard()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func presentStripePaymentSheet() {
        paymentSheet?.present(from: self) { [weak self] paymentResult in
            guard let self = self else { return }
            
            switch paymentResult {
            case .completed:
                print("✅ Stripe Payment Success")
                self.confirmPaymentOnBackend()
                
            case .canceled:
                print("❌ Stripe Payment Cancelled")
                
            case .failed(let error):
                print("❌ Stripe Payment failed: \(error)")
                AlertManager.showErrorAlert(message: "Payment failed: \(error.localizedDescription)")
            }
        }
    }
    
    func confirmPaymentOnBackend() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        
        BookingService.instance.confirmStripePayment { [weak self] response in
            LoadingSpinner.manager.hideLoadingAnimation()
            self?.delegate?.tripEndedForPassengerAfterPayment()
            
            DispatchQueue.main.async {
                let sb = UIStoryboard(name: "Home", bundle: nil)
                let vcToOpen = sb.instantiateViewController(withIdentifier: "PaymentSuccessfulViewController") as! PaymentSuccessfulViewController
                self?.navigationController?.pushViewController(vcToOpen, animated: true)
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: "Payment was successful, but failed to update trip status. Please contact support.")
        }
    }
}

extension PassengerTripPaymentViewController: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}
