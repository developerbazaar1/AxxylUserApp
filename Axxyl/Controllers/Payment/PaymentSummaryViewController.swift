//
//  PaymentSummaryViewController.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 26/01/23.
//

import UIKit

class PaymentSummaryViewController: UIViewController {

    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var cardTotalFeeLbl: UILabel!
    @IBOutlet weak var monthlyTotalFeeLbl: UILabel!
    @IBOutlet weak var weeklyTotalFeeLbl: UILabel!
    @IBOutlet weak var creditProcessingFeeLbl: UILabel!
    @IBOutlet weak var airportFeeLbl: UILabel!
    @IBOutlet weak var axxylFeeLbl: UILabel!
    @IBOutlet weak var rideTipLbl: UILabel!
    @IBOutlet weak var amountRcvdLbl: UILabel!
    @IBOutlet weak var summaryOrHistoryLbl: UILabel!
    @IBOutlet weak var cardSummaryStackView: UIStackView!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var rideLbl: UILabel!
    @IBOutlet weak var rideView: UIView!
    @IBOutlet weak var headerLbl: UILabel!
    
    var screenMode: PaymentFeeScreenMode = PaymentFeeScreenMode.paymentSummary
    var monthlyFeeData = [MonthlyFee(month: "January", year: "2023", fee: "$100.00"), MonthlyFee(month: "December", year: "2022", fee: "$250.00")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateScreen()
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateScreen() {
        self.historyTableView.isHidden = true
        self.cardSummaryStackView.isHidden = true
        self.headerLbl.text = screenMode.rawValue
        
        switch screenMode {
        case .paymentSummary:
            self.cardSummaryStackView.isHidden = false
            self.totalLbl.text = "Total Amount"
            self.summaryOrHistoryLbl.text = "Card Summary"
            self.getPaymentSummary()
        case .monthlyFee:
            self.historyTableView.isHidden = false
            self.totalLbl.text = "Monthly Fee"
            self.summaryOrHistoryLbl.text = "History"
        }
        
        self.rideView.layer.cornerRadius = 8
        self.rideView.layer.borderWidth = 1
        self.rideView.layer.borderColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1).cgColor
        self.totalView.layer.cornerRadius = 8
        self.totalView.layer.borderWidth = 1
        self.totalView.layer.borderColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1).cgColor
    }

    func getPaymentSummary() {
        DriverService.instance.getDriverPaymentSummary {[weak self] paymentSummary in
            LoadingSpinner.manager.hideLoadingAnimation()
            if paymentSummary.isSuccess(){
                DispatchQueue.main.async {
                    self?.updateUIWithPaymentData(summary: paymentSummary)
                }
            } else {
                AlertManager.showErrorAlert(message: paymentSummary.msg ?? "Fetching driver payment summary got failed.")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    func updateUIWithPaymentData(summary: DriverPaymentSummaryResponse) {
        let totalRide = summary.response.card.Total_Ride + summary.response.cash.Total_Ride
        let totalAmount = (Double(summary.response.card.card) ?? 0.00) + (Double(summary.response.cash.cash) ?? 0.00)
        self.rideLbl.text =  "\(totalRide)"
        self.amountLbl.text =  String(format: "$%.2f", totalAmount)
        self.amountRcvdLbl.text = String(format: "$%.2f", Double(summary.response.card.card) ?? 0.00)
        self.rideTipLbl.text = String(format: "$%.2f", summary.response.card.driver_Tip)
        self.axxylFeeLbl.text = String(format: "-$%.2f", 0.00)
        self.airportFeeLbl.text = String(format: "-$%.2f", summary.response.card.total_airport_charge)
        self.creditProcessingFeeLbl.text = String(format: "-$%.2f", summary.response.card.processingfee)
        
        let cardAmount = (Double(summary.response.card.card) ?? 0.00)
        let total = cardAmount + Double(summary.response.card.driver_Tip) - Double(summary.response.card.total_airport_charge) - Double(summary.response.card.processingfee)
        self.cardTotalFeeLbl.text = String(format: "$%.2f", total)
    }

}

extension PaymentSummaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthlyFeeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentHistoryCell", for: indexPath) as? PaymentHistoryTableViewCell {
            let data = monthlyFeeData[indexPath.row]
            cell.monthYearLbl.text = "\(data.month) \(data.year)"
            cell.feeLbl.text = "\(data.fee)"
            return cell
        } else {
            return PaymentHistoryTableViewCell();
        }
    }
}
