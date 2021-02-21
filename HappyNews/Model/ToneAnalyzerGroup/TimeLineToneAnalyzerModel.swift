//
//  TimeLineToneAnalyzerModel.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/09.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import Foundation
import ToneAnalyzer
import SwiftyJSON
import PKHUD


// MARK: - Protocol
// TimeLineViewControllerに値を返す
protocol DoneCatchTimeLineAnalyzerProtocol {
    func catchAnalyzer(joyOrOther: Bool)
}

// ▼参照しているclass
// NewsCount

// LanguageTranslatorModelで翻訳したニュースの感情を分析しNewsViewControllerへ返す
class TimeLineToneAnalyzerModel {
    
    
    // MARK: - Property
    // プロトコルのインスタンス
    var doneCatchTimeLineAnalyzerProtocol: DoneCatchTimeLineAnalyzerProtocol?
    
    // TimeLineViewControllerから渡ってくる値
    var timeLineToneAnalyzerAccessKey     : String?
    var timeLineToneAnalyzerAccessVersion : String?
    var timeLineToneAnalyzerAccessURL     : String?
    var timeLineToneAnalyText             : String
    
    // TimeLineViewControllerから値を受け取る
    init(toneAnalyzerApiKey: String, toneAnalyzerVersion: String, toneAnalyzerURL: String, toneAnalyzerText: String) {
        
        timeLineToneAnalyzerAccessKey     = toneAnalyzerApiKey
        timeLineToneAnalyzerAccessVersion = toneAnalyzerVersion
        timeLineToneAnalyzerAccessURL     = toneAnalyzerURL
        timeLineToneAnalyText             = toneAnalyzerText
    }
    
    
    // MARK: - setTimeLineToneAnalyzer
    // 感情分析開始
    func setTimeLineToneAnalyzer() {
        
        // API認証子
        let timeLineToneAnalyzerKey = WatsonIAMAuthenticator(apiKey: timeLineToneAnalyzerAccessKey!)
        let timeLineToneAnalyzer    = ToneAnalyzer(version: timeLineToneAnalyzerAccessVersion!, authenticator: timeLineToneAnalyzerKey)
        timeLineToneAnalyzer.serviceURL = timeLineToneAnalyzerAccessURL
        
        
        // リクエスト送信
        timeLineToneAnalyzer.tone(toneContent: .text(timeLineToneAnalyText)) {
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
            
            // toneAnalyzerResultTM = レスポンス結果
            guard let toneAnalyzerResultTM = response?.result else {
                print(error?.localizedDescription ?? "unknown error")
                return
            }
            
            // レスポンスのステータスコードで条件分岐
            let statusCode = response?.statusCode
            switch statusCode == Optional(200) {
            case true:
                // 取得対象をdocument_toneに設定し、JSON形式に整形
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                guard let toneAnalysisJSONTM = try? encoder.encode(toneAnalyzerResultTM.documentTone) else {
                    fatalError("Failed to encode to JSON.")
                }
                
                // 正常に分析されたテキストをSwiftyJSONのJSON型へ変換
                let toneAnalysisValueTM = JSON(toneAnalysisJSONTM)
                
                
                if toneAnalysisValueTM["tones"][NewsCount.zeroCount]["score"] > 0.5 && toneAnalysisValueTM["tones"][NewsCount.zeroCount]["tone_name"] == "Joy" || toneAnalysisValueTM["tones"][NewsCount.zeroCount]["tone_id"] == "joy" {
                    
                    // 値を返す
                    self.doneCatchTimeLineAnalyzerProtocol!.catchAnalyzer(joyOrOther: true)
                } else {
                    
                    // 値を返す
                    self.doneCatchTimeLineAnalyzerProtocol!.catchAnalyzer(joyOrOther: false)
                }
            case false:
                // statusCode = [400: "障害", 500: "内部システムエラー"]
                print("translation failure: \(statusCode)")
            }
        }
    }
}
