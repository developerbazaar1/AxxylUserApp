//
//  FareDetailsViewController.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 10/12/22.
//

import UIKit

class FareDetailsViewController: UIViewController {

    var fareAmount = "0.0"
    var taxesAmount = "0.0"
    var waitingChargesAmount = "0.0"
    var tipAmount = "0.0"
    var totalAmount = "0.0"
    var airportCharges = "0.0"
    var isAirportDrop = false
    
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var tipLbl: UILabel!
    @IBOutlet weak var airportPickupLbl: UILabel!
    @IBOutlet weak var airportPickupStaticLbl: UILabel!
    @IBOutlet weak var waitingChargesLbl: UILabel!
    @IBOutlet weak var taxesLbl: UILabel!
    @IBOutlet weak var fareLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }
    
    func updateUI() {
        self.fareLbl.text = String(format: "$%.2f", (self.fareAmount as NSString).doubleValue)
        self.taxesLbl.text = String(format: "$%.2f", (self.taxesAmount as NSString).doubleValue) //"$" + self.taxesAmount
        self.waitingChargesLbl.text = String(format: "$%.2f", (self.waitingChargesAmount as NSString).doubleValue) //"$" + self.waitingChargesAmount
        self.tipLbl.text =  String(format: "$%.2f", (self.tipAmount as NSString).doubleValue) // "$" + self.tipAmount
        self.airportPickupLbl.text =  String(format: "$%.2f", (self.airportCharges as NSString).doubleValue)// "$\(self.airportCharges)"
        self.totalLbl.text =  self.totalAmount //String(format: "$%.2f",
                                     //(self.totalAmount + self.waitingChargesAmount as NSString).doubleValue) //"$" + self.totalAmount
//        self.airportPickupStaticLbl.text = isAirportDrop ? "Airport Drop Charges:" : "Airport Pickup Charges:"
        self.airportPickupStaticLbl.text = "Airport Charges:"
    }

    @IBAction func closeModelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
