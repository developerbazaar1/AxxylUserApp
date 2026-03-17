//
//  CarTableViewCell.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 03/12/22.
//

import UIKit

protocol CarCellDelegate: AnyObject {
    func didTapEditButtonInCell(_ cell: CarTableViewCell)
}

class CarTableViewCell: UITableViewCell {

    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var customBgView: UIView!
    @IBOutlet weak var carSelectRadioBtn: RadioButton!
    @IBOutlet weak var carNameLbl: UILabel!
    @IBOutlet weak var carColorLbl: UILabel!
    
    weak var delegate: CarCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customBgView.backgroundColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)
        customBgView.layer.borderWidth = 1;
        customBgView.layer.borderColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1).cgColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func radioButtonClicked(_ sender: RadioButton) {
        sender.isChecked = !sender.isChecked
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        delegate?.didTapEditButtonInCell(self)
    }
}
