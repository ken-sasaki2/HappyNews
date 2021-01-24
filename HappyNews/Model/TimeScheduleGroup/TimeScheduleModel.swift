//
//  TimeScheduleModel.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/01/15.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import Foundation


// MARK: - Protocol
//NewsViewControllerへ値を返す
protocol DoneCatchTimeScheduleProtocol {
    func catchTimeSchedule(updateOrCache: Bool)
}

class TimeScheduleModel {
    
    
    // MARK: - Property
    //前回起動時刻の保管場所
    var lastActivation: String?

    //UserDefaults.standardのインスタン作成
    var userDefaults = UserDefaults.standard
    
    //プロトコルのインスタンス
    var doneCatchTimeScheduleProtocol: DoneCatchTimeScheduleProtocol?
    
    //NewsViewControllerから渡ってくる値
    var date         : Date?
    var dateFormatter: DateFormatter?
    
    //現在時刻を受け取る
    init(dateTime: Date, dateTimeFormat: DateFormatter) {
        
        date          = dateTime
        dateFormatter = dateTimeFormat
    }
    
    
    // MARK: - SetTimeSchedule
    //時間の比較とそれに合った処理をおこなう
    func setTimeSchedule() {
        
        //日時のフォーマットと地域を指定
        dateFormatter!.dateFormat = "HH:mm:ss"
        dateFormatter!.timeZone   = TimeZone(identifier: "Asia/Tokyo")
        
        //アプリ起動時刻を定義
        let currentTime = dateFormatter!.string(from: date!)
        print("現在時刻: \(currentTime)")
        
        //アプリ起動時刻の保存
        userDefaults.set(currentTime, forKey: "lastActivation")
        
        //定時時刻の設定
        let morningPoint     = dateFormatter!.date(from: "07:00:00")
        let afternoonPoint   = dateFormatter!.date(from: "11:00:00")
        let eveningPoint     = dateFormatter!.date(from: "17:00:00")
        let nightPoint       = dateFormatter!.date(from: "23:59:59")
        let lateAtNightPoint = dateFormatter!.date(from: "00:00:00")
        
        //定時時刻の変換
        let morningTime     = dateFormatter!.string(from: morningPoint!)
        let afternoonTime   = dateFormatter!.string(from: afternoonPoint!)
        let eveningTime     = dateFormatter!.string(from: eveningPoint!)
        let nightTime       = dateFormatter!.string(from: nightPoint!)
        let lateAtNightTime = dateFormatter!.string(from: lateAtNightPoint!)
        
        //前回起動時刻の取り出し
        lastActivation = userDefaults.string(forKey: "lastActivation")
        print("起動時刻更新: \(lastActivation)")
        
        
        // MARK: - TimeSchedule 07:00 〜
        //前回起動時刻と定時時刻の間隔で時間割（日付を無くして全て時間指定）
        //07:00以降11:00以前の場合
        if lastActivation!.compare(morningTime) == .orderedDescending && lastActivation!.compare(afternoonTime) == .orderedAscending {

            //UserDefaultsに 'morningUpdate' が無ければtureをあればfalseを返す
            if userDefaults.string(forKey: "morningUpdate") == nil {
                print("朝のニュース 'true' を返す")

                //UserDefaultsで値を保存して次回起動時キャッシュ表示に備える
                userDefaults.set("morningUpdate", forKey: "morningUpdate")

                //次回時間割に備えてUserDefaultsに保存した値を削除
                userDefaults.removeObject(forKey: "afternoonUpdate")
                userDefaults.removeObject(forKey: "eveningUpdate")
                userDefaults.removeObject(forKey: "nightUpdate")
                
                //NewsViewControllerへAPI通信をおこなう値を返す
                doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
            } else {
                
                //前回API通信時にエラーが発生していた場合の処理
                if userDefaults.object(forKey: "LT: many429Errors.") != nil || userDefaults.object(forKey: "LT: errorOccurred") != nil || userDefaults.object(forKey: "TA: many429Errors.") != nil || userDefaults.object(forKey: "TA: errorOccurred") != nil {
                    
                    print("朝のニュース 'true' を返す（前回エラー）")
                    
                    //NewsViewControllerへAPI通信をおこなう値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
                    
                    //UserDefaultsに保存した前回エラーの証を削除
                    userDefaults.removeObject(forKey: "LT: errorOccurred")
                    userDefaults.removeObject(forKey: "TA: many429Errors.")
                    userDefaults.removeObject(forKey: "TA: errorOccurred")
                } else {
                    
                    print("朝のニュース 'false' を返す")
                    //NewsViewControllerへキャッシュ通信の値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: false)
                }
            }
        }

        
        // MARK: - TimeSchedule 11:00 〜
        //11:00以降17:00以前の場合
        else if lastActivation!.compare(afternoonTime) == .orderedDescending && lastActivation!.compare(eveningTime) == .orderedAscending {

            //UserDefaultsに 'afternoonUpdate' が無ければtureをあればfalseを返す
            if userDefaults.string(forKey: "afternoonUpdate") == nil {
                print("昼のニュース 'true' を返す")

                //UserDefaultsで値を保存して次回起動時キャッシュ表示に備える
                userDefaults.set("afternoonUpdate", forKey: "afternoonUpdate")

                //次回時間割に備えてUserDefaultsに保存した値を削除
                userDefaults.removeObject(forKey: "morningUpdate")
                userDefaults.removeObject(forKey: "eveningUpdate")
                userDefaults.removeObject(forKey: "nightUpdate")
                
                //NewsViewControllerへAPI通信をおこなう値を返す
                doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
            } else {
                
                //前回API通信時にエラーが発生していた場合の処理
                if userDefaults.object(forKey: "LT: many429Errors.") != nil || userDefaults.object(forKey: "LT: errorOccurred") != nil || userDefaults.object(forKey: "TA: many429Errors.") != nil || userDefaults.object(forKey: "TA: errorOccurred") != nil {
                    
                    print("昼のニュース 'true' を返す（前回エラー）")
                    
                    //NewsViewControllerへAPI通信をおこなう値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
                    
                    //UserDefaultsに保存した前回エラーの証を削除
                    userDefaults.removeObject(forKey: "LT: errorOccurred")
                    userDefaults.removeObject(forKey: "TA: many429Errors.")
                    userDefaults.removeObject(forKey: "TA: errorOccurred")
                } else {
                    
                    print("昼のニュース 'false' を返す")
                    //NewsViewControllerへキャッシュ通信の値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: false)
                }
            }
        }

        
        // MARK: - TimeSchedule 17:00 〜
        //17:00以降23:59:59以前の場合（1日の最後）
        else if lastActivation!.compare(eveningTime) == .orderedDescending && lastActivation!.compare(nightTime) == .orderedAscending {

            //UserDefaultsに 'eveningUpdate' が無ければtureをあればfalseを返す
            if userDefaults.string(forKey: "eveningUpdate") == nil {
                print("夕方のニュース 'true' を返す")

                //UserDefaultsで値を保存して次回起動時キャッシュ表示に備える
                userDefaults.set("eveningUpdate", forKey: "eveningUpdate")

                //次回時間割に備えてUserDefaultsに保存した値を削除
                userDefaults.removeObject(forKey: "morningUpdate")
                userDefaults.removeObject(forKey: "afternoonUpdate")
                userDefaults.removeObject(forKey: "nightUpdate")
                
                //NewsViewControllerへAPI通信をおこなう値を返す
                doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
            } else {
                
                //前回API通信時にエラーが発生していた場合の処理
                if userDefaults.object(forKey: "LT: many429Errors.") != nil || userDefaults.object(forKey: "LT: errorOccurred") != nil || userDefaults.object(forKey: "TA: many429Errors.") != nil || userDefaults.object(forKey: "TA: errorOccurred") != nil {
                    
                    print("夕方のニュース 'true' を返す（前回エラー）")
                    
                    //NewsViewControllerへAPI通信をおこなう値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
                    
                    //UserDefaultsに保存した前回エラーの証を削除
                    userDefaults.removeObject(forKey: "LT: errorOccurred")
                    userDefaults.removeObject(forKey: "TA: many429Errors.")
                    userDefaults.removeObject(forKey: "TA: errorOccurred")
                } else {
                    
                    print("夕方のニュース 'false' を返す")
                    //NewsViewControllerへキャッシュ通信の値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: false)
                }
            }
        }

        
        // MARK: - TimeSchedule 00:00 〜
        //00:00以降07:00以前の場合（日を跨いで初めて起動）
        else if lastActivation!.compare(lateAtNightTime) == .orderedDescending && lastActivation!.compare(morningTime) == .orderedAscending  {

            //UserDefaultsに 'nightUpdate' が無ければtureをあればfalseを返す
            if userDefaults.string(forKey: "nightUpdate") == nil {
                print("夜のニュース 'true' を返す")

                //UserDefaultsで値を保存して次回起動時キャッシュ表示に備える
                userDefaults.set("nightUpdate", forKey: "nightUpdate")

                //次回時間割に備えてUserDefaultsに保存した値を削除
                userDefaults.removeObject(forKey: "morningUpdate")
                userDefaults.removeObject(forKey: "afternoonUpdate")
                userDefaults.removeObject(forKey: "eveningUpdate")
                
                //NewsViewControllerへAPI通信をおこなう値を返す
                doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
            } else {
                
                //前回API通信時にエラーが発生していた場合の処理
                if userDefaults.object(forKey: "LT: many429Errors.") != nil || userDefaults.object(forKey: "LT: errorOccurred") != nil || userDefaults.object(forKey: "TA: many429Errors.") != nil || userDefaults.object(forKey: "TA: errorOccurred") != nil {
                    
                    print("夜のニュース 'true' を返す（前回エラー）")
                    
                    //NewsViewControllerへAPI通信をおこなう値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
                    
                    //UserDefaultsに保存した前回エラーの証を削除
                    userDefaults.removeObject(forKey: "LT: errorOccurred")
                    userDefaults.removeObject(forKey: "TA: many429Errors.")
                    userDefaults.removeObject(forKey: "TA: errorOccurred")
                } else {
                    
                    print("夜のニュース 'false' を返す")
                    //NewsViewControllerへキャッシュ通信の値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: false)
                }
            }
        }

        //どの時間割にも当てはまらない場合
        else {
            print("いずれも当てはまらないので 'false' を返す")
            
            //NewsViewControllerへキャッシュ通信の値を返す
            doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: false)
        }
    }
}
