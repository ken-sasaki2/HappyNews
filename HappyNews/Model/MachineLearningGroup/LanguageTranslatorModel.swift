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

protocol DoneCatchTranslationProtocol {
    
    func catchTranslation(arrayTranslationData: Array<String>, resultCount: Int)
}

class LanguageTranslatorModel {
    
    //Controllerから渡ってくる値
    var languageTranslatorAccessKey    : String?
    var languageTranslatorAccessversion: String?
    var languageTranslatorAccessURL    : String?
    var translationTextArray           : [Any] = []
    var translationText                : String?
    
    //Controllerに値を返すときに使用
    var doneCatchTranslationProtocol: DoneCatchTranslationProtocol?
    
    //JSON解析で使用
    var count     = 0
    var textCount = 50
    
    //LanguageTranslatorの中継保管場所
    var containsArray: [String] = []
    
    //配列の生合成を合わせる変数(初期値は翻訳失敗を回避するため)
    var sortNum50 = "Avoiding Nil $50"
    var sortNum49 = "Avoiding Nil $49"
    var sortNum48 = "Avoiding Nil $48"
    var sortNum47 = "Avoiding Nil $47"
    var sortNum46 = "Avoiding Nil $46"
    var sortNum45 = "Avoiding Nil $45"
    var sortNum44 = "Avoiding Nil $44"
    var sortNum43 = "Avoiding Nil $43"
    var sortNum42 = "Avoiding Nil $42"
    var sortNum41 = "Avoiding Nil $41"
    var sortNum40 = "Avoiding Nil $40"
    var sortNum39 = "Avoiding Nil $39"
    var sortNum38 = "Avoiding Nil $38"
    var sortNum37 = "Avoiding Nil $37"
    var sortNum36 = "Avoiding Nil $36"
    var sortNum35 = "Avoiding Nil $35"
    var sortNum34 = "Avoiding Nil $34"
    var sortNum33 = "Avoiding Nil $33"
    var sortNum32 = "Avoiding Nil $32"
    var sortNum31 = "Avoiding Nil $31"
    var sortNum30 = "Avoiding Nil $30"
    var sortNum29 = "Avoiding Nil $29"
    var sortNum28 = "Avoiding Nil $28"
    var sortNum27 = "Avoiding Nil $27"
    var sortNum26 = "Avoiding Nil $26"
    var sortNum25 = "Avoiding Nil $25"
    var sortNum24 = "Avoiding Nil $24"
    var sortNum23 = "Avoiding Nil $23"
    var sortNum22 = "Avoiding Nil $22"
    var sortNum21 = "Avoiding Nil $21"
    var sortNum20 = "Avoiding Nil $20"
    var sortNum19 = "Avoiding Nil $19"
    var sortNum18 = "Avoiding Nil $18"
    var sortNum17 = "Avoiding Nil $17"
    var sortNum16 = "Avoiding Nil $16"
    var sortNum15 = "Avoiding Nil $15"
    var sortNum14 = "Avoiding Nil $14"
    var sortNum13 = "Avoiding Nil $13"
    var sortNum12 = "Avoiding Nil $12"
    var sortNum11 = "Avoiding Nil $11"
    var sortNum10 = "Avoiding Nil $10"
    var sortNum9  = "Avoiding Nil $9"
    var sortNum8  = "Avoiding Nil $8"
    var sortNum7  = "Avoiding Nil $7"
    var sortNum6  = "Avoiding Nil $6"
    var sortNum5  = "Avoiding Nil $5"
    var sortNum4  = "Avoiding Nil $4"
    var sortNum3  = "Avoiding Nil $3"
    var sortNum2  = "Avoiding Nil $2"
    var sortNum1  = "Avoiding Nil $1"
    
