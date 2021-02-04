//
//  ToneAnalyzerModel.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/23.
//  Copyright © 2020 佐々木　謙. All rights reserved.

import Foundation
import ToneAnalyzer
import SwiftyJSON
import PKHUD


// MARK: - Protocol
// NewsViewControllerに値を返す
protocol DoneCatchAnalyzerProtocol {
    func catchAnalyzer(arrayAnalyzerData: Array<Int>)
}

// ▼参照しているclass
// NewsCount
// UserDefault

// LanguageTranslatorModelで翻訳したニュースの感情を分析しNewsViewControllerへ返す
class ToneAnalyzerModel {
    
    
    // MARK: - Property
    // プロトコルのインスタンス
    var doneCatchAnalyzerProtocol: DoneCatchAnalyzerProtocol?
    
    // JSON解析で扱う
    var toneAnalysisArray: [JSON] = []
    var joyCountArray    : [Int]  = []
    
    // API通信時に429エラーが発生した値を保存
    var errorResponseTA: String?
    var errorResultTA = JSON()
    
    // NewsViewControllerから渡ってくる値
    var toneAnalyzerAccessKey    : String?
    var toneAnalyzerAccessVersion: String?
    var toneAnalyzerAccessURL    : String?
    var toneAnalyzerArray        : [String] = []
    
    // NewsViewControllerから値を受け取る
    init(toneAnalyzerApiKey: String, toneAnalyzerVersion: String, toneAnalyzerURL: String, translationArray: [String]) {
        
        toneAnalyzerAccessKey     = toneAnalyzerApiKey
        toneAnalyzerAccessVersion = toneAnalyzerVersion
        toneAnalyzerAccessURL     = toneAnalyzerURL
        toneAnalyzerArray         = translationArray
    }
    
    
    // MARK: - SetToneAnalyzer
    // 感情分析開始
    func setToneAnalyzer() {
        
        // API認証子
        let toneAnalyzerKey = WatsonIAMAuthenticator(apiKey: toneAnalyzerAccessKey!)
        let toneAnalyzer    = ToneAnalyzer(version: toneAnalyzerAccessVersion!, authenticator: toneAnalyzerKey)
        toneAnalyzer.serviceURL = toneAnalyzerAccessURL
        
        // 直列処理で扱うインスタンス
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue")
        
        for i in (0..<NewsCount.itemCount).reversed() {
            
            // 直列処理開始(レスポンスを投げたリクエスト順に受け取るため)
            dispatchGroup.enter()
            dispatchQueue.async(group: dispatchGroup) {
                
                // リクエスト送信
                toneAnalyzer.tone(toneContent: .text(self.toneAnalyzerArray[i])) {
                    response, error in
                    
                    // エラー処理
                    if let error = error {
                        switch error {
                        case let .http(statusCode, message, metadata):
                            switch statusCode {
                            
                            // 429エラーが発生した場合
                            case .some(429):
                                // errorResponseTAに文字列を代入後、JSON型に変換してappend
                                self.errorResponseTA = "TA: errorResponse 429 error occurred"
                                print(self.errorResponseTA)
                                self.errorResultTA = JSON(self.errorResponseTA)
                                self.toneAnalysisArray.append(self.errorResultTA)
                                
                                // 429エラーが多発してitemCountに達した場合
                                if self.toneAnalysisArray.count == NewsCount.itemCount {
                                    
                                    // API通信時のエラー結果を保存
                                    UserDefault.standard.set("TA: 429エラー多発", forKey: "TA: many429Errors.")
                                    
                                    // 感情分析が失敗したことをユーザーに伝える
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        HUD.show(.label("予期せぬエラー発生\nアプリを再起動してください"))
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            HUD.hide(animated: true)
                                        }
                                    }
                                }
                            
                            // 429エラー以外が発生した場合
                            default:
                                if let statusCode = statusCode {
                                    print("Error - code: \(statusCode), \(message ?? "")")
                                    
                                    // API通信時のエラー結果を保存
                                    UserDefault.standard.set("予期せぬエラー発生", forKey: "TA: errorOccurred")
                                    
                                    // 感情分析が失敗したことをユーザーに伝える
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        HUD.show(.label("予期せぬエラー発生\nアプリを再起動してください"))
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            HUD.hide(animated: true)
                                        }
                                    }
                                }
                            }
                        default:
                            print(error.localizedDescription)
                        }
                        return
                    }
                    
                    // toneAnalyzerResult = レスポンス結果
                    guard let toneAnalyzerResult = response?.result else {
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
                        guard let toneAnalysisJSON = try? encoder.encode(toneAnalyzerResult.documentTone) else {
                            fatalError("Failed to encode to JSON.")
                        }
                        
                        // 正常に分析されたテキストをSwiftyJSONのJSON型へ変換
                        let toneAnalysisValue = JSON(toneAnalysisJSON)
                        
                        // 感情分析結果を配列に保存
                        self.toneAnalysisArray.append(toneAnalysisValue)
                        
                        // 直列処理完了後にjsonAnalysisOfToneAnalyzerを呼び出す
                        if self.toneAnalysisArray.count == NewsCount.itemCount {
                            
                            print("All Process Done!")
                            self.jsonAnalysisOfToneAnalyzer()
                        }
                        
                    case false:
                        // statusCode = [400: "障害", 500: "内部システムエラー"]
                        print("translation failure: \(statusCode)")
                    }
                }
                // 直列処理完了
                dispatchGroup.leave()
            }
        }
    }
    
    
    // MARK: - JsonAnalysisOfToneAnalyzer
    // 感情分析結果のJSON解析をおこないNewsViewControllerへ値を返すメソッド
    func jsonAnalysisOfToneAnalyzer() {
        
        // 感情分析結果が正常に保存されているか確認
        print("toneAnalysisArray: \(toneAnalysisArray.debugDescription)")
        print("toneAnalysisArray.count: \(toneAnalysisArray.count)")
        
        for i in 0..<NewsCount.itemCount {
            
            // 感情分析結果が"Joy" && score0.5以上の要素を検索
            if toneAnalysisArray[i]["tones"][NewsCount.zeroCount]["score"] > 0.7 && toneAnalysisArray[i]["tones"][NewsCount.zeroCount]["tone_name"] == "Joy" || toneAnalysisArray[i]["tones"][NewsCount.zeroCount]["tone_id"] == "joy" {
                
                // 条件を満たした要素のindex番号を取得（-1で整合性）
                joyCountArray.append(toneAnalysisArray[NewsCount.zeroCount].count+i-1)
            }
        }
        // joyCountArrayをNewsViewControllerへ返す
        self.doneCatchAnalyzerProtocol?.catchAnalyzer(arrayAnalyzerData: joyCountArray)
    }
}
