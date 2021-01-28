//
//  TimeScheduleModel.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/01/15.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import Foundation


// MARK: - Protocol
// NewsViewControllerへ値を返す
protocol DoneCatchTimeScheduleProtocol {
    func catchTimeSchedule(updateOrCache: Bool)
}

// ▼参照しているclass
// DateItems
// UserDefault
// UpdateTimes

// 現在時刻と定時時刻を比較してNewsViewControllerへ値を返す
class TimeScheduleModel {
    
    
    // MARK: - Property
    // プロトコルのインスタンス
    var doneCatchTimeScheduleProtocol: DoneCatchTimeScheduleProtocol?
    
    // フォーマットを整形した現在時刻を保存
    var currentTime: String?
    
    // NewsViewControllerから渡ってきた値を保存
    var dateTime: Date?
    
    // NewsViewControllerから現在時刻を受け取る
    init(date: Date) {
        dateTime = date
    }
    
    
    // MARK: - SetTimeSchedule
    // 時間の比較結果で一致した条件の処理をおこなう
    func setTimeSchedule() {
        
        // 現在時刻のフォーマットと地域を指定
        DateItems.dateFormatter.dateFormat = "HH:mm:ss"
        DateItems.dateFormatter.timeZone   = TimeZone(identifier: "Asia/Tokyo")
        
        // アプリ起動時刻を定義
        let currentTime = DateItems.dateFormatter.string(from: dateTime!)
        print("現在時刻: \(currentTime)")
        
        // アプリ起動時刻の保存
        UserDefault.standard.set(currentTime, forKey: "lastActivation")
        
        
        // MARK: - TimeSchedule 07:00 〜
        // 現在時刻と定時時刻の比較で時間割を作成（日付を無くして全て時間指定）
        // 07:00以降11:00以前の場合
        if currentTime > UpdateTimes.morningTime && currentTime < UpdateTimes.afternoonTime {

            // UserDefaultsに 'morningUpdate' が無ければtureをあればelse
            if UserDefault.outputMorningUpdate == nil {
                print("朝のニュース 'true' を返す")

                // 07:00以降のAPI通信実行履歴を保存
                UserDefault.standard.set("morningUpdate", forKey: "morningUpdate")

                // 11:00以降のAPI通信に備えてAPI通信の実行履歴を削除
                UserDefault.removeExceptionMorning()
                
                // NewsViewControllerへAPI通信実行を許可する値を返す
                doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
            } else {
                
                // 前回API通信時にエラーが発生していた場合の処理
                if UserDefault.ErrorHistory429LT != nil || UserDefault.ErrorHistoryLT != nil ||  UserDefault.ErrorHistory429TA != nil || UserDefault.ErrorHistoryTA != nil {
                    
                    print("朝のニュース 'true' を返す（前回エラー）")
                    
                    // NewsViewControllerへAPI通信実行を許可する値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
                    
                    // API通信時に保存したエラー履歴を削除
                    UserDefault.removeErrorObject()
                } else {
                    
                    print("朝のニュース 'false' を返す")
                    // NewsViewControllerへキャッシュでUI更新を指示する値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: false)
                }
            }
        }

        
        // MARK: - TimeSchedule 11:00 〜
        // 11:00以降17:00以前の場合
        else if currentTime > UpdateTimes.afternoonTime && currentTime < UpdateTimes.eveningTime {

            // UserDefaultsに 'afternoonUpdate' が無ければtureをあればelse
            if UserDefault.outputAfternoonUpdate == nil {
                print("昼のニュース 'true' を返す")

                // 11:00以降のAPI通信実行履歴を保存
                UserDefault.standard.set("afternoonUpdate", forKey: "afternoonUpdate")

                // 17:00以降のAPI通信に備えてAPI通信の実行履歴を削除
                UserDefault.removeExceptionAfternoon()
                
                // NewsViewControllerへAPI通信実行を許可する値を返す
                doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
            } else {
                
                // 前回API通信時にエラーが発生していた場合の処理
                if UserDefault.ErrorHistory429LT != nil || UserDefault.ErrorHistoryLT != nil ||  UserDefault.ErrorHistory429TA != nil || UserDefault.ErrorHistoryTA != nil {
                    
                    print("昼のニュース 'true' を返す（前回エラー）")
                    
                    // NewsViewControllerへAPI通信実行を許可する値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
                    
                    // API通信時に保存したエラー履歴を削除
                    UserDefault.removeErrorObject()
                } else {
                    
                    print("昼のニュース 'false' を返す")
                    // NewsViewControllerへキャッシュでUI更新を指示する値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: false)
                }
            }
        }

        
        // MARK: - TimeSchedule 17:00 〜
        // 17:00以降23:59:59以前の場合（1日の最後）
        else if currentTime > UpdateTimes.eveningTime && currentTime < UpdateTimes.nightTime {

            // UserDefaultsに 'eveningUpdate' が無ければtureをあればelse
            if UserDefault.outputEveningUpdate == nil {
                print("夕方のニュース 'true' を返す")

                // 17:00以降のAPI通信実行履歴を保存
                UserDefault.standard.set("eveningUpdate", forKey: "eveningUpdate")

                // 00:00以降のAPI通信に備えてAPI通信の実行履歴を削除
                UserDefault.removeExceptionEvening()
                
                // NewsViewControllerへAPI通信実行を許可する値を返す
                doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
            } else {
                
                // 前回API通信時にエラーが発生していた場合の処理
                if UserDefault.ErrorHistory429LT != nil || UserDefault.ErrorHistoryLT != nil ||  UserDefault.ErrorHistory429TA != nil || UserDefault.ErrorHistoryTA != nil {
                    
                    print("夕方のニュース 'true' を返す（前回エラー）")
                    
                    // NewsViewControllerへAPI通信実行を許可する値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
                    
                    // API通信時に保存したエラー履歴を削除
                    UserDefault.removeErrorObject()
                } else {
                    
                    print("夕方のニュース 'false' を返す")
                    // NewsViewControllerへキャッシュでUI更新を指示する値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: false)
                }
            }
        }

        
        // MARK: - TimeSchedule 00:00 〜
        // 00:00以降07:00以前の場合（日を跨いで初めて起動）
        else if currentTime > UpdateTimes.lateAtNightTime && currentTime < UpdateTimes.morningTime {

            // UserDefaultsに 'nightUpdate' が無ければtureをあればelse
            if UserDefault.outputNightUpdate == nil {
                print("夜のニュース 'true' を返す")

                // 00:00以降のAPI通信実行履歴を保存
                UserDefault.standard.set("nightUpdate", forKey: "nightUpdate")
                
                // 07:00以降のAPI通信に備えてAPI通信の実行履歴を削除
                UserDefault.removeExceptionLateAtNight()
                
                // NewsViewControllerへAPI通信実行を許可する値を返す
                doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
            } else {
                
                // 前回API通信時にエラーが発生していた場合の処理
                if UserDefault.ErrorHistory429LT != nil || UserDefault.ErrorHistoryLT != nil ||  UserDefault.ErrorHistory429TA != nil || UserDefault.ErrorHistoryTA != nil {
                    
                    print("夜のニュース 'true' を返す（前回エラー）")
                    
                    // NewsViewControllerへAPI通信実行を許可する値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: true)
                    
                    // API通信時に保存したエラー履歴を削除
                    UserDefault.removeErrorObject()
                } else {
                    
                    print("夜のニュース 'false' を返す")
                    // NewsViewControllerへキャッシュでUI更新を指示する値を返す
                    doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: false)
                }
            }
        }

        //どの時間割にも当てはまらない場合
        else {
            
            print("いずれも当てはまらないので 'false' を返す")
            // NewsViewControllerへキャッシュでUI更新を指示する値を返す
            doneCatchTimeScheduleProtocol?.catchTimeSchedule(updateOrCache: false)
        }
    }
}
