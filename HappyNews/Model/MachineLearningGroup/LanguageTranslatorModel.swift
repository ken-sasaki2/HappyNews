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
import PKHUD


// MARK: - Protocol
//NewsViewControllerに値を返す
protocol DoneCatchTranslationProtocol {
    func catchTranslation(arrayTranslationData: Array<String>, resultCount: Int)
}

class LanguageTranslatorModel {
    
    
    // MARK: - Property
    //NewsViewControllerに値を返すときに使用
    var doneCatchTranslationProtocol: DoneCatchTranslationProtocol?
    
    //UserDefaultsのインスタンス
    var userDefaults = UserDefaults.standard
    
    //JSON解析で使用
    var count     = 0
    var textCount = 50
    
    //429エラーが発生した場合に使用
    var errorResponseLT: String?
    var errorResultLT = JSON()
    
    //LanguageTranslatorの中継保管場所
    var containsArray: [String] = []
    
    //ニュースの要素順を整える配列、初期値はnilによる番号差分を回避するため
    var translationArray = [String](repeating: "空の値", count: 50)
    
    //NewsViewControllerから渡ってくる値
    var languageTranslatorAccessKey    : String?
    var languageTranslatorAccessversion: String?
    var languageTranslatorAccessURL    : String?
    var translationTextArray           : [String] = []
    var translationText                : String?
    
    //NewsViewControllerから値を受け取る
    init(languageTranslatorApiKey: String, languageTranslatorVersion: String, languageTranslatorURL: String, newsTextArray: [String]) {
        
        languageTranslatorAccessKey     = languageTranslatorApiKey
        languageTranslatorAccessversion = languageTranslatorVersion
        languageTranslatorAccessURL     = languageTranslatorURL
        translationTextArray            = newsTextArray
    }
    
    
    // MARK: - SetLanguageTranslator
    //翻訳開始
    func setLanguageTranslator() {
        
        //API認証子
        let languageTranslatorKey = WatsonIAMAuthenticator(apiKey: languageTranslatorAccessKey!)
        let languageTranslator    = LanguageTranslator(version: languageTranslatorAccessversion!, authenticator: languageTranslatorKey)
        languageTranslator.serviceURL = languageTranslatorAccessURL
        
        for i in 0..<self.textCount {
            
            //リクエスト送信
            languageTranslator.translate(text: [translationTextArray[i]], modelID: "ja-en") {
                response, error in
                
                //エラー処理
                if let error = error {
                    switch error {
                    case let .http(statusCode, message, metadata):
                        switch statusCode {
                        case .some(429):
                            //429エラーが発生すると意図する値を作成してappend
                            self.errorResponseLT =  "LT: errorResponse 429 error occurred"
                            print(self.errorResponseLT)
                            self.containsArray.append(self.errorResponseLT!)
                            
                            //429エラーが多発してtextCountに達した場合
                            if self.containsArray.count == self.textCount {
                                
                                //API通信時のエラー結果を保存
                                self.userDefaults.set("LanguageTranslator: 429エラー多発", forKey: "LT: many429Errors.")
                                
                                //感情分析が失敗したことをユーザーに伝える
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    HUD.show(.label("予期せぬエラー発生\nアプリを再起動してください"))
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        HUD.hide(animated: true)
                                    }
                                }
                            }
                        default:
                            if let statusCode = statusCode {
                                print("Error - code: \(statusCode), \(message ?? "")")
                                
                                //API通信時のエラー結果を保存
                                self.userDefaults.set("予期せぬエラー発生", forKey: "LT: errorOccurred")
                                
                                //感情分析が失敗したことをユーザーに伝える
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
                    
                    //中継保管場所として翻訳結果を配列に保管
                    self.containsArray.append(translation.translation!)
                    
                    //配列のcountが真ならばメソッドを呼び出す
                    if self.containsArray.count == self.textCount {
                        self.sortTheTranslationResults()
                    }
                    
                case false:
                    //ステータスコードの400範囲は障害、500範囲は内部システムエラー
                    print("translation failure: \(statusCode)")
                }
            }
        }
    }
    
    
    // MARK: - SortTheTranslationResults
    //翻訳結果の並べ替えをおこなうメソッド
    func sortTheTranslationResults() {
        
        //"$i"の検索をおこない意図した変数へ代入
        for i in 0..<textCount {
            
            //'i'固定、その間に'y'を加算
            for y in (0..<textCount).reversed() {
                
                //'y+1'は特定の文字列検索の生合成を合わせるため
                switch self.containsArray.count == self.textCount {
                case self.containsArray[i].contains("$\(y+1)"):
                    self.translationArray[y] = self.containsArray[i].description
                    break
                default :
                    break
                }
            }
        }
        
        //最後にappendされたtranslationArrayをNewsViewControllerへ返す
        if translationArray.count == textCount  {
            
            //NewsViewControllerへ値を返す
            self.doneCatchTranslationProtocol?.catchTranslation(arrayTranslationData: translationArray, resultCount: translationArray.count)
        } else {
            print("Not enough elements in the array")
        }
    }
}
