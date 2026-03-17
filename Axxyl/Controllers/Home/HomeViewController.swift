//
//  HomeViewController.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 29/09/22.
//

import UIKit
import CoreLocation
import MapKit
import Kingfisher
import MessageUI

enum HomeState : Int {
    case search
    case etaDriver
    case driverWaiting
    case tripStarted
    
    
    case empty
    case driverHome
    case driverNewRideRequest
    case driverArriving
    case passengerNotified
    case driverTripStarted
}

class HomeViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var profileBtn: UIButton!
    
    @IBOutlet weak var driverOnWayView: DriverOnWayView!
    @IBOutlet weak var tripStartForUserView: TripStartedView!
    @IBOutlet weak var welcomeDriverView: WelcomeDriverView!
    @IBOutlet weak var welcomePassengerView: WelcomePassengerView!
    @IBOutlet weak var rideRequestReceivedView: NewRequestReceivedView!
    @IBOutlet weak var driverArrivingView: DriverArrivingView!
    @IBOutlet weak var passengerNotifiedView: PassengerNotifiedView!
    @IBOutlet weak var driverTripStartedView: DriverTripStarted!
    
    var isFirstTimeMapRendered: Bool = false;
    
    var myCurrentLocation: MapLocation?
    var destinationLocation = MapLocation(id: 1)
    lazy var geocoder = CLGeocoder()
    
    var notificationData : CommonNotificationData?
    
    let currentUserType = LoginService.instance.currentUserType
    
    var currentLocation : CLLocation?
    
    var driverPoolingTimer: Timer?
    
    var nearByDriverTimer: Timer?
    
    var homeState : HomeState = .empty {
        didSet {
            updateScreenState()
        }
    }
    
    var greetingMessage: String {
      let hour = Calendar.current.component(.hour, from: Date())
      if hour < 12 { return "Good morning" }
      if hour < 18 { return "Good afternoon" }
      return "Good evening"
    }
    
    lazy var locationManager: CLLocationManager = {
        var manager = CLLocationManager()
        manager.distanceFilter = 10
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        profileBtn.imageView?.layer.masksToBounds = true
        profileBtn.imageView?.layer.cornerRadius = profileBtn.frame.width/2
        profileBtn.imageView?.layer.borderWidth = 2
        profileBtn.imageView?.layer.borderColor = UIColor(red: 77.0/255.0, green: 35.0/255.0, blue: 229.0/255.0, alpha: 0.5).cgColor
        
        locationManager.delegate = self
        mapView.showsUserLocation = true
//        locationManager.startUpdatingHeading()
        self.mapView.showsCompass = false
        
        welcomePassengerView.delegate = self
        driverOnWayView.delegate = self
        welcomeDriverView.delegate = self
        rideRequestReceivedView.delegate = self
        driverArrivingView.delegate = self
        passengerNotifiedView.delegate = self
        driverTripStartedView.delegate = self
        
        if self.currentUserType == .passenger {
            self.addPassengerNotificationListener()
        }else if self.currentUserType == .driver {
            self.addDriverNotificationListener()
        }
        //checkLocationPermission()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedUpdatedEta), name: NSNotification.Name("UpdatedETA"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedUpdatedTripInfo), name: NSNotification.Name("UpdatedTripInfo"), object: nil)
        
        self.homeState = self.currentUserType == .passenger ? HomeState.search : HomeState.driverHome
        Logger.shared.log("Home view controoler")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           self.updateUIWithValues()
           if self.currentUserType == .driver {
               self.getDriverStatus()
           }
       }
    
    @objc func appWillEnterForeground() {
            checkLocationPermission()
        }
    
    override func viewDidAppear(_ animated: Bool) {
        Logger.shared.log("Home view controoler", level: .debug)
        super.viewDidAppear(animated)
        self.updateScreenState()
        UIApplication.shared.isIdleTimerDisabled = true
        if let user = LoginService.instance.getCurrentUser() {
            welcomePassengerView.headerTitleLbl.text = "\(greetingMessage), " + user.name
        }
        
        if self.homeState == .search && LoginService.instance.currentUserType == .passenger && currentLocation != nil {
            self.startPoolingNearByDrivers()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        self.stopPoolingNearByDrivers()
    }
    
    func checkLocationPermission() {
                let status = locationManager.authorizationStatus

                switch status {
                case .notDetermined:
                    // Request permission if not yet determined
                    locationManager.requestWhenInUseAuthorization()
                    locationManager.requestAlwaysAuthorization()
                case .restricted, .denied:
                    // Show alert if permission is denied or restricted
                   let openSettings = UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
                                // Open app settings
                                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(appSettings)
                                }
                            })
                    AlertManager.showCustomAlertWith("Need Location permission", message: "To provide the best taxi service experience, we need access to your location. Please enable location services by following this path:\n\nSettings → Axxyl → Location → Select 'While Using the App' or 'Always'.", actions: [openSettings])
                case .authorizedAlways, .authorizedWhenInUse:
                    // Permissions are already granted, continue as normal
                    break
                @unknown default:
                    break
                }
        }
    
    func addPassengerNotificationListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(receivedPassengerNotifications), name: NSNotification.Name(PushNotificationTypes.arrived.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedPassengerNotifications), name: NSNotification.Name(PushNotificationTypes.tripStarted.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedPassengerNotifications), name: NSNotification.Name(PushNotificationTypes.ariveEnd.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedPassengerNotifications), name: NSNotification.Name(PushNotificationTypes.cancle.rawValue), object: nil)
    }
    
    @objc func receivedUpdatedEta(notification: Notification) {
        guard let etaStr = notification.object as? String else {
            return
        }
        
        let savedDist = UserDefaults.standard.string(forKey: "ESTIMATED_DISTANCE_OF_TRAVEL") ?? "---"
        let distanceDisplay = savedDist.contains("miles") ? savedDist : "\(savedDist) miles"
        
        if self.homeState == .etaDriver {
            self.driverOnWayView.updateEtaBanner(time: etaStr, distance: distanceDisplay)
        } else if self.homeState == .tripStarted {
            self.tripStartForUserView.updateEtaBanner(time: etaStr, distance: distanceDisplay)
        } else if self.homeState == .driverArriving {
            self.driverArrivingView.etaBtn.setTitle("ETA: \(etaStr)", for: .normal)
        } else if self.homeState == .driverTripStarted {
            self.driverTripStartedView.etaBtn.setTitle("ETA: \(etaStr)", for: .normal)
        }
    }
    
    @objc func receivedUpdatedTripInfo(notification: Notification) {
        guard let info = notification.object as? [String: String],
              let etaStr = info["eta"],
              let distStr = info["distance"] else {
            return
        }
        
        let distanceDisplay = distStr.contains("miles") ? distStr : "\(distStr) miles"
        
        if self.homeState == .etaDriver {
            self.driverOnWayView.updateEtaBanner(time: etaStr, distance: distanceDisplay)
        } else if self.homeState == .tripStarted {
            self.tripStartForUserView.updateEtaBanner(time: etaStr, distance: distanceDisplay)
        }
        // Legacy support for other views if needed
        let displayStr = "ETA: \(etaStr) (\(distanceDisplay))"
        if self.homeState == .driverArriving {
            self.driverArrivingView.etaBtn.setTitle(displayStr, for: .normal)
        } else if self.homeState == .driverTripStarted {
            self.driverTripStartedView.etaBtn.setTitle(displayStr, for: .normal)
        }
    }
    
    func addDriverNotificationListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(receivedDriverNotifications), name: NSNotification.Name(PushNotificationTypes.sentReq.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedDriverNotifications), name: NSNotification.Name(PushNotificationTypes.cancle.rawValue), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func receivedPassengerNotifications(_ notification : Notification) {
        if let data = notification.object as? NotificationData {
            if data.msgType == PushNotificationTypes.arrived.rawValue {
                Logger.shared.log("Notification received: \(PushNotificationTypes.arrived.rawValue)", level: .error)
                self.notificationData = data
                self.homeState = .driverWaiting
                self.stopDriverLocationPooling()
            } else if data.msgType == PushNotificationTypes.tripStarted.rawValue {
                Logger.shared.log("Notification received: \(PushNotificationTypes.tripStarted.rawValue)", level: .error)
                self.notificationData = data
                self.homeState = .tripStarted
            }
        } else if let data = notification.object as? CancelEndNotificationData {
            if data.msgType == PushNotificationTypes.cancle.rawValue {
                Logger.shared.log("Notification received: \(PushNotificationTypes.cancle.rawValue)", level: .error)
                self.notificationData = data
                self.rideCanceledStateUpdate()
                self.homeState = .search
                self.stopDriverLocationPooling()
                AlertManager.showInfoAlert(message: "Ride has been cancelled")
            }
        } else if let data = notification.object as? ArrivedEndNotificationData {
            if data.msgType == PushNotificationTypes.ariveEnd.rawValue {
                Logger.shared.log("Notification received: \(PushNotificationTypes.ariveEnd.rawValue)", level: .error)
                self.notificationData = data
                self.homeState = .empty
                self.clearRoutesAndAnnotations()
                self.tripEndedForPassenger()
            }
        }
    }
    
    @objc func receivedDriverNotifications(_ notification : Notification) {
        if let data = notification.object as? CommonNotificationData {
            if data.msgType == PushNotificationTypes.sentReq.rawValue {
                Logger.shared.log("Driver Notification received: \(PushNotificationTypes.sentReq.rawValue)", level: .error)
                self.notificationData = data
                self.homeState = .driverNewRideRequest
            }else if data.msgType == PushNotificationTypes.cancle.rawValue {
                Logger.shared.log("Driver Notification received: \(PushNotificationTypes.cancle.rawValue)", level: .error)
                self.notificationData = data
                self.homeState = .driverHome
                AlertManager.showInfoAlert(message: "Ride has been cancelled")
            }
        }
    }
    
    func updateScreenStateForDriver() {
        if homeState == .driverHome {
            self.welcomeDriverView.bottomConstriant.constant = 0
            self.welcomeDriverView.onlineOfflineSwitch.setOn(DriverService.instance.isOnline, animated: true)
            self.rideRequestReceivedView.bottomConstriant.constant = -450
            self.passengerNotifiedView.bottomConstriant.constant = -550
            self.driverTripStartedView.bottomConstriant.constant = -350
            self.driverArrivingView.bottomConstriant.constant = -420
            UIView.animate(withDuration: 0.5, delay: 1) {
                self.view.layoutIfNeeded()
            }
        }else if homeState == .driverNewRideRequest {
            self.welcomeDriverView.bottomConstriant.constant = -420
            self.rideRequestReceivedView.bottomConstriant.constant = 0
            UIView.animate(withDuration: 0.5, delay: 1) {
                self.view.layoutIfNeeded()
            }
            if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
                updateDriverRideRequestReceived(data)
            }
        }else if homeState == .driverArriving {
            self.rideRequestReceivedView.bottomConstriant.constant = -420
            self.driverArrivingView.bottomConstriant.constant = 0
            UIView.animate(withDuration: 0.5, delay: 1) {
                self.view.layoutIfNeeded()
            }
            if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
                updateDriverArriving(data)
            }
        }else if homeState == .passengerNotified {
            self.driverArrivingView.bottomConstriant.constant = -420
            self.passengerNotifiedView.bottomConstriant.constant = 0
            UIView.animate(withDuration: 0.5, delay: 1) {
                self.view.layoutIfNeeded()
            }
            if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
                updatePassengerNotified(data)
            }
        }else if homeState == .driverTripStarted {
            self.driverTripStartedView.bottomConstriant.constant = 0
            self.passengerNotifiedView.bottomConstriant.constant = -550
            UIView.animate(withDuration: 0.5, delay: 1) {
                self.view.layoutIfNeeded()
            }
            if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
                updateDriverTripStarted(data)
            }
        }
    }
    
    func updateScreenState() {
        if currentUserType == .passenger {
            self.updateScreenStateForPassenger()
            // Stop driver pooling if driver is not on the way to passenger location
//            if homeState != .etaDriver {
//                self.stopDriverLocationPooling()
//            }
        } else if currentUserType == .driver {
            self.updateScreenStateForDriver()
        }
    }
    
    func updateUIWithValues() {
        if let currentUser = LoginService.instance.getCurrentUser() {
            if let imgURL = URL(string: currentUser.profile_image) {
                self.profileBtn.kf.setImage(with: imgURL, for: .normal)
            }
        }
    }
    
    @IBAction func menuBtnPressed(_ sender: Any) {
        let sb = UIStoryboard(name: "Profile", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    @IBAction func humburgerBtnPressed(_ sender: Any) {
        let sb = UIStoryboard(name: "Menu", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    func presentSearchViewController() {
        let sb = UIStoryboard(name: "Home", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        vcToOpen.delegate = self
        vcToOpen.mapView = mapView
        if myCurrentLocation != nil {
            vcToOpen.stopLocationItems.removeAll()
            myCurrentLocation?.id = 0
            vcToOpen.stopLocationItems.append(myCurrentLocation!)
            vcToOpen.stopLocationItems.append(destinationLocation)
        }
        vcToOpen.modalPresentationStyle = .fullScreen
        present(vcToOpen, animated: true)
    }
    
    func presentTipsViewController() {
        let sb = UIStoryboard(name: "Home", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "tipsviewcontroller") as! TipsViewController
        vcToOpen.modalPresentationStyle = .pageSheet
        vcToOpen.delegate = self
        if #available(iOS 15.0, *) {
            if let sheet = vcToOpen.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                // sheet.largestUndimmedDetentIdentifier = .medium
            }
        } else {
            // Fallback on earlier versions
        }
        present(vcToOpen,animated: true)
    }
    
    func navigateToPassengerTripPaymentViewController() {
        let sb = UIStoryboard(name: "Home", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "PassengerTripPaymentViewController") as! PassengerTripPaymentViewController
        vcToOpen.delegate = self
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    func getDriverStatus() {
        DriverService.instance.getDriverStatus {[weak self] response in
            if response.isSuccess() {
                DriverService.instance.isOnline = response.bookingOn == "1" ? true : false
            }
            DispatchQueue.main.async {
                self?.updateUIWithDriverStatus()
            }
        } errorCallBack: { errMsg in
            print("failed to load driver status... check why it is happening - \(errMsg)")
        }
    }
    
    func sendSmsToNumber(_ number : String) {
        guard MFMessageComposeViewController.canSendText() else {
            print("Unable to send messages.")
            return
        }
        
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = self
        controller.recipients = ["+\(number)"]
        controller.body = ""
        present(controller, animated: true)
    }
    
    func makeACallToNumber(_ number : String) {
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            checkLocationPermission()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // TODO : refactor - update only if user is driver
        if LoginService.instance.currentUserType == .driver {
            Logger.shared.log("Updating driver location: \(String(describing: locations.last?.coordinate))", level: .misc)
            self.updateDriverLocation(newLocation: locations.last)
        } else {
            self.setupNavigationCamera()
            Logger.shared.log("Updating Passanger location: \(String(describing: locations.last?.coordinate))", level: .misc)
            self.updatePassengerLocation(newLocation: locations.last)
        }
        
        print("LOCATION UPDATE --> \(String(describing: locations.last?.coordinate))")
        if let location = locations.last {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Unable to Reverse Geocode Location (\(error))")
                } else {
                    if let placemarks = placemarks, let placemark = placemarks.first {
                        self.myCurrentLocation = LocationManager.managerObj.parseLocationPlaceMark(placemark: placemark, isCurrentLocation: true)
                    } else {
                        print("No Matching Addresses Found")
                    }
                }
            }
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009))
            mapView.setRegion(region, animated: true)
        }
        if (currentLocation != nil) {
            self.showNearByCarsOnMap()
        }
    }
    
    // Forces the Map into 3D Turn-By-Turn Navigation Mode
    func setupNavigationCamera() {
        guard self.homeState == .driverArriving || self.homeState == .driverTripStarted || self.homeState == .tripStarted else { return }
        
        self.mapView.showsBuildings = true
        self.mapView.isPitchEnabled = true
        self.mapView.isRotateEnabled = true
        
        // RECOVERY: If tracking was dropped (Tracking: 0), restart it.
        if self.mapView.userTrackingMode != .followWithHeading {
            print("--- AXXYL MAP DEBUG: setupNavigationCamera() RECOVERING .followWithHeading ---")
            self.mapView.setUserTrackingMode(.followWithHeading, animated: true)
        }
        
        // ZOOM LOCK: Prevent MapKit from zooming out beyond 1500m during navigation.
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 1500)
        if self.mapView.cameraZoomRange.maxCenterCoordinateDistance != 1500 {
            self.mapView.setCameraZoomRange(zoomRange, animated: true)
        }
        
        // PITCH & CENTER ENFORCEMENT:
        // If the pitch is wrong, or if we have drifted too far from the user location
        let camera = self.mapView.camera
        if camera.pitch < 60 {
            print("--- AXXYL MAP DEBUG: setupNavigationCamera() Correcting Camera state. ---")
            
            // Re-create camera looking at the USER location
            if let userCoord = self.mapView.userLocation.location?.coordinate {
                let navCamera = MKMapCamera(lookingAtCenter: userCoord, fromDistance: 500, pitch: 70, heading: self.mapView.camera.heading)
                self.mapView.setCamera(navCamera, animated: true)
            } else {
                // Fallback if user location is nil
                let navCamera = self.mapView.camera
                navCamera.pitch = 70
                navCamera.centerCoordinateDistance = 500
                self.mapView.setCamera(navCamera, animated: true)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.mapView.setUserTrackingMode(.followWithHeading, animated: true)
        self.mapView.camera.heading = newHeading.magneticHeading
    }
}

