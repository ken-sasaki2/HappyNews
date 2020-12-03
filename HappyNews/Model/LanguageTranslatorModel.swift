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

    func catchTranslation(arrayTranslationData: Array<String>, resultCount: Int)
}

class LanguageTranslatorModel {

    //Controllerから渡ってくる値
    var languageTranslatorAccessKey     : String?
    var languageTranslatorAccessversion : String?
    var languageTranslatorAccessURL     : String?
    var translationTextArray            : [Any] = []
    var translationText                 : String?
    
    //Controllerに値を返すときに使用
    var translationArray = [String]()
    var doneCatchTranslationProtocol: DoneCatchTranslationProtocol?

    //JSON解析で使用
    var count     = 0
    var textCount = 50

    //NewsTableViewから値を受け取る
    init(languageTranslatorApiKey: String, languageTranslatorVersion: String, languageTranslatorURL: String, newsTextArray: [Any]) {

        languageTranslatorAccessKey     = languageTranslatorApiKey
        languageTranslatorAccessversion = languageTranslatorVersion
        languageTranslatorAccessURL     = languageTranslatorURL
        translationTextArray            = newsTextArray
    }

    //翻訳開始
    func setLanguageTranslator() {

        //API認証子
        let languageTranslatorKey = WatsonIAMAuthenticator(apiKey: languageTranslatorAccessKey!)
        let languageTranslator    = LanguageTranslator(version: languageTranslatorAccessversion!, authenticator: languageTranslatorKey)
            languageTranslator.serviceURL = languageTranslatorAccessURL
        
        for i in 0..<self.textCount {
            
            self.translationText = translationTextArray[i] as? String

            //リクエスト送信
            languageTranslator.translate(text: [self.translationText!], modelID: "ja-en") {
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
                //translationResult = レスポンス結果
                guard let translationResult = response?.result else {
                    print(error?.localizedDescription ?? "unknown error")
                    return
                }
              
                //レスポンスのステータスコードで条件分岐
                let statusCode = response?.statusCode
                switch statusCode == Optional(200) {
                case true:
                    //レスポンス結果をJSON形式に整形
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    guard let translationJSON = try? encoder.encode(translationResult) else {
                        fatalError("Failed to encode to JSON.")
                    }
                    
                    //SwiftyJSONのJSON型へ変換
                    let translationValue: JSON = JSON(translationJSON)
                    
                    //translation = 翻訳結果（JSON解析結果）
                    let translation = Translation(translation: translationValue["translations"][self.count]["translation"].string!)
                    
                    //翻訳結果を配列に保存
                    self.translationArray.append(translation.translation!)
                    
                    //最後にappendされたtranslationArrayをControllerへ返す
                    if self.translationArray.count == self.textCount  {
                        //NewsTableViewControllerへ値を渡す
                        self.doneCatchTranslationProtocol?.catchTranslation(arrayTranslationData: self.translationArray, resultCount: self.translationArray.count)
                    }
                    
                case false:
                    //ステータスコードの400範囲は障害、500範囲は内部システムエラー
                    print("translation failure: \(statusCode)")
                }
            }
            //NewsTableViewControllerへ値を渡す
            self.doneCatchTranslationProtocol?.catchTranslation(arrayTranslationData: self.translationArray, resultCount: self.translationArray.count)
        }
    }
}
