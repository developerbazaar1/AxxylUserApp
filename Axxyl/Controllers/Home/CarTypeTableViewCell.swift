//
//  CarTypeTableViewCell.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 08/10/22.
//

import UIKit

class CarTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var carNameLbl: UILabel!
    @IBOutlet weak var noOfSeatLbl: UILabel!
    @IBOutlet weak var carImgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setValues(type : CarCategory) {
//        priceLbl.text = "$\(Double(type.price)!)"
        priceLbl.text = type.displayTotalPrice()
        carNameLbl.text = type.name
        carImgView.image = UIImage(named: "\(type.name)_Car.png")//kf.setImage(with: URL(string: type.carTypeIcon))
        noOfSeatLbl.text = type.seats + " Seats"
    }

}
