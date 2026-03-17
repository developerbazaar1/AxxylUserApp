//
//  PaymentHistoryTableViewCell.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 26/01/23.
//

import UIKit

class PaymentHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var feeLbl: UILabel!
    @IBOutlet weak var monthYearLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