    //UserDefaultsのインスタンス
    var userDefaults = UserDefaults.standard
    
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
                        default:
                            if let statusCode = statusCode {
                                print("Error - code: \(statusCode), \(message ?? "")")
                                
                                //API通信時のエラー結果を保存
                                self.userDefaults.set("予期せぬエラー発生", forKey: "LT: errorOccurred")
                                
                                //感情分析が失敗したことをユーザーに伝える
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    HUD.show(.label("予期せぬエラー発生"))
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
    
    //翻訳結果の並べ替えをおこなうメソッド
    func sortTheTranslationResults() {
        
        //"$i"の検索をおこない意図した変数へ代入
        for i in (0...49).reversed() {
            
            switch containsArray.count == textCount {
            case containsArray[i].contains("$50"):
                sortNum50 = containsArray[i]
            case containsArray[i].contains("$49"):
                sortNum49 = containsArray[i]
            case containsArray[i].contains("$48"):
                sortNum48 = containsArray[i]
            case containsArray[i].contains("$47"):
                sortNum47 = containsArray[i]
            case containsArray[i].contains("$46"):
                sortNum46 = containsArray[i]
            case containsArray[i].contains("$45"):
                sortNum45 = containsArray[i]
            case containsArray[i].contains("$44"):
                sortNum44 = containsArray[i]
            case containsArray[i].contains("$43"):
                sortNum43 = containsArray[i]
            case containsArray[i].contains("$42"):
                sortNum42 = containsArray[i]
            case containsArray[i].contains("$41"):
                sortNum41 = containsArray[i]
            case containsArray[i].contains("$40"):
                sortNum40 = containsArray[i]
            case containsArray[i].contains("$39"):
                sortNum39 = containsArray[i]
            case containsArray[i].contains("$38"):
                sortNum38 = containsArray[i]
            case containsArray[i].contains("$37"):
                sortNum37 = containsArray[i]
            case containsArray[i].contains("$36"):
                sortNum36 = containsArray[i]
            case containsArray[i].contains("$35"):
                sortNum35 = containsArray[i]
            case containsArray[i].contains("$34"):
                sortNum34 = containsArray[i]
            case containsArray[i].contains("$33"):
                sortNum33 = containsArray[i]
            case containsArray[i].contains("$32"):
                sortNum32 = containsArray[i]
            case containsArray[i].contains("$31"):
                sortNum31 = containsArray[i]
            case containsArray[i].contains("$30"):
                sortNum30 = containsArray[i]
            case containsArray[i].contains("$29"):
                sortNum29 = containsArray[i]
            case containsArray[i].contains("$28"):
                sortNum28 = containsArray[i]
            case containsArray[i].contains("$27"):
                sortNum27 = containsArray[i]
            case containsArray[i].contains("$26"):
                sortNum26 = containsArray[i]
            case containsArray[i].contains("$25"):
                sortNum25 = containsArray[i]
            case containsArray[i].contains("$24"):
                sortNum24 = containsArray[i]
            case containsArray[i].contains("$23"):
                sortNum23 = containsArray[i]
            case containsArray[i].contains("$22"):
                sortNum22 = containsArray[i]
            case containsArray[i].contains("$21"):
                sortNum21 = containsArray[i]
            case containsArray[i].contains("$20"):
                sortNum20 = containsArray[i]
            case containsArray[i].contains("$19"):
                sortNum19 = containsArray[i]
            case containsArray[i].contains("$18"):
                sortNum18 = containsArray[i]
            case containsArray[i].contains("$17"):
                sortNum17 = containsArray[i]
            case containsArray[i].contains("$16"):
                sortNum16 = containsArray[i]
            case containsArray[i].contains("$15"):
                sortNum15 = containsArray[i]
            case containsArray[i].contains("$14"):
                sortNum14 = containsArray[i]
            case containsArray[i].contains("$13"):
                sortNum13 = containsArray[i]
            case containsArray[i].contains("$12"):
                sortNum12 = containsArray[i]
            case containsArray[i].contains("$11"):
                sortNum11 = containsArray[i]
            case containsArray[i].contains("$10"):
                sortNum10 = containsArray[i]
            case containsArray[i].contains("$9"):
                sortNum9 = containsArray[i]
            case containsArray[i].contains("$8"):
                sortNum8 = containsArray[i]
            case containsArray[i].contains("$7"):
                sortNum7 = containsArray[i]
            case containsArray[i].contains("$6"):
                sortNum6 = containsArray[i]
            case containsArray[i].contains("$5"):
                sortNum5 = containsArray[i]
            case containsArray[i].contains("$4"):
                sortNum4 = containsArray[i]
            case containsArray[i].contains("$3"):
                sortNum3 = containsArray[i]
            case containsArray[i].contains("$2"):
                sortNum2 = containsArray[i]
            case containsArray[i].contains("$1"):
                sortNum1 = containsArray[i]
            default :
                print("Failure because there is no '$ Int'")
            }
        }
        
        //翻訳前と翻訳後の配列の順番を合わせる
        let translationArray: [String] = [sortNum50, sortNum49, sortNum48, sortNum47, sortNum46, sortNum45, sortNum44, sortNum43, sortNum42, sortNum41, sortNum40, sortNum39, sortNum38, sortNum37, sortNum36, sortNum35, sortNum34, sortNum33, sortNum32, sortNum31, sortNum30, sortNum29, sortNum28, sortNum27, sortNum26, sortNum25, sortNum24, sortNum23, sortNum22, sortNum21, sortNum20, sortNum19, sortNum18, sortNum17, sortNum16, sortNum15, sortNum14, sortNum13, sortNum12, sortNum11, sortNum10, sortNum9, sortNum8, sortNum7, sortNum6, sortNum5, sortNum4, sortNum3, sortNum2, sortNum1]
        
        //最後にappendされたtranslationArrayをControllerへ返す
        if translationArray.count == textCount  {
            
            //NewsTableViewControllerへ値を渡す
            self.doneCatchTranslationProtocol?.catchTranslation(arrayTranslationData: translationArray, resultCount: translationArray.count)
        } else {
            print("Not enough elements in the array")
        }
    }
}
