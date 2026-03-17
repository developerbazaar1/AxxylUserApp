//
//  HeaderView.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 25/09/22.
//

import UIKit

protocol HeaderViewProtocol : AnyObject  {
    var headerTitle : String { get }
    func backAction()
    var isBackEnabled : Bool { get }
}

class HeaderView: UIView {

    @IBOutlet var titleLbl : UILabel?
    weak var delegate : HeaderViewProtocol?
    @IBOutlet var widthConstriant : NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
        delegate?.backAction()
    }
    
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        titleLbl?.text = delegate?.headerTitle
//        guard let _ = delegate else {
//
//            widthConstriant?.constant = 0
//            return
//        }
//
//
//        widthConstriant?.constant = 44
//    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
