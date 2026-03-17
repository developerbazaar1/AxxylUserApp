//
//  DriverOnWayView.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 23/10/22.
//

import UIKit

protocol DriverOnWayViewDelegate : AnyObject {
    func navigateToCurrentLocation()
    func openProfile()
    func openMessageComposer()
    func callDriver()
    func changeDestination()
    func cancelRide()
}

let waitTime : TimeInterval = 1 * 60; // seconds

class DriverOnWayView: UIView {

    @IBOutlet var amountLbl: UILabel!
    @IBOutlet var destinationLbl: UILabel!
    @IBOutlet var originAddressLbl: UILabel!
    @IBOutlet var carNoLbl: UILabel!
    @IBOutlet var carModelLbl: UILabel!
    @IBOutlet var driverNameLbl: UILabel!
    weak var delegate : DriverOnWayViewDelegate?
    @IBOutlet var driverEtaStackView : UIStackView!
    @IBOutlet var driverWaitingStackView: UIStackView!
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    @IBOutlet var driverProfilePhotoBtn: UIButton!
    @IBOutlet var msgBtn: UIButton!
    @IBOutlet var callBtn: UIButton!
    @IBOutlet var etaBtn: UIButton!
    var waitTimer : Timer?
    @IBOutlet var waitingTimeLbl: UILabel!
    var remainingWaitTime : TimeInterval = waitTime
    
    // Programmatic ETA Banner Components
    private let etaBannerContainer = UIView()
    private let etaTimeLabel = UILabel()
    private let etaDistanceLabel = UILabel()
    private let etaIconLabel = UILabel() // For the 🚗/📍 icons
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupEtaBanner()
        // Hide legacy button as per redesign
        etaBtn.isHidden = true
        // If it's in a stack view, we might need to remove it or hide it
        etaBtn.alpha = 0
    }
    
    private func setupEtaBanner() {
        // 1. Configure Container
        etaBannerContainer.backgroundColor = UIColor(red: 0.918, green: 0.957, blue: 1.0, alpha: 1.0) // #EAF4FF
        etaBannerContainer.layer.cornerRadius = 12
        etaBannerContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Find the main stack view or superview to attach to
        // Looking at the storyboard, there's a view xWt-dQ-aY8 containing the gJ6-2C-nxR stack view.
        // We want to insert the banner at the VERY TOP of the white card.
        
        if let mainStack = self.subviews.first?.subviews.first as? UIStackView {
            mainStack.insertArrangedSubview(etaBannerContainer, at: 0)
        } else {
            // Fallback if structure is different
            self.addSubview(etaBannerContainer)
            NSLayoutConstraint.activate([
                etaBannerContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
                etaBannerContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
                etaBannerContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
            ])
        }
        
        // 2. Configure Labels
        etaTimeLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold) // Reduced to 20pt
        etaTimeLabel.textColor = .black
        etaTimeLabel.text = "Calculating..."
        etaTimeLabel.numberOfLines = 0 // Allow wrap to next line
        etaTimeLabel.lineBreakMode = .byWordWrapping
        etaTimeLabel.adjustsFontSizeToFitWidth = true // Further safety
        etaTimeLabel.minimumScaleFactor = 0.7
        
        etaDistanceLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        etaDistanceLabel.textColor = .darkGray
        etaDistanceLabel.text = "---"
        
        etaIconLabel.font = UIFont.systemFont(ofSize: 24)
        etaIconLabel.text = "🚗"
        
        // 3. Layout with Stack Views
        let textStack = UIStackView(arrangedSubviews: [etaTimeLabel, etaDistanceLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        
        let contentStack = UIStackView(arrangedSubviews: [etaIconLabel, textStack])
        contentStack.axis = .horizontal
        contentStack.spacing = 12
        contentStack.alignment = .center
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        etaBannerContainer.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: etaBannerContainer.topAnchor, constant: 12),
            contentStack.bottomAnchor.constraint(equalTo: etaBannerContainer.bottomAnchor, constant: -12),
            contentStack.leadingAnchor.constraint(equalTo: etaBannerContainer.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: etaBannerContainer.trailingAnchor, constant: -16)
        ])
    }
    
    func updateEtaBanner(time: String, distance: String, animate: Bool = true) {
        let updateBlock = {
            if time.contains("0 min") || time.contains("Reaching") {
                self.etaTimeLabel.text = "Arriving now"
            } else {
                self.etaTimeLabel.text = "Arriving in \(time)"
            }
            self.etaDistanceLabel.text = "📍 \(distance)"
            self.etaIconLabel.text = "🚗"
        }
        
        if animate {
            UIView.transition(with: etaBannerContainer, duration: 0.3, options: .transitionCrossDissolve, animations: updateBlock, completion: nil)
        } else {
            updateBlock()
        }
    }
    
    private func styleEtaButton() {
        // Legacy - no longer needed but kept for safety
    }
    
    @IBAction func currentLocationBtnTapped(_ sender: Any) {
        print("currentLocationBtnTapped")
        delegate?.navigateToCurrentLocation()
    }
    
    @IBAction func profileBtnTapped(_ sender: Any) {
        print("profileBtnTapped")
        delegate?.openProfile()
    }
    
    @IBAction func messageBtnTapped(_ sender: Any) {
        print("messageBtnTapped")
        delegate?.openMessageComposer()
    }
    
    @IBAction func callBtnTapped(_ sender: Any) {
        print("callBtnTapped")
        delegate?.callDriver()
    }
    
    @IBAction func changeDestinationBtnTapped(_ sender: Any) {
        print("changeDestinationBtnTapped")
        delegate?.changeDestination()
    }
    
    @IBAction func cancelRideBtnTapped(_ sender: Any) {
        print("cancelRideBtnTapped")
        delegate?.cancelRide()
    }
    
    func stringFromTime(interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter.string(from: interval)!
    }

    @objc func updateWaitTime() {
//        if remainingWaitTime > 0 {
//            remainingWaitTime = remainingWaitTime - 1
//            self.waitingTimeLbl.text = stringFromTime(interval: remainingWaitTime)
//        }else{
//            self.stopDriverWaitTime()
//        }
        remainingWaitTime = remainingWaitTime - 1
        self.waitingTimeLbl.text = stringFromTime(interval: remainingWaitTime)
    }
    
    func startDriverWaitTime() {
        if self.waitTimer != nil {
            self.waitTimer?.invalidate()
            self.waitTimer = nil
        }
        
        self.waitTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateWaitTime), userInfo: nil, repeats: true)
    }
    
    func stopDriverWaitTime() {
        if self.waitTimer != nil {
            self.remainingWaitTime = waitTime
            self.waitTimer?.invalidate()
            self.waitTimer = nil
        }
    }
}