// MARK:- MapViewDelegate
extension HomeViewController : MKMapViewDelegate {
    
    private func getNavigationPuckImage() -> UIImage {
        let size = CGSize(width: 44, height: 44)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 22, y: 6))
        path.addLine(to: CGPoint(x: 36, y: 36))
        path.addLine(to: CGPoint(x: 22, y: 28))
        path.addLine(to: CGPoint(x: 8, y: 36))
        path.close()
        
        // Add subtle shadow
        context.setShadow(offset: CGSize(width: 0, height: 2), blur: 4, color: UIColor.black.withAlphaComponent(0.3).cgColor)
        
        // Draw white border
        UIColor.white.setFill()
        path.fill()
        
        // Remove shadow for inner fill
        context.setShadow(offset: .zero, blur: 0, color: nil)
        
        // Draw inner blue arrow
        let innerPath = UIBezierPath()
        innerPath.move(to: CGPoint(x: 22, y: 11))
        innerPath.addLine(to: CGPoint(x: 32, y: 32))
        innerPath.addLine(to: CGPoint(x: 22, y: 26))
        innerPath.addLine(to: CGPoint(x: 12, y: 32))
        innerPath.close()
        
        UIColor(red: 26/255, green: 115/255, blue: 232/255, alpha: 1.0).setFill()
        innerPath.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
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
        
        if let subtitle = annotation.subtitle, subtitle == "NearByDriver" {
            // Use the navigation puck image for smooth GPS
            annotationView!.image = getNavigationPuckImage()
            
            // Rotate the car icon to match the direction of travel
            let bearing = LocationManager.managerObj.driverBearing
            let angle = CGFloat(bearing) * .pi / 180
            annotationView?.transform = CGAffineTransform(rotationAngle: angle)
        } else {
            let pinImage: UIImage?
            let title = annotation.subtitle!! + "_Route.png"
            pinImage = UIImage(named: title)
            annotationView!.image = pinImage
            annotationView?.transform = .identity
        }
        
        return annotationView
    }
    
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
//        renderer.lineWidth = 2
//        if (isFirstTimeMapRendered) {
//            renderer.strokeColor = UIColor.black
//        }else{
//            renderer.strokeColor = UIColor.clear
//        }
//        return renderer
//    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.black
            renderer.lineWidth = 4.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}


