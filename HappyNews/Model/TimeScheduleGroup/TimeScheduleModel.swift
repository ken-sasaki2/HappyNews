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
    //プロトコルのインスタンス
    var doneCatchTimeScheduleProtocol: DoneCatchTimeScheduleProtocol?
    
    //フォーマットを整形した現在時刻を保存
    var currentTime: String?
    
    //NewsViewControllerから渡ってきた値を受け取る
    var dateTime: Date?
    
    //現在時刻を受け取る
    init(date: Date) {
        dateTime = date
    }
    
    
    // MARK: - SetTimeSchedule
    //時間の比較とそれに合った処理をおこなう
    func setTimeSchedule() {
        
        //日時のフォーマットと地域を指定
        DateItems.dateFormatter.dateFormat = "HH:mm:ss"
        DateItems.dateFormatter.timeZone   = TimeZone(identifier: "Asia/Tokyo")
        
        //アプリ起動時刻を定義
        let currentTime = DateItems.dateFormatter.string(from: dateTime!)
        print("現在時刻: \(currentTime)")
        
        //アプリ起動時刻の保存
        UserDefault.standard.set(currentTime, forKey: "lastActivation")
        
        
        // MARK: - TimeSchedule 07:00 〜
        //現在時刻と定時時刻の間隔で時間割（日付を無くして全て時間指定）
        //07:00以降11:00以前の場合
        if currentTime > UpdateTimes.morningTime && currentTime < UpdateTimes.afternoonTime {

            //UserDefaultsに 'morningUpdate' が無ければtureをあれば更に分岐
            if UserDefault.outputmorningUpdate == nil {
                print("朝のニュース 'true' を返す")

                //UserDefaultsで値を保存して次回起動時キャッシュ表示に備える
                UserDefault.standard.set("morningUpdate", forKey: "morningUpdate")

                //次回API通信の時刻に備えてUserDefaultsに保存した値を削除
                UserDefault.removeExceptionMorning()
                
                //NewsViewControllerへAPI通信をおこなう値を返す
                doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
            } else {
                
                //前回API通信時にエラーが発生していた場合の処理
                if UserDefault.ErrorHistory429LT != nil || UserDefault.ErrorHistoryLT != nil ||  UserDefault.ErrorHistory429TA != nil || UserDefault.ErrorHistoryTA != nil {
                    
                    print("朝のニュース 'true' を返す（前回エラー）")
                    
                    //NewsViewControllerへAPI通信をおこなう値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
                    
                    //UserDefaultsに保存した前回エラーの履歴を削除
                    UserDefault.removeErrorObject()
                } else {
                    
                    print("朝のニュース 'false' を返す")
                    //NewsViewControllerへキャッシュ通信の値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: false)
                }
            }
        }

        
        // MARK: - TimeSchedule 11:00 〜
        //11:00以降17:00以前の場合
        else if currentTime > UpdateTimes.afternoonTime && currentTime < UpdateTimes.eveningTime {

            //UserDefaultsに 'afternoonUpdate' が無ければtureをあれば更に分岐
            if UserDefault.outputAfternoonUpdate == nil {
                print("昼のニュース 'true' を返す")

                //UserDefaultsで値を保存して次回起動時キャッシュ表示に備える
                UserDefault.standard.set("afternoonUpdate", forKey: "afternoonUpdate")

                //次回API通信の時刻に備えてUserDefaultsに保存した値を削除
                UserDefault.removeExceptionAfternoon()
                
                //NewsViewControllerへAPI通信をおこなう値を返す
                doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
            } else {
                
                //前回API通信時にエラーが発生していた場合の処理
                if UserDefault.ErrorHistory429LT != nil || UserDefault.ErrorHistoryLT != nil ||  UserDefault.ErrorHistory429TA != nil || UserDefault.ErrorHistoryTA != nil {
                    
                    print("昼のニュース 'true' を返す（前回エラー）")
                    
                    //NewsViewControllerへAPI通信をおこなう値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
                    
                    //UserDefaultsに保存した前回エラーの履歴を削除
                    UserDefault.removeErrorObject()
                } else {
                    
                    print("昼のニュース 'false' を返す")
                    //NewsViewControllerへキャッシュ通信の値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: false)
                }
            }
        }

        
        // MARK: - TimeSchedule 17:00 〜
        //17:00以降23:59:59以前の場合（1日の最後）
        else if currentTime > UpdateTimes.eveningTime && currentTime < UpdateTimes.nightTime {

            //UserDefaultsに 'eveningUpdate' が無ければtureをあれば更に分岐
            if UserDefault.outputEveningUpdate == nil {
                print("夕方のニュース 'true' を返す")

                //UserDefaultsで値を保存して次回起動時キャッシュ表示に備える
                UserDefault.standard.set("eveningUpdate", forKey: "eveningUpdate")

                //次回時間割に備えてUserDefaultsに保存した値を削除
                UserDefault.removeExceptionEvening()
                
                //NewsViewControllerへAPI通信をおこなう値を返す
                doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
            } else {
                
                //前回API通信時にエラーが発生していた場合の処理
                if UserDefault.ErrorHistory429LT != nil || UserDefault.ErrorHistoryLT != nil ||  UserDefault.ErrorHistory429TA != nil || UserDefault.ErrorHistoryTA != nil {
                    
                    print("夕方のニュース 'true' を返す（前回エラー）")
                    
                    //NewsViewControllerへAPI通信をおこなう値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
                    
                    //UserDefaultsに保存した前回エラーの履歴を削除
                    UserDefault.removeErrorObject()
                } else {
                    
                    print("夕方のニュース 'false' を返す")
                    //NewsViewControllerへキャッシュ通信の値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: false)
                }
            }
        }

        
        // MARK: - TimeSchedule 00:00 〜
        //00:00以降07:00以前の場合（日を跨いで初めて起動）
        else if currentTime > UpdateTimes.lateAtNightTime && currentTime < UpdateTimes.morningTime {

            //UserDefaultsに 'nightUpdate' が無ければtureをあれば更に分岐
            if UserDefault.outputNightUpdate == nil {
                print("夜のニュース 'true' を返す")

                //UserDefaultsで値を保存して次回起動時キャッシュ表示に備える
                UserDefault.standard.set("nightUpdate", forKey: "nightUpdate")
                
                //次回時間割に備えてUserDefaultsに保存した値を削除
                UserDefault.removeExceptionLateAtNight()
                
                //NewsViewControllerへAPI通信をおこなう値を返す
                doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
            } else {
                
                //前回API通信時にエラーが発生していた場合の処理
                if UserDefault.ErrorHistory429LT != nil || UserDefault.ErrorHistoryLT != nil ||  UserDefault.ErrorHistory429TA != nil || UserDefault.ErrorHistoryTA != nil {
                    
                    print("夜のニュース 'true' を返す（前回エラー）")
                    
                    //NewsViewControllerへAPI通信をおこなう値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
                    
                    //UserDefaultsに保存した前回エラーの履歴を削除
                    UserDefault.removeErrorObject()
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
