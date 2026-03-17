//
//  SerachTableTableViewCell.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 07/10/22.
//

import UIKit

protocol SearchCellDelegate: AnyObject {
    func didTapRemoveButtonInCell(_ cell: SearchTableViewCell)
    func textFieldStartEditingInCell(_ cell: SearchTableViewCell)
    func textFieldDataChangedInCell(_ cell: SearchTableViewCell)
    func textfieldEndEditingInCell(_ cell: SearchTableViewCell)
}

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tripImageView: UIImageView!
    @IBOutlet weak var locationTxtFld: UITextField!
    @IBOutlet weak var removeCellBtn: UIButton!
    @IBOutlet weak var upperPathConnectorView: UIView!
    @IBOutlet weak var lowerPathConnectorView: UIView!
    @IBOutlet weak var txtFldGradiantView: GradientView!
    
    weak var delegate: SearchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        locationTxtFld.tintColor = UIColor(red: 10.0/255.0, green: 102.0/255.0, blue: 226.0/255.0, alpha: 1)
        locationTxtFld.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func removeCellBtnClicked(_ sender: UIButton) {
        delegate?.didTapRemoveButtonInCell(self)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        delegate?.textFieldDataChangedInCell(self)
    }
}

extension SearchTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        txtFldGradiantView.borderWidth = 1
        txtFldGradiantView.borderColor = UIColor(red: 10.0/255.0, green: 102.0/255.0, blue: 226.0/255.0, alpha: 1)
        delegate?.textFieldStartEditingInCell(self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        txtFldGradiantView.borderWidth = 0
        delegate?.textfieldEndEditingInCell(self)
    }
    
}
