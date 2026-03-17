//
//  PassengerPaymentPayload.swift
//  Axxyl
//
//  Created by Seema on 31/03/24.
//

import Foundation

struct PaymentTransId: Codable {
    var card_number: String
    var expiration_date: String
    var card_code: String
    var fare_amount: String
}

struct PassengerPaymentPayload: Codable {
    var action = Actions.processPayment.rawValue
    var customer_id: String
    var driver_id: String
    var trip_id: String
    var source: String
    var destination: String
    var paymentTransId: PaymentTransId?
}

// MARK: - Stripe Integration Models

struct StripePaymentIntentPayload: Codable {
    var action = Actions.createPaymentIntent.rawValue
    var tripId: String
    var amount: String
    var currency: String = "usd"
}

struct StripePaymentIntentResponse: Codable {
    var status: String
    var clientSecret: String?
    var msg: String?
    
    func isSuccess() -> Bool {
        return status.lowercased() == "success" || status.lowercased() == "true" || status == "1"
    }
}

struct StripeConfirmPaymentPayload: Codable {
    var action = Actions.confirmPayment.rawValue
    var tripId: String
}
