//
//  NewHeaderView.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 17/10/22.
//

import UIKit

protocol NewHeaderViewProtocol : AnyObject  {
    var headerTitle : String { get }
    func backAction()
    var isBackEnabled : Bool { get }
}

@IBDesignable class NewHeaderView: UIView, NibLoadable {
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var buttonWidthConstraint: NSLayoutConstraint!
    weak var delegate : NewHeaderViewProtocol? {
        didSet {
            self.layoutIfNeeded()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
        updateUIAsRequired()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
        self.updateUIAsRequired()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.delegate?.backAction()
    }
    
    func updateUIAsRequired() {
        if delegate != nil && !delegate!.isBackEnabled {
            self.buttonWidthConstraint.constant = 0
        }
        self.headerLbl.text = self.delegate?.headerTitle ?? "Header title not provided"
    }
    
    func setConfiguration() {
        if delegate != nil && !delegate!.isBackEnabled {
            self.buttonWidthConstraint.constant = 0
        }
        self.headerLbl.text = self.delegate?.headerTitle ?? "Header title not provided"
        self.layoutIfNeeded()
    }
}

public protocol NibLoadable {
    static var nibName: String { get }
}

public extension NibLoadable where Self: UIView {
    
    static var nibName: String {
        return String(describing: Self.self) // defaults to the name of the class implementing this protocol.
    }
    
    static var nib: UINib {
        let bundle = Bundle(for: Self.self)
        return UINib(nibName: Self.nibName, bundle: bundle)
    }
    
    func setupFromNib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else { //fatalError("Error loading \(self) from nib")
            print("Error loading \(self) from nib")
            return
        }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
}
