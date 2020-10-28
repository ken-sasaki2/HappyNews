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
    
    //規則を決める
    func catchAnalyzer(arrayAnalyzerData: Array<Analyzer>, resultCount: Int)
}

class ToneAnalyzerModel {
    
    //外部から渡ってくる値
    var analysisKey    : String?
    var version        : String?
    var serviceURL     : String?
    var analysisText   : String?
    var firstScore     : Float?
    var secondScore    : Float?
    var thirdScore     : Float?
    var firstToneName  : String?
    var secondToneName : String?
    var thirdToneName  : String?
    var analyzerArray = [Analyzer]()
    var doneCatchAnalyzerProtocol: DoneCatchAnalyzerProtocol?

    //JSON解析で使用
    var count = 0
    var length: Int?
    
    //NewsTableViewから値を受け取る
    init(analysisApiKey: String, analysisVersion: String, analysisURL: String, analysisContent: String) {
        
        analysisKey   = analysisApiKey
        version       = analysisVersion
        serviceURL    = analysisURL
        analysisText  = analysisContent
    }
    
    //感情分析
    func setToneAnalyzer() {
        
        //APIを認証するためのキーとversionとurlを定義
        let toneAnalyzerKey         = WatsonIAMAuthenticator(apiKey: analysisKey!)
        let toneAnalyzer            = ToneAnalyzer(version: version!, authenticator: toneAnalyzerKey)
            toneAnalyzer.serviceURL = serviceURL

        //sampleTextを分析（リクエスト送信）
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

          //データ処理
          guard let toneAnalysisResult = response?.result else {
            print(error?.localizedDescription ?? "unknown error")
            return
          }

          //レスポンスの結果で条件分岐
          let statusCode = response?.statusCode
            switch statusCode == Optional(200) {
            case true:
                //分析結果のデータをJSON形式に変換
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                guard let toneAnalysisJSON = try? encoder.encode(toneAnalysisResult) else {
                    fatalError("Failed to encode to JSON.")
                }

                //JSON解析(score)
                let toneAnalysisValue = JSON(toneAnalysisJSON)
                
                //感情分析結果の配列の要素数を取得し、その数によってJSON解析数を分岐
                self.length = toneAnalysisValue["document_tone"]["tones"].count
                if self.length == 1 {
                    
                    let  firstToneScore   = toneAnalysisValue["document_tone"]["tones"][self.count]["score"].float
                    self.firstScore       = ceil(firstToneScore! * 100)/100
                    self.firstToneName    = toneAnalysisValue["document_tone"]["tones"][self.count]["tone_name"].string
                } else if self.length == 2 {
                    
                    let  firstToneScore   = toneAnalysisValue["document_tone"]["tones"][self.count]["score"].float
                    self.firstScore       = ceil(firstToneScore! * 100)/100
                    self.firstToneName    = toneAnalysisValue["document_tone"]["tones"][self.count]["tone_name"].string
                    
                    let  secondToneScore  = toneAnalysisValue["document_tone"]["tones"][self.count+1]["score"].float
                    self.secondScore      = ceil(secondToneScore! * 100)/100
                    self.secondToneName   = toneAnalysisValue["document_tone"]["tones"][self.count+1]["tone_name"].string
                } else if self.length == 3 {
                    
                    let  firstToneScore   = toneAnalysisValue["document_tone"]["tones"][self.count]["score"].float
                    self.firstScore       = ceil(firstToneScore! * 100)/100
                    self.firstToneName    = toneAnalysisValue["document_tone"]["tones"][self.count]["tone_name"].string
                    
                    let  secondToneScore  = toneAnalysisValue["document_tone"]["tones"][self.count+1]["score"].float
                    self.secondScore      = ceil(secondToneScore! * 100)/100
                    self.secondToneName   = toneAnalysisValue["document_tone"]["tones"][self.count+1]["tone_name"].string
                    
                    let thirdToneScore = toneAnalysisValue["document_tone"]["tones"][self.count+2]["score"].float
                    self.thirdScore    = ceil(thirdToneScore! * 100)/100
                    self.thirdToneName = toneAnalysisValue["document_tone"]["tones"][self.count+2]["tone_name"].string
                }
                
                print("cheack: \(toneAnalysisValue)")
    
                //構造体Analyzerに感情分析結果を追加
                self.analyzerArray.append(Analyzer(firstScore: self.firstScore, secondScore: self.secondScore, thirdScore: self.thirdScore, firstToneName: self.firstToneName, secondToneName: self.secondToneName, thirdToneName: self.thirdToneName))
                
                //NewsTableViewControllerへ値を渡す
                self.doneCatchAnalyzerProtocol?.catchAnalyzer(arrayAnalyzerData: self.analyzerArray, resultCount: self.analyzerArray.count)

            case false:
                //ステータスコードの表示(200範囲は成功、400範囲は障害、500範囲は内部システムエラー)
                print("analysis failure: \(statusCode)")
            }
        }
    }
}
