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

protocol DoneCatchTranslationProtocol {
    
    //規則を決める
    func catchData(arrayData: Array<Translation>, resultCount: Int)
}

class LanguageTranslatorModel {

    //外部から渡ってくる値
    var translatorKey: String?
    var version      : String?
    var serviceURL   : String?
    var analysisText : String?
    var translation  : String?
    var translationArray = [Translation]()
    var doneCatchTranslationProtocol: DoneCatchTranslationProtocol?

    //JSON解析で使用
    var count = 0

    //NewsTableViewから値を受け取る
    init(translatorApiKey: String, translatorVersion: String, translatorURL: String, sampleText: String) {

        translatorKey = translatorApiKey
        version       = translatorVersion
        serviceURL    = translatorURL
        analysisText  = sampleText
    }

    //JSON解析をおこなう
    func setLanguageTranslator() {

        //APIを認証するためのキーとversionとurlを定義
        let languageTranslatorKey = WatsonIAMAuthenticator(apiKey: translatorKey!)
        let translator            = LanguageTranslator(version: version!, authenticator: languageTranslatorKey)
        translator .serviceURL    = serviceURL

        //enからjaに翻訳（リクエスト送信）
        translator.translate(text: [analysisText!], modelID: "en-ja") {
            response, error in

            //エラー処理
            if let error = error {
                switch error {
                case let .http(statusCode, message, metadata):
                  switch statusCode {
                  case .some(404):
                    // Handle Not Found (404) exception
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
            guard let translationResult = response?.result else {
                print(error?.localizedDescription ?? "unknown error")
                return
            }

            //レスポンスの結果で条件分岐
            let responseCode = response?.statusCode
            switch responseCode == Optional(200) {
            case true:
                //翻訳のデータをJSON形式に変換
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                guard let translationJSON = try? encoder.encode(translationResult) else {
                    fatalError("Failed to encode to JSON.")
                }

                //JSON解析(translation)
                let translationValue = JSON(translationJSON)
                self.translation     = translationValue["translations"][self.count]["translation"].string
                
                //構造体Translationに翻訳結果を追加
                self.translationArray.append(Translation(translation: self.translation!))
                
                //NewsTableViewControllerへ値を渡す
                self.doneCatchTranslationProtocol?.catchData(arrayData: self.translationArray, resultCount: self.translationArray.count)

            case false:
                //ステータスコードの表示(200範囲は成功、400範囲は障害、500範囲は内部システムエラー)
                print("translation failure: \(responseCode)")
            }
        }
    }
}
