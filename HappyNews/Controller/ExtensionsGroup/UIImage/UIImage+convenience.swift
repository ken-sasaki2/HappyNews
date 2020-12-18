//
//  UIImage+convenience.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/12/18.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    public convenience init(url: String) {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            self.init(data: data)!
            return
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        self.init()
    }
}
