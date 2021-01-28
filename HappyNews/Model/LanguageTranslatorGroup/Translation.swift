//
//  TranslationResult.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/25.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import Foundation

// ▼関係するclass
// LanguageTranslatorModel

// JSON解析で扱う
class Translation {
    
    var translation: String?
    
    init(translation: String) {
        self.translation = translation
    }
}
