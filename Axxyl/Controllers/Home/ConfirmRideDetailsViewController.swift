//
//  ConfirmRideDetailsViewController.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 12/10/22.
//

import UIKit
import Stripe
import StripePaymentSheet

protocol ConfirmRideProtocol : AnyObject {
    func editAddress()
    func confirmRide()
    func changePaymentMethod()
}

class ConfirmRideDetailsViewController: UIViewController {
    
    weak var confirmDelegate : ConfirmRideProtocol?
    @IBOutlet weak var confirmRiderBtn: GradientButton!
    @IBOutlet weak var endAddressLbl: UILabel!
    @IBOutlet weak var startAddressLbl: UILabel!
    
    @IBOutlet weak var totalAmountLbl: UILabel!
    @IBOutlet weak var carTypeNameLbl: UILabel!
    @IBOutlet weak var carTypeIconImgView: UIImageView!
    @IBOutlet weak var noOfSeatsLbl: UILabel!
    @IBOutlet weak var maskedCardNoLbl: UILabel!
    @IBOutlet weak var travelTimeLbl: UILabel!
    @IBOutlet weak var travelDistanceLbl: UILabel!
    @IBOutlet weak var airportPriceLbl: UILabel!
    @IBOutlet weak var airportChargesStackView: UIStackView!
    
    var paymentSheet: PaymentSheet?
    var paymentSheetResult: PaymentSheetResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.confirmRiderBtn.addTarget(self, action: #selector(confirmRidePressed), for: UIControl.Event.touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUIWithValues()
    }
    
    func updateUIWithValues() {
        guard let routes = BookingService.instance.routeLocations, routes.count > 1 else {
            return
        }
        
        let startLoc = routes.first!
        let endLoc = routes.last!
        startAddressLbl.text = (startLoc.name ?? "") + " - " + (startLoc.address ?? "")
        endAddressLbl.text = (endLoc.name  ?? "") + " - " + (endLoc.address ?? "")
        
        guard let vehType = BookingService.instance.currentVehicleType else {
            return
        }
        carTypeNameLbl.text = vehType.name
        carTypeIconImgView.image = UIImage(named: "\(vehType.name)_Car.png")//kf.setImage(with: URL(string: vehType.carTypeIcon))
        noOfSeatsLbl.text = vehType.seats + " Seats"
        
        guard let paymentmethod = BookingService.instance.currentPaymentMethod else {
            return
        }
        
        totalAmountLbl.text = BookingService.instance.currentVehicleType?.displayTotalPrice() ?? "$0.0"
        
        let subStr = paymentmethod.cardnum.suffix(4)
        maskedCardNoLbl.text = "Visa : **** " + String(subStr)
        
        guard let estimate = BookingService.instance.currentRideEstimateResponse else {
            return
        }
        
        travelTimeLbl.text = estimate.time ?? ""
        if let etaTimeStr = UserDefaults.standard.value(forKey: "ESTIMATED_TIME_FOR_TRAVEL") as? String {
            travelTimeLbl.text = etaTimeStr
        }
        
        travelDistanceLbl.text = estimate.distance ?? ""
        
        if let etaDistStr = UserDefaults.standard.value(forKey: "ESTIMATED_DISTANCE_OF_TRAVEL") as? String {
            travelDistanceLbl.text = etaDistStr
        }
        
        if estimate.geoPickPrice == 0.0 && estimate.geoDropPrice == 0.0 {
            airportChargesStackView.isHidden = true
        }else{
            if estimate.geoDropPrice != 0.0 {
                airportPriceLbl.text = "Airport Drop Charges: $ \(estimate.geoDropPrice ?? 0.0)"
            }
            if estimate.geoPickPrice != 0.0 {
                airportPriceLbl.text = "Airport Pickup Charges: $ \(estimate.geoDropPrice ?? 0.0)"
            }
        }
    }
    
    @IBAction func editLocation(_ sender: Any) {
        self.dismiss(animated: true) {
            self.confirmDelegate?.editAddress()
        }
    }
    
    @IBAction func changePaymentMethodBtnPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.confirmDelegate?.changePaymentMethod()
        }
        let sb = UIStoryboard(name: "Payment", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "PaymentsViewController") as! PaymentsViewController
        vcToOpen.selectionMode = true
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    @IBAction func changeVehicleType(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func goBackBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc func confirmRidePressed() {
        self.dismiss(animated: true) {
            self.confirmDelegate?.confirmRide()
        }
        //  createPaymentIntent()
        // Note: Payment processing is now handled in PassengerTripPaymentViewController at the end of the trip
    }
}
