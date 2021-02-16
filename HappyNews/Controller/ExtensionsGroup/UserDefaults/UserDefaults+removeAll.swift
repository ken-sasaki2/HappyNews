//
//  UserDefaults+removeAll.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/07.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import Foundation

// UserDefaultsの全削除を可能に拡張
extension UserDefaults {
    func removeAll() {
        dictionaryRepresentation().forEach { removeObject(forKey: $0.key) }
    }
}
