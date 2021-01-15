//
//  TimeScheduleModel.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/01/15.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import Foundation

class TimeScheduleModel {
    
    //前回起動時刻の保管場所
    var lastActivation: String?

    //UserDefaults.standardのインスタン作成
    var userDefaults = UserDefaults.standard
    
    //NewsViewControllerから渡ってくる値
    var date         : Date?
    var dateFormatter: DateFormatter?
    
    //現在時刻を受け取る
    init(dateTime: Date, dateTimeFormat: DateFormatter) {
        
        date          = dateTime
        dateFormatter = dateTimeFormat
    }
    
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
        
        //前回起動時刻と定時時刻の間隔で時間割（日付を無くして全て時間指定）
        //07:00以降11:00以前の場合
        if lastActivation!.compare(morningTime) == .orderedDescending && lastActivation!.compare(afternoonTime) == .orderedAscending {

            //UserDefaultsに'朝の更新完了'の値が無ければAPIと通信、あればキャッシュでUI更新
            if userDefaults.string(forKey: "morningUpdate") == nil {
                print("朝のAPI通信")

                //UserDefaultsで値を保存して次回起動時キャッシュ表示に備える
                userDefaults.set("morningUpdate", forKey: "morningUpdate")

                //次回時間割に備えてUserDefaultsに保存した値を削除
                userDefaults.removeObject(forKey: "afternoonUpdate")
                userDefaults.removeObject(forKey: "eveningUpdate")
                userDefaults.removeObject(forKey: "nightUpdate")
                
                //NewsViewControllerへ値を返す
                
            } else {
                    print("キャッシュの表示")
                }
            }

        //11:00以降17:00以前の場合
        else if lastActivation!.compare(afternoonTime) == .orderedDescending && lastActivation!.compare(eveningTime) == .orderedAscending {

            //UserDefaultsに'昼の更新完了'の値が無ければAPIと通信、あればキャッシュでUI更新
            if userDefaults.string(forKey: "afternoonUpdate") == nil {
                print("昼のAPI通信")

                //UserDefaultsで値を保存して次回起動時キャッシュ表示に備える
                userDefaults.set("afternoonUpdate", forKey: "afternoonUpdate")

                //次回時間割に備えてUserDefaultsに保存した値を削除
                userDefaults.removeObject(forKey: "morningUpdate")
                userDefaults.removeObject(forKey: "eveningUpdate")
                userDefaults.removeObject(forKey: "nightUpdate")
                
                //NewsViewControllerへ値を返す
                
            } else {
                print("キャッシュの表示")
                //reloadNewsData()
            }
        }

        //17:00以降23:59:59以前の場合（1日の最後）
        else if lastActivation!.compare(eveningTime) == .orderedDescending && lastActivation!.compare(nightTime) == .orderedAscending {

            //UserDefaultsに'夕方のAPI更新完了（日付変更以前）'の値が無ければAPIと通信、あればキャッシュでUI更新
            if userDefaults.string(forKey: "eveningUpdate") == nil {
                print("夕方のAPI通信（日付変更以前）")

                //UserDefaultsで値を保存して次回起動時キャッシュ表示に備える
                userDefaults.set("eveningUpdate", forKey: "eveningUpdate")

                //次回時間割に備えてUserDefaultsに保存した値を削除
                userDefaults.removeObject(forKey: "morningUpdate")
                userDefaults.removeObject(forKey: "afternoonUpdate")
                userDefaults.removeObject(forKey: "nightUpdate")
                
                //NewsViewControllerへ値を返す
            } else {
                print("キャッシュの表示")
                //reloadNewsData()
            }
        }

        //00:00以降07:00以前の場合（日を跨いで初めて起動）
        else if lastActivation!.compare(lateAtNightTime) == .orderedDescending && lastActivation!.compare(morningTime) == .orderedAscending  {

            //UserDefaultsに'夕方のAPI更新完了（日付変更以降）'値が無ければAPIと通信、あればキャッシュでUI更新
            if userDefaults.string(forKey: "nightUpdate") == nil {
                print("夕方のAPI通信（日付変更以降）")

                //UserDefaultsで値を保存して次回起動時キャッシュ表示に備える
                userDefaults.set("nightUpdate", forKey: "nightUpdate")

                //次回時間割に備えてUserDefaultsに保存した値を削除
                userDefaults.removeObject(forKey: "morningUpdate")
                userDefaults.removeObject(forKey: "afternoonUpdate")
                userDefaults.removeObject(forKey: "eveningUpdate")
                
                //NewsViewControllerへ値を返す
            } else {
                print("キャッシュの表示")
                //reloadNewsData()
            }
        }

        //どの時間割にも当てはまらない場合
        else {
            print("キャッシュの表示")
            //reloadNewsData()
        }
    }
}
