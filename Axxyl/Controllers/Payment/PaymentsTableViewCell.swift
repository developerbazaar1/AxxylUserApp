//
//  PaymentsTableViewCell.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 25/09/22.
//

import UIKit

class PaymentsTableViewCell: UITableViewCell {

    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var cardNumber: UILabel!
    
    func updateCellView(card: Card) {
        cardImage.image = UIImage(named: card.imageName)
        cardNumber.text = card.number
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setValuesToUI(cardDetails : UserCard){
        cardImage.image = UIImage(named: "Visa.png")
        cardNumber.text = cardDetails.cardnum.getMaskedCardNum(longLength: false)
    }
}
