//
//  TimeLineTranslatorModel.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/09.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import Foundation
import LanguageTranslator
import SwiftyJSON
import PKHUD

// ▼参照しているclass
// NewsCount
// Translation


// MARK: - Protocol
// TimeLineViewControllerに値を返す
protocol DoneCatchTimeLineTranslationProtocol {
    func catchTranslation(timeLineTranslationText: String)
}

// タイムライン投稿ページのテキストを翻訳してTimeLineViewControllerへ返す
class TimeLineTranslatorModel {
    
    
    // MARK: - Property
    // プロトコルのインスタンス
    var doneCatchTimeLineTranslationProtocol: DoneCatchTimeLineTranslationProtocol?
    
    // TimeLineViewControllerから渡ってくる値
    var timeLineTranslatorAccessKey    : String?
    var timeLineTranslatorAccessversion: String?
    var timeLineTranslatorAccessURL    : String?
    var timeLineText                   : String
    
    // TimeLineViewControllerから値を受け取る
    init(timeLineTranslatorApiKey: String, timeLineTranslatorVersion: String, timeLineTranslatorURL: String, timeLineBody: String) {
        
        timeLineTranslatorAccessKey     = timeLineTranslatorApiKey
        timeLineTranslatorAccessversion = timeLineTranslatorVersion
        timeLineTranslatorAccessURL     = timeLineTranslatorURL
        timeLineText                    = timeLineBody
    }
    
    
    // MARK: - setTimeLineTranslator
    // TimeLine投稿内容の翻訳開始
    func setTimeLineTranslator() {
        
        // API認証子
        let timeLineTranslatorKey = WatsonIAMAuthenticator(apiKey: timeLineTranslatorAccessKey!)
        let timeLineTranslator    = LanguageTranslator(version: timeLineTranslatorAccessversion!, authenticator: timeLineTranslatorKey)
            timeLineTranslator.serviceURL = timeLineTranslatorAccessURL
        
        // リクエスト送信
        timeLineTranslator.translate(text: [timeLineText], modelID: "ja-en") {
            response, error in
            
            // エラー処理
            if let error = error {
                switch error {
                case let .http(statusCode, message, metadata):
                    switch statusCode {
                    default:
                        if let statusCode = statusCode {
                            print("Error - code: \(statusCode), \(message ?? "")")
                        }
                    }
                default:
                    print(error.localizedDescription)
                }
                return
            }
            
            // レスポンス結果を保存
            guard let translationResultTM = response?.result else {
                print(error?.localizedDescription ?? "unknown error")
                return
            }
            
            // レスポンスのステータスコードで条件分岐
            let statusCode = response?.statusCode
            switch statusCode == Optional(200) {
            case true:
                // レスポンス結果をJSON形式に整形
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                guard let translationJSONTM = try? encoder.encode(translationResultTM) else {
                    fatalError("Failed to encode to JSON.")
                }
                
                // SwiftyJSONのJSON型へ変換
                let translationValueTM: JSON = JSON(translationJSONTM)
                
                // translation = 翻訳結果（JSON解析結果）
                let translationTM = Translation(translation: translationValueTM["translations"][NewsCount.zeroCount]["translation"].string!)
                
                // 値を返す
                self.doneCatchTimeLineTranslationProtocol?.catchTranslation(timeLineTranslationText: translationTM.translation!)
                
            case false:
                // statusCode = [400: "障害", 500: "内部システムエラー"]
                print("translation failure: \(statusCode)")
            }
        }
    }
}
