//
//  LanguageTranslatorModel.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/23.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import Foundation
import LanguageTranslator
import SwiftyJSON

class LanguageTranslatorModel {
    
    //外部から渡ってくる値
    var translatorKey   : String?
    var version         : String?
    var serviceURL      : String?
    
    //NewsTableViewから値を受け取る
    init(translatorApiKey: String, translatorVersion: String, translatorURL: String) {
        
        translatorKey = translatorApiKey
        version       = translatorVersion
        serviceURL    = translatorURL
    }
    
    //JSON解析をおこなう
    
    //その値を返す
}
