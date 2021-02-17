//
//  UserDefault.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/01/24.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import Foundation

// ▼関係するclass
// TimeScheduleModel
// LanguageTranslatorModel
// ToneAnalyzerModel
// NewsViewController
// WebViewController

// UserDefaultsで保存した値の取り出し or 削除で扱う
class UserDefault {
    
    // UserDefaultsに値を保存する場合に扱う（Value, Keyを指定した保存処理はインスタンス化できない為）
    static var standard = UserDefaults.standard
    
    // アカウント画像の取り出しで扱う
    static var imageCapture = UserDefaults.standard.string(forKey: "userImage")
    
    // ユーザー名の取り出しで扱う
    static var getUserName = UserDefaults.standard.string(forKey: "userName")
    
    // uidの取り出しで扱う
    static var getUID = UserDefaults.standard.string(forKey: "uid")

    // アプリ起動時刻の取り出しで扱う
    static var lastActivation = UserDefaults.standard.string(forKey: "lastActivation")
    
    // ToneAnalyzerModelから返ってきた感情分析結果の取り出しで扱う
    static var joyCountArray = UserDefaults.standard.array(forKey: "joyCountArray") as! [Int]
    
    // TimeScheduleModelの時間割でAPI通信をおこなった履歴の取り出しで扱う
    static var outputMorningUpdate   = UserDefaults.standard.string(forKey: "morningUpdate")
    static var outputAfternoonUpdate = UserDefaults.standard.string(forKey: "afternoonUpdate")
    static var outputEveningUpdate   = UserDefaults.standard.string(forKey: "eveningUpdate")
    static var outputNightUpdate     = UserDefaults.standard.string(forKey: "nightUpdate")
    
    // API通信時のエラー発生履歴の取り出しで扱う
    static var ErrorHistory429LT = UserDefaults.standard.object(forKey: "LT: many429Errors.")
    static var ErrorHistoryLT    = UserDefaults.standard.object(forKey: "LT: errorOccurred")
    static var ErrorHistory429TA = UserDefaults.standard.object(forKey: "TA: many429Errors.")
    static var ErrorHistoryTA    = UserDefaults.standard.object(forKey: "TA: errorOccurred")
    
    // API通信時に保存したエラー履歴を削除する場合に扱う
    static func removeErrorObject() {
        UserDefaults.standard.removeObject(forKey: "LT: many429Errors.")
        UserDefaults.standard.removeObject(forKey: "LT: errorOccurred")
        UserDefaults.standard.removeObject(forKey: "TA: many429Errors.")
        UserDefaults.standard.removeObject(forKey: "TA: errorOccurred")
    }
    
    // 次回API通信に備えてUserDefaultsに保存した履歴を削除する場合に扱う
    // 朝 - 07:00以降11:00以前の場合
    static func removeExceptionMorning() {
        //次回時間割に備えてUserDefaultsに保存した値を削除
        UserDefaults.standard.removeObject(forKey: "afternoonUpdate")
        UserDefaults.standard.removeObject(forKey: "eveningUpdate")
        UserDefaults.standard.removeObject(forKey: "nightUpdate")
    }
    
    // 昼 - 11:00以降17:00以前の場合
    static func removeExceptionAfternoon() {
        UserDefaults.standard.removeObject(forKey: "morningUpdate")
        UserDefaults.standard.removeObject(forKey: "eveningUpdate")
        UserDefaults.standard.removeObject(forKey: "nightUpdate")
    }
    
    // 夜 - 17:00以降23:59:59以前の場合
    static func removeExceptionEvening() {
        //次回時間割に備えてUserDefaultsに保存した値を削除
        UserDefaults.standard.removeObject(forKey: "morningUpdate")
        UserDefaults.standard.removeObject(forKey: "afternoonUpdate")
        UserDefaults.standard.removeObject(forKey: "nightUpdate")
    }
    
    // 夜 - 00:00以降07:00以前の場合
    static func removeExceptionLateAtNight() {
        //次回時間割に備えてUserDefaultsに保存した値を削除
        UserDefaults.standard.removeObject(forKey: "morningUpdate")
        UserDefaults.standard.removeObject(forKey: "afternoonUpdate")
        UserDefaults.standard.removeObject(forKey: "eveningUpdate")
    }
}
