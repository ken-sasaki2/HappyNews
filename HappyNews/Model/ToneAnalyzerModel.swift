//
//  ToneAnalyzerModel.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/23.
//  Copyright © 2020 佐々木　謙. All rights reserved.

import Foundation
import ToneAnalyzer
import SwiftyJSON

protocol DoneCatchAnalyzerProtocol {
    
    func catchAnalyzer(arrayAnalyzerData: Array<Any>)
}

class ToneAnalyzerModel {
    
    //Controllerから渡ってくる値
    var toneAnalyzerAccessKey    : String?
    var toneAnalyzerAccessVersion: String?
    var toneAnalyzerAccessURL    : String?
    var toneAnalyzerArray        : [String] = []
    
    //JSON解析で使用
    var count      = 0
    var arrayCount = 35
    var toneAnalysisValue = JSON()
    var toneAnalysisArray: [JSON] = []
    var joyCountArray    : [Any]  = []
    
    //プロトコルのインスタンス
    var doneCatchAnalyzerProtocol: DoneCatchAnalyzerProtocol?
    
    //NewsTableViewから値を受け取る
    init(toneAnalyzerApiKey: String, toneAnalyzerVersion: String, toneAnalyzerURL: String, translationArray: [String]) {
        
        toneAnalyzerAccessKey     = toneAnalyzerApiKey
        toneAnalyzerAccessVersion = toneAnalyzerVersion
        toneAnalyzerAccessURL     = toneAnalyzerURL
        toneAnalyzerArray         = translationArray
    }
    
    //感情分析開始
    func setToneAnalyzer() {
        
        //API認証子
        let toneAnalyzerKey = WatsonIAMAuthenticator(apiKey: toneAnalyzerAccessKey!)
        let toneAnalyzer    = ToneAnalyzer(version: toneAnalyzerAccessVersion!, authenticator: toneAnalyzerKey)
            toneAnalyzer.serviceURL = toneAnalyzerAccessURL
        
        for i in 0..<50 {
  
            //リクエスト送信
            toneAnalyzer.tone(toneContent: .text(toneAnalyzerArray[i])) {
                    response, error in

                    //エラー処理
                    if let error = error {
                        switch error {
                        case let .http(statusCode, message, metadata):
                            switch statusCode {
                            case .some(404):
                                print("Handle Not Found (404) exceptz1zion")
                            case .some(413):
                                print("Handle Request Too Large (413) exception")
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
                    //analysisResult = レスポンス結果
                    guard let toneAnalyzerResult = response?.result else {
                        print(error?.localizedDescription ?? "unknown error")
                        return
                    }

                    //レスポンスのステータスコードで条件分岐
                    let statusCode = response?.statusCode
                    switch statusCode == Optional(200) {
                    case true:
                        //分析結果のデータをJSON形式に整形
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        guard let toneAnalysisJSON = try? encoder.encode(toneAnalyzerResult) else {
                            fatalError("Failed to encode to JSON.")
                        }

                        //SwiftyJSONのJSON型へ変換
                        self.toneAnalysisValue = JSON(toneAnalysisJSON)
                        
                        //感情分析結果を配列に保存
                        self.toneAnalysisArray.append(self.toneAnalysisValue)
                        print("toneAnalysisArray: \(self.toneAnalysisArray)")
                        //感情分析結果がXMLの要素数と一致していれば実行
                        if self.toneAnalysisArray.count == self.arrayCount {
                            
                            //jsonAnalysisOfToneAnalyzerの呼び出し
                            self.jsonAnalysisOfToneAnalyzer()
                        }
                        
                    case false:
                        //ステータスコードの400範囲は障害、500範囲は内部システムエラー
                        print("analysis failure: \(statusCode)")
                    }
            }
        }
    }
    
    //先にfor文を呼び出したいのでclass内でメソッドを分ける
    func jsonAnalysisOfToneAnalyzer() {
        
        //感情分析結果が一つの配列に保存されているかの確認
        print("toneAnalysisArray: \(toneAnalysisArray)")
        print("toneAnalysisArray.count: \(toneAnalysisArray.count)")
        
        for i in 0...arrayCount-1 {
            
            //感情分析結果が"Joy" && score0.5以上の要素を検索
            if toneAnalysisArray[i]["document_tone"]["tones"][count]["score"] > 0.5 && toneAnalysisArray[i]["document_tone"]["tones"][count]["tone_name"] == "Joy" {
                
                //条件を満たした要素のindex番号の取得（-1で整合性）
                joyCountArray.append(toneAnalysisArray[0].count+i-1)
            }
        }
        //最後にappendされた配列をControllerへ返す
        self.doneCatchAnalyzerProtocol?.catchAnalyzer(arrayAnalyzerData: joyCountArray)
    }
}
