//
//  CGFloatExtension.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 12/05/23.
//

import Foundation

extension CGFloat {
        var toRadians: CGFloat { return self * .pi / 180 }
        var toDegrees: CGFloat { return self * 180 / .pi }
    }