extension HomeViewController : WelcomePassengerViewDelegate {
    func viewPastTrips() {
        let sb = UIStoryboard(name: "Menu", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "BookingHistoryViewController")
        self.navigationController?.pushViewController(vcToOpen, animated: true)
    }
    
    func searchTxtFieldDidBeginEditing() {
        presentSearchViewController()
    }
    
}

extension HomeViewController: RouteLocationDelegate {
    func pushSelectVehicleWithRouteArray(routeLocations: [MapLocation]) {
        let routeArray = routeLocations.filter({ $0.latitude != nil })
        if routeArray.count > 1 {
            let sb = UIStoryboard(name: "Home", bundle: nil)
            let vcToOpen = sb.instantiateViewController(withIdentifier: "SelectVehicleTypeViewController") as! SelectVehicleTypeViewController
            vcToOpen.routeLocations = routeArray
            BookingService.instance.routeLocations = routeArray
            self.navigationController?.pushViewController(vcToOpen, animated: true)
        }
    }
}


extension HomeViewController : DriverOnWayViewDelegate {
    func navigateToCurrentLocation() {
        
    }
    
    func openProfile() {
        
    }
    
    func openMessageComposer() {
        
        guard let data = self.notificationData as? NotificationData else {
            return
        }
        
        self.sendSmsToNumber(data.vendorPhone)
    }
    
