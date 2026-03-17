//
//  Card.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 27/09/22.
//

import Foundation

struct Card {
    var name: String
    var number: String
    var expiryMonth: Int
    var expiryYear: Int
    var imageName: String
    
    init(name: String, number: String, expiryMonth: Int, expiryYear: Int, imageName: String) {
        self.name = name
        self.number = number
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.imageName = imageName
    }
}
