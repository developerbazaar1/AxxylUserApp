//
//  Media.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 26/01/23.
//

import UIKit
struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    init?(withImage image: UIImage?, forKey key: String) {
        let todayDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let result = formatter.string(from: todayDate)
        let tag = key.components(separatedBy: "file")
        self.key = key
        self.mimeType = "application/octet-stream" //"image/jpeg"
        self.filename = "IMG-\(result)-WA000\(tag[1]).jpg"
        guard let data = image?.jpegData(compressionQuality: 0.7) else { return nil }
        self.data = data
    }
}
