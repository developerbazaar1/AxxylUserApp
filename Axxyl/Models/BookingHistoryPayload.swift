//
//  BookingHistoryPayload.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 02/10/22.
//

import Foundation

struct BookingHistoryPayload : Encodable {
    var action:String
    var userId:String
    var usertype:String
}
