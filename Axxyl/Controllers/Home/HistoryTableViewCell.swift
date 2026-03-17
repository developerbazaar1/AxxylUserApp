//
//  HistoryTableViewCell.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 07/10/22.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var placeTitleLbl: UILabel!
    @IBOutlet weak var placeAddressLbl: UILabel!
    @IBOutlet weak var placeTypeImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
