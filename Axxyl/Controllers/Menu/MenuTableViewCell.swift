//
//  MenuTableViewCell.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 29/09/22.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var menuItemImage: UIImageView!
    @IBOutlet weak var menuItemLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