    func callDriver() {
        if let data = self.notificationData as? NotificationData {
            self.makeACallToNumber(data.vendorPhone)
        }
    }
    
    func changeDestination() {
        AlertManager.showErrorAlert(message: "This feature will be implemented in next phase.")
    }
    
    func cancelRide() {
        // TODO : show confirmation pop up
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        BookingService.instance.cancelRideInProgress { res in
            LoadingSpinner.manager.hideLoadingAnimation()
            if res.isSuccess() {
                DispatchQueue.main.async {
                    self.homeState = .search
                }
            }else{
                AlertManager.showErrorAlert(message: res.msg ?? "Failed to cancel ride request")
            }
            
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
        
    }
    
}

extension HomeViewController : MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
}

extension HomeViewController : TipsSelectionDelegate {
    func skipTip() {
        BookingService.instance.tipAmount = "0"
        self.navigateToPassengerTripPaymentViewController()
    }
    
    func addTipWithPercentage(percentage: Int) {
        var totalPrice = 0.0
        if let data = self.notificationData as? ArrivedEndNotificationData {
            totalPrice = Double(data.totalPrice) ?? 0.0
        }else{
            totalPrice = BookingService.instance.currentVehicleType?.total ?? 0.0
        }
        
        let tipAmount : Double = (totalPrice * Double(percentage)) / 100.0
        BookingService.instance.tipAmount = "\(tipAmount)"
        self.navigateToPassengerTripPaymentViewController()
    }
    
    func addTipAsAmount(amount: String) {
        BookingService.instance.tipAmount = amount
        self.navigateToPassengerTripPaymentViewController()
    }
}

extension HomeViewController : DriverStatusProtocol {
    func driverStatusChanged(online: Bool) {
        self.updateDriverStatus(online: online)
    }
    
    func updateDriverLocation(newLocation: CLLocation?){
        
        guard let loc = newLocation else {
            return
        }
        
        guard let clLoc = self.currentLocation else {
            self.currentLocation = loc
            self.sendDriverLocationToBackend(cord: loc.coordinate)
            return
        }
        
        
        let distance = loc.distance(from: clLoc)
        print("changed distance : \(distance)")
        if !distance.isLessThanOrEqualTo(20.0) {
            print("Driver moved more than \(distance) mtr so updating the location on backend")
            Logger.shared.log("Driver moved more than \(distance) mtr so updating the location on backend", level: .error)
            Logger.shared.log("#CALLING# sendDriverLocationToBackend", level: .info)
            self.sendDriverLocationToBackend(cord: loc.coordinate)
            self.currentLocation = newLocation
        }
        
        if LoginService.instance.currentUserType == .driver && !distance.isLessThanOrEqualTo(20.0) {
            if homeState == .driverArriving  {
                Logger.shared.log("#CALLING# Driver -> Passanger (START)", level: .info)
                self.routeFromDriverToPassengerLocation()
            } else if homeState == .driverTripStarted {
                Logger.shared.log("#CALLING# Driver -> Destination (STOP)", level: .info)
                self.routeFromDriverCurrentLocationToDestinationLocation()
            }
        }
    }
    
    func sendDriverLocationToBackend(cord: CLLocationCoordinate2D) {
        if LoginService.instance.currentUserType == .driver && DriverService.instance.isOnline {
            DriverService.instance.updateDriverLocation(cordinates: cord) { response in
                if response.isSuccess() {
                    Logger.shared.log("Driver Location Uploded Successfullly", level: .info)
                    // TODO : nothing to do?
                }
            } errorCallBack: { errMsg in
                // Nothing to show?
                print("Failed to update driver's location, check why it is happening?")
                Logger.shared.log("Failed to update driver's location, check why it is happening?", level: .info)
            }
        }
    }
    
