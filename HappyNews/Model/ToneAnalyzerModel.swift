//
//  ToneAnalyzerModel.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/23.
//  Copyright © 2020 佐々木　謙. All rights reserved.

import Foundation
import ToneAnalyzer
import SwiftyJSON

//Controllerに値を渡す
protocol DoneCatchAnalyzerProtocol {
    func catchAnalyzer(arrayAnalyzerData: Array<Int>)
}

class ToneAnalyzerModel {
    
    //Controllerから渡ってくる値
    var toneAnalyzerAccessKey    : String?
    var toneAnalyzerAccessVersion: String?
    var toneAnalyzerAccessURL    : String?
    var toneAnalyzerArray        : [String] = []
    
    //JSON解析で使用
    var count      = 0
    var arrayCount = 50
    var toneAnalysisArray: [JSON] = []
    var joyCountArray    : [Int]  = []
    
    //429エラーが発生した場合に使用
    var errorResponse: String?
    var errorResult = JSON()
    
    
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
        
        //直列処理で使用するインスタンス
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue")
        
        for i in 0..<arrayCount {
            
            //直列処理開始
            dispatchGroup.enter()
            dispatchQueue.async(group: dispatchGroup) {
                print("#\(i)Start")
                
                //リクエスト送信
                toneAnalyzer.tone(toneContent: .text(self.toneAnalyzerArray[i])) {
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
                            case .some(429):
                                //429エラーが発生すると意図する値を作成してappend
                                self.errorResponse = "errorResponse 429 error occurred"
                                print(self.errorResponse)
                                self.errorResult = JSON(self.errorResponse)
                                self.toneAnalysisArray.append(self.errorResult)
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
                    
                    //toneAnalyzerResult = レスポンス結果
                    guard let toneAnalyzerResult = response?.result else {
                        print(error?.localizedDescription ?? "unknown error")
                        return
                    }
                    
                    //レスポンスのステータスコードで条件分岐
                    let statusCode = response?.statusCode
                    switch statusCode == Optional(200) {
                    case true:
                        //取得対象をdocument_toneに設定し、JSON形式に整形
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        guard let toneAnalysisJSON = try? encoder.encode(toneAnalyzerResult.documentTone) else {
                            fatalError("Failed to encode to JSON.")
                        }
                        
                        //正常に分析されたテキストをSwiftyJSONのJSON型へ変換
                        let toneAnalysisValue = JSON(toneAnalysisJSON)
                        
                        //感情分析結果を配列に保存
                        self.toneAnalysisArray.append(toneAnalysisValue)
                        
                        //全ての直列処理完了後に発火
                        if self.toneAnalysisArray.count == self.arrayCount {
                            print("All Process Done!")
                            //jsonAnalysisOfToneAnalyzerの呼び出し
                            self.jsonAnalysisOfToneAnalyzer()
                        }
                        
                    case false:
                        //ステータスコードの400範囲は障害、500範囲は内部システムエラー
                        print("analysis failure: \(statusCode)")
                    }
                }
                //直列処理完了
                print("#\(i)End")
                dispatchGroup.leave()
            }
        }
    }
    
    //先にfor文を呼び出したいのでclass内でメソッドを分ける
    func jsonAnalysisOfToneAnalyzer() {
        
        //感情分析結果が一つの配列に保存されているかの確認
        print("toneAnalysisArray: \(toneAnalysisArray.debugDescription)")
        print("toneAnalysisArray.count: \(toneAnalysisArray.count)")
        
        for i in 0...arrayCount-1 {
            
            //感情分析結果が"Joy" && score0.5以上の要素を検索(document_toneのみ取得した場合)
            if toneAnalysisArray[i]["tones"][count]["score"] > 0.5 && toneAnalysisArray[i]["tones"][count]["tone_name"] == "Joy" {
                
                //条件を満たした要素のindex番号の取得（-1で整合性）
                joyCountArray.append(toneAnalysisArray[0].count+i-1)
            }
        }
        //最後にappendされた配列をControllerへ返す
        self.doneCatchAnalyzerProtocol?.catchAnalyzer(arrayAnalyzerData: joyCountArray)
    }
}
