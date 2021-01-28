//
//  UIColor+Colors.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/12/15.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import Foundation
import UIKit

// 16進数color機能拡張
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let v = Int("000000" + hex, radix: 16) ?? 0
        let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
        let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
        let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }
}
