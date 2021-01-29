//
//  LocalNotificationModel.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/01/29.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import Foundation
import UIKit

// ▼関係するclass
// NewsViewControler
// AppDelegate

// 特定の時刻に通知を送信する
class LocalNotificationModel {
    
    // ローカルPush通知で必要なインスタンス作成
    var notificationContent = UNMutableNotificationContent()
    var notificationTime    = DateComponents()
    
    
    // MARK: - MorningNotification
    // 朝のローカルPush通知 (07:00)
    func morningNotification() {
        
        // 通知を発火させるきっかけを定義するインスタンス
        let morningTrigger: UNNotificationTrigger

        // 通知内容の設定
        notificationContent.title    = "【お知らせ】HappyNewsを更新"
        notificationContent.subtitle = "新たなニュースを取得できます"
        notificationContent.sound    = .default

        // 通知時間の設定
        notificationTime.hour   = 7
        notificationTime.minute = 0
        morningTrigger = UNCalendarNotificationTrigger(dateMatching: notificationTime, repeats: true)

        // 通知の発火を要求
        let morningRequest = UNNotificationRequest(identifier: "morningNotification", content: notificationContent, trigger: morningTrigger)
        UNUserNotificationCenter.current().add(morningRequest, withCompletionHandler: nil)
    }
    
    
    // MARK: - AfternoonNotification
    // 昼のローカルPush通知の作成 (11:00)
    func afternoonNotification() {
        
        // 通知を発火させるきっかけを定義するインスタンス
        let afternoonTrigger: UNNotificationTrigger
        
        // 通知内容の設定
        notificationContent.title    = "【お知らせ】HappyNewsを更新"
        notificationContent.subtitle = "新たなニュースを取得できます"
        notificationContent.sound    = .default
        
        // 通知時間の設定
        notificationTime.hour   = 11
        notificationTime.minute = 0
        afternoonTrigger = UNCalendarNotificationTrigger(dateMatching: notificationTime, repeats: true)
        
        // 通知の発火を要求
        let afternoonRequest = UNNotificationRequest(identifier: "afternoonNotification", content: notificationContent, trigger: afternoonTrigger)
        UNUserNotificationCenter.current().add(afternoonRequest, withCompletionHandler: nil)
    }
    
    
    // MARK: - EveningNotification
    // 夕方のローカルPush通知の作成 (17:00)
    func eveningNotification() {
        
        // 通知を発火させるきっかけを定義するインスタンス
        let eveningTrigger: UNNotificationTrigger
        
        // 通知内容の設定
        notificationContent.title    = "【お知らせ】HappyNewsを更新"
        notificationContent.subtitle = "新たなニュースを取得できます"
        notificationContent.sound    = .default
        
        // 通知時間の設定
        notificationTime.hour   = 17
        notificationTime.minute = 0
        eveningTrigger = UNCalendarNotificationTrigger(dateMatching: notificationTime, repeats: true)
        
        // 通知の発火を要求
        let eveningRequest = UNNotificationRequest(identifier: "eveningNotification", content: notificationContent, trigger: eveningTrigger)
        UNUserNotificationCenter.current().add(eveningRequest, withCompletionHandler: nil)
    }
}
