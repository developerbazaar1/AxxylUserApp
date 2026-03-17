//
//  SelectVehicleTypeViewController.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 08/10/22.
//

import UIKit
import MapKit

let searchTimeout : TimeInterval = 60

class SelectVehicleTypeViewController: UIViewController {

    @IBOutlet weak var bookingProgressView: UIView!
    @IBOutlet weak var mkmapView: MKMapView!
    @IBOutlet weak var vehicleTypeSelectionView: VehicleTypeView!
    @IBOutlet weak var maskedCardNumberLbl: UILabel!
    @IBOutlet weak var vehicleSelectionContentView: UIView!
    @IBOutlet weak var carTypesTableView: UITableView!
    @IBOutlet weak var cardInfoStackView: UIStackView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var selectedCardBtn: UIButton!
    var isSearchingDriver = false
    
    @IBOutlet weak var inlineActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectingLbl: UILabel!
    @IBOutlet weak var retrySearchBtnStackView: UIStackView!
    var carTypes : [CarCategory]?
    var userCardData : [UserCard]?
    var routeLocations: [MapLocation]?
    var searchDriverTimer : Timer?
    
    var snapShotOptions: MKMapSnapshotter.Options = MKMapSnapshotter.Options()
    var snapShot: MKMapSnapshotter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.getEstimatedPriceDetails()
        self.getUserCards()
        mkmapView.showsUserLocation = true
        mkmapView.showsCompass = true
        mkmapView.showsScale = true
        mkmapView.showsTraffic = true
        mkmapView.showsBuildings = true
       // mkmapView.showsPointsOfInterest = true
        // for test
        if let routeArray = routeLocations {
            LocationManager.managerObj.addAnnotationOnMap(mapview: self.mkmapView, locationArray: routeArray)
            let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            LocationManager.managerObj.showRouteOnMap(mapView: self.mkmapView, locationArray: routeArray, padding: padding)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedNotifications), name: NSNotification.Name(PushNotificationTypes.accept.rawValue), object: nil)
        print("[DEBUG][SelectVehicle] Registered observer for notification type: '\(PushNotificationTypes.accept.rawValue)'")
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updatePaymentMethod(shouldUseSelected: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func receivedNotifications(_ notification : Notification) {
        print("[DEBUG][SelectVehicle] RAW notification received: name=\(notification.name.rawValue)")
        print("[DEBUG][SelectVehicle] Notification object type: \(type(of: notification.object))")
        if let data = notification.object as? NotificationData {
            print("[DEBUG][SelectVehicle] NotificationData parsed - msgType: '\(data.msgType)', expecting: '\(PushNotificationTypes.accept.rawValue)'")
            if data.msgType == PushNotificationTypes.accept.rawValue {
                print("[DEBUG][SelectVehicle] ✅ Ride ACCEPTED by driver! vendorId: \(data.vendorId), vendorName: \(data.vendorName)")
                self.searchDriverTimer?.invalidate()
                self.searchDriverTimer = nil
                self.reloadHomeScreenWaitingForDriver(data: data)
            } else {
                print("[DEBUG][SelectVehicle] ⚠️ msgType mismatch - got '\(data.msgType)', needed '\(PushNotificationTypes.accept.rawValue)'")
            }
        } else {
            print("[DEBUG][SelectVehicle] ❌ Could not cast notification object to NotificationData")
        }
    }
    
    func navigateToPaymentMethods() {
        let sb = UIStoryboard(name: "Payment", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "PaymentsViewController") as! PaymentsViewController
        vcToOpen.selectionMode = true
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    @IBAction func addPaymentMethodBtnPressed(_ sender: Any) {
        self.navigateToPaymentMethods()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        if self.isSearchingDriver {
            return
        }
        mkmapView.removeAnnotations(mkmapView.annotations)
        mkmapView.removeOverlays(mkmapView.overlays)
        self.navigationController?.popViewController(animated: true)
    }
    
    func getUserCards() {
        print("calling ger user cards")
        LoginService.instance.getCardData {[weak self] cardResponse in
            print("card Response ", cardResponse)
            if cardResponse.isSuccess() {
                if cardResponse.carDetails != nil {
                    self?.userCardData = cardResponse.carDetails;
                    DispatchQueue.main.async {
                        self?.updatePaymentMethod()
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
    
    @IBAction func changePaymentMethod(_ sender: Any) {
        self.addPaymentMethodBtnPressed(UIButton())
    }
    
    func updatePaymentMethod(shouldUseSelected : Bool = false){
        
        if !shouldUseSelected {
            guard let cards = self.userCardData else {
                return
            }
            
            for card in cards {
                if card.isActive() {
                    BookingService.instance.currentPaymentMethod = card
                    break
                }
            }
            if (cards.isEmpty) {
                BookingService.instance.currentPaymentMethod = nil;
            }
        }
        
        guard let cardData = BookingService.instance.currentPaymentMethod else {
            UIView.animate(withDuration: 0.25) {
                self.addBtn.isHidden = false
                self.cardInfoStackView.isHidden = true
                self.view.layoutIfNeeded()
            }
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            self.addBtn.isHidden = true
            self.cardInfoStackView.isHidden = false
            self.view.layoutIfNeeded()
        }
        selectedCardBtn.setTitle(cardData.cardnum.getMaskedCardNum(longLength: false), for: UIControl.State.normal)
        selectedCardBtn.layoutIfNeeded()
    }
    
    func getEstimatedPriceDetails() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        BookingService.instance.getEstimatedPriceDetails { [weak self] estimateResponse in
            LoadingSpinner.manager.hideLoadingAnimation()
            guard let weakSelf = self else { return }
            if (estimateResponse.isSuccess()){
                BookingService.instance.currentRideEstimateResponse = estimateResponse
                weakSelf.carTypes = estimateResponse.catPriceList
                DispatchQueue.main.async {
                    weakSelf.carTypesTableView.reloadData()
                }
            }else{
                AlertManager.showErrorAlert(message: estimateResponse.msg ?? "Failed to get ride estimate")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    func takeSnapshot() {
        // TODO: get proper area snapshot
        snapShotOptions.region = mkmapView.region
        snapShotOptions.size = mkmapView.frame.size //CGSize(width: mkmapView.visibleMapRect.size.width, height: mkmapView.visibleMapRect.size.height)
        print("Size: \(mkmapView.visibleMapRect.size.width) , \(mkmapView.visibleMapRect.size.height)")
        snapShotOptions.scale = UIScreen.main.scale
       // snapShotOptions.region.span = mkmapView.region.span
              
        snapShot = MKMapSnapshotter(options: snapShotOptions)
        snapShot.start { (snapshot, error) -> Void in
            if error == nil {
                UserDefaults.standard.setValue(snapshot!.image.pngData()!, forKey: "SNAPSHOT_IMAGE")
                print("Image data = \(UserDefaults.standard.data(forKey: "SNAPSHOT_IMAGE")!)")
            } else {
                print("Error taking snapshot")
            }
        }
    }
 
    func showConfirmRideDetails() {
        let sb = UIStoryboard(name: "Home", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "ConfirmRideDetailsViewController") as! ConfirmRideDetailsViewController
        vcToOpen.confirmDelegate = self
        vcToOpen.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = vcToOpen.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
            }
        } else {
            // Fallback on earlier versions
        }
        present(vcToOpen,animated: true)
    }
    
    func updateUIWithDriverSearchRetry() {
        self.connectingLbl.text = "Drivers not available, do want to retry again?"
        self.retrySearchBtnStackView.isHidden = false
        self.inlineActivityIndicator.isHidden = true
    }
    
    func updateUIWithSearchingProgress() {
        self.connectingLbl.text = "Connecting to nearby drivers..."
        self.retrySearchBtnStackView.isHidden = true
        self.inlineActivityIndicator.isHidden = false
        self.view.layoutIfNeeded()
    }

    
    func startDriverSearchTimer() {
        if (searchDriverTimer != nil) {
            searchDriverTimer?.invalidate()
            searchDriverTimer = nil
        }
        
        print("[DEBUG][SelectVehicle] ⏱ Driver search timer STARTED - waiting \(searchTimeout)s for driver to accept...")
        self.searchDriverTimer = Timer.scheduledTimer(withTimeInterval: searchTimeout, repeats: false, block: {[weak self] timer in
            timer.invalidate()
            print("[DEBUG][SelectVehicle] ⏱ Driver search timer EXPIRED after \(searchTimeout)s - no driver accepted!")
            DispatchQueue.main.async {
                self?.isSearchingDriver = false
                self?.updateUIWithDriverSearchRetry()
            }
        })
    }
    
    @IBAction func cancelRetryDriverSearchBtnPressed(_ sender: Any) {
        self.updateUIWithSearchingProgress()
        self.updateErrorCondition()
    }
    
    @IBAction func retryDriverSearchBtnPressed(_ sender: Any) {
        self.updateUIWithSearchingProgress()
        self.confirmRide()
    }
}


extension SelectVehicleTypeViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        takeSnapshot()
        tableView.deselectRow(at: indexPath, animated: true)
        if BookingService.instance.currentPaymentMethod != nil {
            BookingService.instance.currentVehicleType = carTypes![indexPath.row]
            self.showConfirmRideDetails()
        }else{
            AlertManager.showErrorAlert(message: "Please select Payment method")
        }
    }
}

extension SelectVehicleTypeViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carTypes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CarTypeCellIdentifier", for: indexPath) as? CarTypeTableViewCell {
            cell.setValues(type: carTypes![indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

extension SelectVehicleTypeViewController : ConfirmRideProtocol {
    
    func updateErrorCondition() {
        self.vehicleSelectionContentView.isHidden = false
        self.bookingProgressView.isHidden = true
        self.view.layoutIfNeeded()
    }
    
    func reloadHomeScreenWaitingForDriver(data : NotificationData) {
        print("[DEBUG][SelectVehicle] reloadHomeScreenWaitingForDriver - navigating back to home with driver info")
        print("[DEBUG][SelectVehicle] Driver vendorId: \(data.vendorId), vendorName: \(data.vendorName)")
        if let homeVc = self.navigationController?.rootViewController as? HomeViewController {
            print("[DEBUG][SelectVehicle] ✅ Found HomeViewController, setting state to .etaDriver")
            homeVc.homeState = .etaDriver
            homeVc.notificationData = data
        } else {
            print("[DEBUG][SelectVehicle] ❌ Could not find HomeViewController in navigation stack!")
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func confirmRide() {
        self.vehicleSelectionContentView.isHidden = true
        self.bookingProgressView.isHidden = false
        self.view.layoutIfNeeded()
        
        self.isSearchingDriver = true
        print("[DEBUG][SelectVehicle] confirmRide() called - sending pickup request to backend...")
        
        BookingService.instance.requestAPickup {[weak self] response in
            
            if response.isSuccess() {
                print("[DEBUG][SelectVehicle] ✅ Backend accepted pickup request. rideId: \(String(describing: response.rideId))")
                print("[DEBUG][SelectVehicle] Now waiting for driver push notification (type: '\(PushNotificationTypes.accept.rawValue)')...")
                BookingService.instance.rideIdInProgress = response.rideId
                DispatchQueue.main.async {
                    self?.startDriverSearchTimer()
                }
            } else {
                print("[DEBUG][SelectVehicle] ❌ Backend REJECTED pickup request. msg: \(String(describing: response.msg))")
                self?.isSearchingDriver = false
                AlertManager.showErrorAlert(message: response.msg ?? "Failed to find drivers")
                DispatchQueue.main.async {
                    self?.updateErrorCondition()
                }
            }
        } errorCallBack: {[weak self] errMsg in
            print("[DEBUG][SelectVehicle] ❌ requestAPickup network/error callback: \(errMsg)")
            self?.isSearchingDriver = false
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    func editAddress() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func changePaymentMethod() {
        self.navigateToPaymentMethods()
    }
}

extension SelectVehicleTypeViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.lineWidth = 4
        renderer.strokeColor = UIColor.black
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let pinImage: UIImage?
        let title = annotation.subtitle!! + "_Route.png"
        pinImage = UIImage(named: title)
        annotationView!.image = pinImage

        return annotationView
    }
}

