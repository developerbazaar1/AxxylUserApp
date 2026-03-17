//
//  BookingHistoryViewController.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 30/09/22.
//

import UIKit

class BookingHistoryViewController: UIViewController {
    @IBOutlet weak var headerView: NewHeaderView!
    
    @IBOutlet weak var noDataHistoryLbl: UILabel!
    @IBOutlet weak var noDataHistoryView: UIView!
    @IBOutlet weak var pastSegmentBtn: GradientButton!
    @IBOutlet weak var pendingSegmentBtn: GradientButton!
    @IBOutlet weak var historyTableview: UITableView!
    
    var selectedSegmentItemIndex: Int = 0;
    var pastRides : [BookingHistoryItem]?
    var pendingRides : [BookingHistoryItem]?
    
    var temArray: Int {
//        if let userType = UserDefaults.standard.string(forKey: AppUserDefaultsKeys.usertype), userType ==  UserType.passenger.rawValue {
        if LoginService.instance.currentUserType ==  UserType.passenger {
            if selectedSegmentItemIndex == 0 {
               return 3
            } else {
                return 0
            }
        } else {
            if selectedSegmentItemIndex == 1 {
               return 1
            } else {
                return 10
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadBookingHistory()
        self.navigationController?.isNavigationBarHidden = true
        
        self.headerView.delegate = self
        self.headerView.setConfiguration()
    }
    
    func reloadUI() {
        DispatchQueue.main.async {
            self.historyTableview.isHidden = false
            self.noDataHistoryView.isHidden = true
            if let pastRidesData = self.pastRides?.isEmpty, pastRidesData == true, self.selectedSegmentItemIndex == 0 {
                self.historyTableview.isHidden = true
                self.noDataHistoryView.isHidden = false
                self.noDataHistoryLbl.text = "You don’t have any past bookings."
            }
            
            if let pendingRidesData = self.pendingRides?.isEmpty, pendingRidesData == true, self.selectedSegmentItemIndex == 1 {
                self.historyTableview.isHidden = true
                self.noDataHistoryView.isHidden = false
                self.noDataHistoryLbl.text = "You don’t have any pending bookings."
            }
            self.historyTableview.reloadData()
        }
    }
    
    func loadBookingHistory() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        BookingService.instance.getBookingHistory { [weak self] bookingResponse in
            LoadingSpinner.manager.hideLoadingAnimation()
            if (bookingResponse.isSuccess()) {
                self?.pastRides = bookingResponse.history
                self?.pendingRides = bookingResponse.pending
                self?.reloadUI()
            }else{
                AlertManager.showErrorAlert(message: bookingResponse.msg)
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    

    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pastBtnPressed(_ sender: Any) {
        if !pastSegmentBtn.isSegmentSelected {
            selectedSegmentItemIndex = 0
            pendingSegmentBtn.isSegmentSelected = false
            pastSegmentBtn.isSegmentSelected = true
            // historyTableview.reloadData()
            reloadUI()
        }
    }
    
    @IBAction func pendingBtnPressed(_ sender: Any) {
        if !pendingSegmentBtn.isSegmentSelected {
            selectedSegmentItemIndex = 1
            pastSegmentBtn.isSegmentSelected = false
            pendingSegmentBtn.isSegmentSelected = true
            //historyTableview.reloadData()
            reloadUI()
        }
    }
    
}

extension BookingHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedSegmentItemIndex == 0 {
            return self.pastRides?.count ?? 0
        }
        return self.pendingRides?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // let profile_item = menus[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TripBooking_Cell", for: indexPath) as? TripBookingTableViewCell {
            
        //Note: Remove this tem arrangment
//            if temArray == 10 || temArray == 1 {
//                cell.dateTimeLbl.text = "Sep 23, 18:30 PM"
//                cell.priceLbl.text = "$8.50"
//                cell.carLbl_tripIdLbl.text = "Trip ID 234676433"
//                cell.pickupPointLbl.text = "Brooklyn Pizza Crew - 758 Nostrand Ave., Brooklyn, NY 11216"
//                cell.dropPointLbl.text = "542 Eastern Pkwy, 873 Bedford Ave, Brooklyn, NY 11205"
//            }
            
            if selectedSegmentItemIndex == 0 {
                cell.setValuesFromItem(historyItem: self.pastRides![indexPath.row])
            }else{
                cell.setValuesFromItem(historyItem: self.pendingRides![indexPath.row])
            }
            
           // cell.menuItemLbl.text = profile_item[Array(profile_item.keys).first!]
           // cell.menuItemImage.image = UIImage(named: "\(Array(profile_item.keys).first!).png")
            return cell
        } else {
            return MenuTableViewCell();
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // print("Go to screen:\(menus[indexPath.row])")
//        let cardDetails = cards[indexPath.row]
//        let sb = UIStoryboard(name: "Payment", bundle: nil)
//        let vcToOpen = sb.instantiateViewController(withIdentifier: "PaymentCardDetailsViewController") as! PaymentCardDetailsViewController
//        vcToOpen.card = cardDetails
//        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
}

extension BookingHistoryViewController : NewHeaderViewProtocol {
    var headerTitle: String {
        return "Booking History"
    }
    
    func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    var isBackEnabled: Bool {
        return true
    }

}