    func updateDriverStatus(online: Bool) {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        
        DriverService.instance.updateDriverStatus(isOnline: online) { response in
            LoadingSpinner.manager.hideLoadingAnimation()
            if response.isSuccess() {
                DriverService.instance.isOnline = online
                if online, let curLoc = self.currentLocation {
                    // Send the current location immediately to update the driver location
                    Logger.shared.log("#CALLING# sendDriverLocationToBackend", level: .info)
                    self.sendDriverLocationToBackend(cord: curLoc.coordinate)
                }
            }else{
                self.welcomeDriverView.resetSwitchStatus(isOn: !online)
                AlertManager.showErrorAlert(message: response.msg ?? "Could not update your status")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
        
    }
}

extension HomeViewController : DriverRideAcceptRejectProtocol {
    func declinedRide() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.declineRide(rideId: self.rideRequestReceivedView.currentRideId) { response in
            LoadingSpinner.manager.hideLoadingAnimation()
            if response.isSuccess() {
                self.homeState = .driverHome
                DriverService.instance.driverRideIdInProgress = nil
                APNNotificationService.instance.clearCachedNotifications()
            }else{
                AlertManager.showErrorAlert(message: response.msg ?? "Failed to cancel the ride")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
        
    }
    
    func acceptedRide() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.acceptRideRequest(reqId: self.rideRequestReceivedView.currentRideId, userId: self.rideRequestReceivedView.userId, coordinates: self.currentLocation!.coordinate) { response in
            LoadingSpinner.manager.hideLoadingAnimation()
            if response.isSuccess() {
                self.homeState = .driverArriving
            }else{
                AlertManager.showErrorAlert(message: response.msg ?? "Failed to accept the ride")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
}

extension HomeViewController: DriverArrivingProtocol {
    
    func notifyUserAboutDriversArrival() {
            LoadingSpinner.manager.showLoadingAnimation(delegate: self)
            DriverService.instance.driverArrivedAtUserLocationSendNotificationRequest(userId: self.driverArrivingView.userId, coordinates: self.currentLocation!.coordinate) { response in
                LoadingSpinner.manager.hideLoadingAnimation()
                if response.isSuccess() {
                    self.homeState = .passengerNotified
                }else{
                    AlertManager.showErrorAlert(message: response.msg ?? "Failed to mark arrival")
                }
            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
            
        }
        
        func ihavearrived() {
            LoadingSpinner.manager.showLoadingAnimation(delegate: self)
            DriverService.instance.driverArrivedAtUserLocationRequest(userId: self.driverArrivingView.userId, coordinates: self.currentLocation!.coordinate) {[weak self] response in
                LoadingSpinner.manager.hideLoadingAnimation()
                if response.isSuccess() {
                    self?.notifyUserAboutDriversArrival()
                }else{
                    AlertManager.showErrorAlert(message: response.msg ?? "Failed to mark arrival")
                }
            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
            }
        }
    
    func callPassenger() {
        if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
            self.makeACallToNumber(data.UserPhone)
        }
    }
    
    func smsPassenger() {
        guard let data = self.notificationData as? DriverReceivedRideRequestNotificationData else {
            return
        }
        self.sendSmsToNumber(data.UserPhone)
    }
}

extension HomeViewController : PassengerNotifiedProtocol {
    func openMapInDrivingMode() {
        if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
            
            let components = data.pickuplatLong.components(separatedBy: ",")
            
            if components.count == 0 || components.count > 2 {
                print("Pick up lat long are either empty or more comma separated values are more than 2")
            }
            
//            let source = MKMapItem(coordinate: CLLocationCoordinate2D(latitude: Double(components[0].replacingOccurrences(of: " ", with: "")) ?? 0.0, longitude: Double(components[1].replacingOccurrences(of: " ", with: "")) ?? 0.0), name: data.pickupLocation)
//
            let components_drop = data.droplatLong.components(separatedBy: ",")
            
            if components_drop.count == 0 || components_drop.count > 2 {
                print("Drop lat long are either empty or more comma separated values are more than 2")
            }
            
            let destination = MKMapItem(coordinate: CLLocationCoordinate2D(latitude: Double(components_drop[0].replacingOccurrences(of: " ", with: "")) ?? 0.0, longitude: Double(components_drop[1].replacingOccurrences(of: " ", with: "")) ?? 0.0), name: data.dropLocation)
            
            MKMapItem.openMaps(
                with: [MKMapItem.forCurrentLocation(), destination],
                launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault]
            )
        }
    }
    
    func startRide() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.startServiceRequest(vendorId: self.passengerNotifiedView.userId, pickup: self.passengerNotifiedView.pickupLatLong) {[weak self] response in
            LoadingSpinner.manager.hideLoadingAnimation()
            if response.isSuccess() {
                self?.homeState = .driverTripStarted
                DispatchQueue.main.async {
                    self?.openMapInDrivingMode()
                }
            }else{
                AlertManager.showErrorAlert(message: response.msg ?? "Failed to start the ride")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    func driverCancelsRide() {
        LoadingSpinner.manager.showLoadingAnimation(delegate: self)
        DriverService.instance.cancelRideInProgress {[weak self] response in
            
            guard let weakSelf = self else { return }
                
            LoadingSpinner.manager.hideLoadingAnimation()
            if response.isSuccess() {
                weakSelf.homeState = .driverHome
                DriverService.instance.driverRideIdInProgress = nil
                APNNotificationService.instance.clearCachedNotifications()
                DispatchQueue.main.async {
                    weakSelf.clearRoutesAndAnnotations()
                }
            }else{
                AlertManager.showErrorAlert(message: response.msg ?? "Failed to cancel the ride")
            }
        } errorCallBack: { errMsg in
            LoadingSpinner.manager.hideLoadingAnimation()
            AlertManager.showErrorAlert(message: errMsg)
        }
    }
    
    func pnsmsPassenger() {
        guard let data = self.notificationData as? DriverReceivedRideRequestNotificationData else {
            return
        }
        self.sendSmsToNumber(data.UserPhone)
    }
    
    func pncallPassenger() {
        if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
            self.makeACallToNumber(data.UserPhone)
        }
    }
    
    func updateBackendWithWaitTimeStart() {
        guard let data = self.notificationData as? DriverReceivedRideRequestNotificationData else {
            return
        }
        DriverService.instance.updateDriverWaitTimeStart(reqId: data.reqId) { response in
            print("Update Wait Time API called ")
        } errorCallBack: { errMsg in
            print("Failed to Update Wait Time API " + errMsg)
        }
    }
}

extension HomeViewController : DriverTripStartProtocol {
    func driverEndsRide() {
        let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel)
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { action in
            self.endRideForDriver()
        }
        
        AlertManager.showCustomAlertWith("Are you sure you want to end this ride?", message: "", actions: [noAction, yesAction])
    }
    
    func navigateToTripDetailsScreen(data: DriverTripEndResponse) {
        let sb = UIStoryboard(name: "Home", bundle: nil)
        let vcToOpen = sb.instantiateViewController(withIdentifier: "driverridedetailsViewController") as! DriverRideDetailsViewController
        vcToOpen.tripData = data
        vcToOpen.delegate = self
        if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
            vcToOpen.emailId = data.userEmail
        }
        vcToOpen.modalPresentationStyle = .fullScreen
        self.present(vcToOpen,animated: true)
    }
    
    func endRideForDriver(){
        if let data = self.notificationData as? DriverReceivedRideRequestNotificationData {
            LoadingSpinner.manager.showLoadingAnimation(delegate: self)
            DriverService.instance.driverEndRide(vendorId: self.driverTripStartedView.userId, pickuplatLong: data.pickuplatLong, droplatLong:data.droplatLong , dropLocation: data.dropLocation, pickupLocation: data.pickupLocation) {[weak self] response in
                LoadingSpinner.manager.hideLoadingAnimation()
                if response.isSuccess() {
                    DispatchQueue.main.async {
                        self?.clearRoutesAndAnnotations()
                        self?.navigateToTripDetailsScreen(data: response)
                    }
                }else{
                    AlertManager.showErrorAlert(message: response.msg ?? "Failed to end the ride")
                }
            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        }
    }
}

// Passenger UI Updates
extension HomeViewController {
    
    func updateDriverLocationOnMap(response: DriverLocationResponse) {
        
        if self.homeState != .etaDriver {
            return
        }
        
        guard let loc =  response.response else {
            return
        }
        
        print("updating driver location on map \(String(describing: loc.lat)) :: \(String(describing: loc.long))")
        
        let driverCoordinate = CLLocationCoordinate2D(latitude: Double(loc.lat) ?? 0.0, longitude: Double(loc.long) ?? 0.0)
        
        guard let myloc = self.myCurrentLocation else {
            Logger.shared.log("my current location maplocation object is null", level: .error)
            return
        }
        
        let driverMapLoc = MapLocation(id: 1234, latitude: driverCoordinate.latitude, longitude: driverCoordinate.longitude)
        
        // Smoothly update the driver's annotation
        LocationManager.managerObj.updateDriverAnnotation(mapView: self.mapView, newCoordinate: driverCoordinate)
        
        // Update the route and ETA with specific padding for .etaDriver state
        let padding = UIEdgeInsets(top: 80, left: 60, bottom: 280, right: 60)
        LocationManager.managerObj.showRouteOnMap(mapView: self.mapView, locationArray: [driverMapLoc, myloc], padding: padding)
    }
    
    @objc func findWhereDriverIs(driverId:String) {
        print("Pooling driver's location")
        BookingService.instance.getDriversLocation(driverId: driverId) {[weak self] driverResponse in
            DispatchQueue.main.async {
                self?.updateDriverLocationOnMap(response: driverResponse)
            }
        } errorCallBack: { errMsg in
            print("Driver location not pooling, check why it is happening")
        }
    }
    
    func startPoolingDriverLocation(driverId: String) {
        self.findWhereDriverIs(driverId: driverId)
        self.driverPoolingTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {[weak self] timer in
            self?.findWhereDriverIs(driverId: driverId)
        })
    }
    
    func stopDriverLocationPooling() {
        if self.driverPoolingTimer != nil {
            self.driverPoolingTimer?.invalidate()
            self.driverPoolingTimer = nil
        }
        LocationManager.managerObj.clearOverlay(mapView: self.mapView)
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    func startPoolingNearByDrivers() {
        print("------>>>> start pooling near by drivers")
        self.nearByDriverTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {[weak self] timer in
            self?.showNearByCarsOnMap()
        })
    }
    
    func stopPoolingNearByDrivers() {
        print("------>>>> Stopping pooling near drivers")
        if self.nearByDriverTimer != nil {
            self.nearByDriverTimer?.invalidate()
            self.nearByDriverTimer = nil
        }
    }
    
    func updateDriverOnWayView(_ data : NotificationData) {
        if homeState == .etaDriver {
            if let rideDetails = BookingService.instance.currentVehicleType {
                driverOnWayView.amountLbl.text = rideDetails.displayTotalPrice()
                driverOnWayView.destinationLbl.text = "To " + BookingService.instance.getDestinationAddress()
                driverOnWayView.originAddressLbl.text = "From " + BookingService.instance.getOriginAddress()
                driverOnWayView.carNoLbl.text = data.car_number + " (\(data.carColor))"
                driverOnWayView.carModelLbl.text = data.carModel
                driverOnWayView.driverNameLbl.text = "Driver : \(data.vendorName)"
                if let imgURL = URL(string: data.vendorImage) {
                    driverOnWayView.driverProfilePhotoBtn.kf.setImage(with: imgURL, for: .normal)
                }
                
                // Show saved ETA or a loading placeholder in the new banner
                let savedEta = UserDefaults.standard.string(forKey: "ESTIMATED_TIME_FOR_TRAVEL") ?? "Calculating..."
                let savedDist = UserDefaults.standard.string(forKey: "ESTIMATED_DISTANCE_OF_TRAVEL") ?? "---"
                let distDisplay = savedDist.contains("miles") ? savedDist : "\(savedDist) miles"
                driverOnWayView.updateEtaBanner(time: savedEta, distance: distDisplay, animate: false)
            }
            
            self.startPoolingDriverLocation(driverId: data.vendorId)
        }
    }
    
    func clearRoutesAndAnnotations() {
        LocationManager.managerObj.clearOverlay(mapView: self.mapView)
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    func updatePassengerLocation(newLocation: CLLocation?){
        Logger.shared.log("#updatePassengerLocation:", level: .info)
        if LoginService.instance.currentUserType == .passenger {
            guard let loc = newLocation else {
                return
            }
            
            if homeState == .tripStarted {
                Logger.shared.log("#TRIP STARTED:", level: .error)
                Logger.shared.log("old loction:\(String(describing: self.currentLocation?.coordinate))", level: .error)
                Logger.shared.log("new loction:\(String(describing: newLocation?.coordinate))", level: .error)
                
                guard let clLoc = self.currentLocation else {
                    self.currentLocation = loc
                    return
                }
                
                let distance = loc.distance(from: clLoc)
                
                print("changed distance : \(distance)")
                
                if !distance.isLessThanOrEqualTo(20.0){
                    print("Passenger moved more than \(distance) mtr so updating the route on the map")
                    Logger.shared.log("Passenger moved more than \(distance) mtr so updating the location on backend", level: .error)
                    Logger.shared.log("#CALLING# Passanger -> Destination (STOP)", level: .info)
                    self.currentLocation = newLocation
                    self.routeFromPassengerToDropLocation()
                }
            } else if self.homeState == .search {
                self.currentLocation = loc
            }
        }
    }
    
    func routeFromPassengerToDropLocation(isFirstTime: Bool = false) {
        
        isFirstTimeMapRendered = isFirstTime;
        
        let coord = BookingService.instance.getDestinationCoordinates()
        let dropLocation = MapLocation(id: 1235, name: "Stop", latitude: coord.latitude, longitude: coord.longitude)
//        let driverLoc = MapLocation(id: 1234, latitude: 18.5678638, longitude: 73.7726889)
        
        guard let myloc = self.currentLocation else {
            // fatalError("my current location maplocation object is null")
            Logger.shared.log("my current location maplocation object is null", level: .error)
            return
        }
        
        let myMap = MapLocation(id: 1423, name: "NearByDriver", latitude: myloc.coordinate.latitude, longitude: myloc.coordinate.longitude)
        
        Logger.shared.log("Passanger -> Destination (STOP)", level: .debug)
        Logger.shared.log("routeFromPassengerToDropLocation:\n Source: \(String(describing: dropLocation.latitude)), \(String(describing: dropLocation.longitude)) Destination: \(String(describing: myMap.latitude)), \(String(describing: myMap.longitude))", level: .debug)
        
//        LocationManager.managerObj.addAnnotationOnMap(searchMode:false, mapview: self.mapView, locationArray: [myMap, dropLocation])
        LocationManager.managerObj.addAnnotationOnMapFromPassangerToEndRide(mapview: self.mapView, locationArray: [myMap, dropLocation])
        
        // Use specific padding for .tripStarted state
        let padding = UIEdgeInsets(top: 80, left: 60, bottom: 280, right: 60)
        LocationManager.managerObj.showRouteOnMap(mapView: self.mapView, locationArray: [myMap, dropLocation], padding: padding)
        //LocationManager.managerObj.showRouteOnMapAnimationNew(self.mapView, with: [myMap, dropLocation])
    
       // LocationManager.managerObj.showRouteWithCarMovingAnimationOnMap(mapView: self.mapView, locationArray: [myMap, dropLocation], isFirstTime: isFirstTime)
       // isFirstTimeMapRendered = false;
    }
    
    func updateTripStartedView(_ data : NotificationData) {
        if homeState == .tripStarted {
            if let rideDetails = BookingService.instance.currentVehicleType {
                tripStartForUserView.amountLbl.text = rideDetails.displayTotalPrice()
                tripStartForUserView.destinationLbl.text = "To " + BookingService.instance.getDestinationAddress()
                tripStartForUserView.originLbl.text = "From " + BookingService.instance.getOriginAddress()
                tripStartForUserView.cardNumberLbl.text = "Visa : \(BookingService.instance.currentPaymentMethod!.cardnum.getMaskedCardNum(longLength: false))"
                // Set saved ETA or placeholder in the new banner
                let savedEta = UserDefaults.standard.string(forKey: "ESTIMATED_TIME_FOR_TRAVEL") ?? "Calculating..."
                let savedDist = UserDefaults.standard.string(forKey: "ESTIMATED_DISTANCE_OF_TRAVEL") ?? "---"
                let distDisplay = savedDist.contains("miles") ? savedDist : "\(savedDist) miles"
                tripStartForUserView.updateEtaBanner(time: savedEta, distance: distDisplay, animate: false)
            }
        }
    }
    
    func updateScreenStateForPassenger() {
        if homeState == .search {
            self.welcomePassengerView.bottomConstriant.constant = 0
            self.driverOnWayView.bottomConstriant.constant = -600
            self.tripStartForUserView.bottomConstriant.constant = -600
            UIView.animate(withDuration: 0.5, delay: 1) {
                self.view.layoutIfNeeded()
            }
        }else if homeState == .driverWaiting {
            self.welcomePassengerView.bottomConstriant.constant = -600
            self.driverOnWayView.driverEtaStackView.isHidden = true
            self.driverOnWayView.driverWaitingStackView.isHidden = false
            self.driverOnWayView.bottomConstriant.constant = 0
            self.tripStartForUserView.bottomConstriant.constant = -600
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.view.layoutIfNeeded()
            }
            self.driverOnWayView.startDriverWaitTime()
        }else if homeState == .etaDriver {
            self.welcomePassengerView.bottomConstriant.constant = -600
            self.driverOnWayView.driverWaitingStackView.isHidden = true
            self.driverOnWayView.driverEtaStackView.isHidden = false
            self.driverOnWayView.bottomConstriant.constant = 0
            self.tripStartForUserView.bottomConstriant.constant = -600
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.view.layoutIfNeeded()
            }
            if let data = self.notificationData as? NotificationData {
                updateDriverOnWayView(data)
            }
        }else if homeState == .tripStarted {
            self.welcomePassengerView.bottomConstriant.constant = -600
            self.tripStartForUserView.bottomConstriant.constant = 0
            self.driverOnWayView.stopDriverWaitTime()
            self.driverOnWayView.bottomConstriant.constant = -600
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.view.layoutIfNeeded()
            }
            if let data = self.notificationData as? NotificationData {
                updateTripStartedView(data)
                routeFromPassengerToDropLocation(isFirstTime: true);
            }
        } else { // Empty State
            self.welcomePassengerView.bottomConstriant.constant = -600
            self.driverOnWayView.bottomConstriant.constant = -600
            self.tripStartForUserView.bottomConstriant.constant = -600
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func rideCanceledStateUpdate() {
        if self.homeState == .driverWaiting {
            self.driverOnWayView.stopDriverWaitTime()
            self.driverOnWayView.bottomConstriant.constant = -550
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func tripEndedForPassenger() {
        self.presentTipsViewController()
    }
    
    func showNearByCarsOnMap() {
        if self.homeState == .search && LoginService.instance.currentUserType ==  UserType.passenger {
            BookingService.instance.getdriversNearby(location: self.currentLocation!) {  uploadResponse in
                if uploadResponse.isSuccess() {
                    DispatchQueue.main.async {
                        var driverLocArray : [CLLocationCoordinate2D] = []
                        for nearDriver in uploadResponse.vendor {
                            if let latCordindates = Double(nearDriver.lat) , let longCordinates = Double(nearDriver.long) {
                                let latitude = CLLocationDegrees(latCordindates)
                                let longitude = CLLocationDegrees(longCordinates)
                                let obj = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                driverLocArray.append(obj)
                            }
                        }
                        LocationManager.managerObj.addCarAnnotationOnMap(mapview: self.mapView, driversLocationArray: driverLocArray)
                    }
                }else{
                    print("Show Drivers Near By Error: \(String(describing: uploadResponse.msg))")
                }
                
            } errorCallBack: { errMsg in
                LoadingSpinner.manager.hideLoadingAnimation()
                AlertManager.showErrorAlert(message: errMsg)
            }
        }
    }
}


// Driver UI Updates
extension HomeViewController {
    
//    func startWaitTimeTimerForDriver() {
//        self.driver5minWaitTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {[weak self] timer in
//            self?.findWhereDriverIs(driverId: driverId)
//        })
//    }
    
    func updateUIWithDriverStatus() {
        if self.homeState == .driverHome {
            self.welcomeDriverView.changeOnlineStatus(isOn: DriverService.instance.isOnline)
        }
    }
    
    func updateDriverRideRequestReceived(_ data : DriverReceivedRideRequestNotificationData) {
        if homeState == .driverNewRideRequest {
            self.rideRequestReceivedView.attachData(data: data)
        }
    }
    
    func updateDriverArriving(_ data : DriverReceivedRideRequestNotificationData) {
        if homeState == .driverArriving {
            self.driverArrivingView.attachData(data: data)
            self.routeFromDriverToPassengerLocation()
        }
    }
    
    func updatePassengerNotified(_ data : DriverReceivedRideRequestNotificationData) {
        if homeState == .passengerNotified {
            // start the 5 mins wait time timer
//            self.startWaitTimeTimerForDriver();
            self.passengerNotifiedView.attachData(data: data)
            self.passengerNotifiedView.startDriverWaitTime()
        }
    }
    
    func updateDriverTripStarted(_ data : DriverReceivedRideRequestNotificationData) {
        if homeState == .driverTripStarted {
            self.driverTripStartedView.attachData(data: data)
            self.routeFromDriverCurrentLocationToDestinationLocation()
        }
    }
    
    func routeFromDriverToPassengerLocation() {
        guard let data = self.notificationData as? DriverReceivedRideRequestNotificationData else {
            return
        }
        
        let components = data.pickuplatLong.components(separatedBy: ",")
        
        let dropLocation = MapLocation(id: 1235, name: "Start", latitude: Double(components[0].replacingOccurrences(of: " ", with: "")) ?? 0.0, longitude: Double(components[1].replacingOccurrences(of: " ", with: "")) ?? 0.0)
//        let dropLocation = MapLocation(id: 1234, name: "Stop", latitude: 16.689733, longitude: 74.172244)

        guard let myloc = self.currentLocation else {
            fatalError("my current location maplocation object is null")
        }
        
        let myMap = MapLocation(id: 1423, name: "NearByDriver", latitude: myloc.coordinate.latitude, longitude: myloc.coordinate.longitude)
        Logger.shared.log("Driver -> Passanger (START)", level: .debug)
        Logger.shared.log("routeFromDriverToPassengerLocation:\n Source: \(String(describing: dropLocation.latitude)), \(String(describing: dropLocation.longitude)) Destination: \(String(describing: myMap.latitude)), \(String(describing: myMap.longitude))", level: .debug)
        LocationManager.managerObj.addAnnotationOnMap(searchMode:false, mapview: self.mapView, locationArray: [myMap, dropLocation])
        LocationManager.managerObj.showRouteOnMap(mapView: self.mapView, locationArray: [myMap, dropLocation])
       // LocationManager.managerObj.showRouteWithCarMovingAnimationOnMap(mapView: self.mapView, locationArray: [myMap, dropLocation])
    }
    
    func routeFromDriverCurrentLocationToDestinationLocation() {
        
        guard let data = self.notificationData as? DriverReceivedRideRequestNotificationData else {
            return
        }
        
        let components = data.droplatLong.components(separatedBy: ",")
        
        let dropLocation = MapLocation(id: 1235, name: "Stop", latitude: Double(components[0].replacingOccurrences(of: " ", with: "")) ?? 0.0, longitude: Double(components[1].replacingOccurrences(of: " ", with: "")) ?? 0.0)
        
        guard let myloc = self.currentLocation else {
            fatalError("my current location maplocation object is null")
        }
        
        let myMap = MapLocation(id: 1423, name: "NearByDriver", latitude: myloc.coordinate.latitude, longitude: myloc.coordinate.longitude)
        Logger.shared.log("Driver -> Destination (STOP)", level: .debug)
        Logger.shared.log("routeFromDriverCurrentLocationToDestinationLocation:\n Source: \(String(describing: dropLocation.latitude)), \(String(describing: dropLocation.longitude)) Destination: \(String(describing: myMap.latitude)), \(String(describing: myMap.longitude))", level: .debug)
        
        //LocationManager.managerObj.addAnnotationOnMap(searchMode:false, mapview: self.mapView, locationArray: [myMap, dropLocation])
        LocationManager.managerObj.addAnnotationOnMapFromPassangerToEndRide(mapview: self.mapView, locationArray: [myMap, dropLocation])
        LocationManager.managerObj.showRouteOnMap(mapView: self.mapView, locationArray: [myMap, dropLocation])
        //LocationManager.managerObj.showRouteWithCarMovingAnimationOnMap(mapView: self.mapView, locationArray: [myMap, dropLocation])
    }
}

extension HomeViewController : DriverEndRideProtocol {
    func onTripEnd() {
        self.homeState = .driverHome
    }
}

extension HomeViewController : PassengerTripEnd {
    func tripEndedForPassengerAfterPayment() {
        self.homeState = .search
    }
}
