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
    
    func catchAnalyzer(arrayAnalyzerData: Array<Analyzer>, resultCount: Int)
}

class ToneAnalyzerModel {
    
    //Controllerから渡ってくる値
    var toneAnalyzerAccessKey    : String?
    var toneAnalyzerAccessVersion: String?
    var toneAnalyzerAccessURL    : String?
    var analysisText             : String?
    
    //Controllerに値を返すときに使用
    var analyzerArray = [Analyzer]()
    var doneCatchAnalyzerProtocol: DoneCatchAnalyzerProtocol?

    //JSON解析で使用
    var count = 0
    
    //NewsTableViewから値を受け取る
    init(toneAnalyzerApiKey: String, toneAnalyzerVersion: String, toneAnalyzerURL: String, toneAnalyzerText: String) {
        
        toneAnalyzerAccessKey     = toneAnalyzerApiKey
        toneAnalyzerAccessVersion = toneAnalyzerVersion
        toneAnalyzerAccessURL     = toneAnalyzerURL
        analysisText              = toneAnalyzerText
    }
    
    //感情分析開始
    func setToneAnalyzer() {
        
        //API認証子
        let toneAnalyzerKey = WatsonIAMAuthenticator(apiKey: toneAnalyzerAccessKey!)
        let toneAnalyzer    = ToneAnalyzer(version: toneAnalyzerAccessVersion!, authenticator: toneAnalyzerKey)
            toneAnalyzer.serviceURL = toneAnalyzerAccessURL

        //リクエスト送信
        toneAnalyzer.tone(toneContent: .text(analysisText!)) {
          response, error in

          //エラー処理
          if let error = error {
            switch error {
            case let .http(statusCode, message, metadata):
                switch statusCode {
                case .some(404):
                    // Handle Not Found (404) exceptz1zion
                    print("Not found")
                case .some(413):
                    // Handle Request Too Large (413) exception
                    print("Payload too large")
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
          guard let analysisResult = response?.result else {
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
                guard let analysisJSON = try? encoder.encode(analysisResult) else {
                    fatalError("Failed to encode to JSON.")
                }

                //SwiftyJSONのJSON型へ変換
                let toneAnalysisValue = JSON(analysisJSON)
                
                //感情分析結果が"Joy"&"Score"が0.5以上なら値を取得
                if toneAnalysisValue["document_tone"]["tones"][self.count]["tone_name"] == "Joy" && toneAnalysisValue["document_tone"]["tones"][self.count]["score"] > 0.5 {

                    //analyzer = Joy"&"Score"が0.5以上の感情分析結果
                    let analyzer = Analyzer(toneScore: toneAnalysisValue["document_tone"]["tones"][self.count]["score"].float,toneName: toneAnalysisValue["document_tone"]["tones"][self.count]["tone_name"].string)
                    
                    //感情分析結果を配列に保存
                    self.analyzerArray.append(analyzer)

                    print(self.analyzerArray.count)
                    print(self.analyzerArray.debugDescription)
                } 

            case false:
                //ステータスコードの400範囲は障害、500範囲は内部システムエラー
                print("analysis failure: \(statusCode)")
            }
            //NewsTableViewControllerへ値を渡す
            self.doneCatchAnalyzerProtocol?.catchAnalyzer(arrayAnalyzerData: self.analyzerArray, resultCount: self.analyzerArray.count)
        }
    }
}
