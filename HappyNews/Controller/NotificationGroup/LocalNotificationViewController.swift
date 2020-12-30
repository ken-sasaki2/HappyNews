//
//  LocalNotificationViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/12/30.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LocalNotificationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ユーザー情報の確認
        print(Auth.auth().currentUser?.uid)
        print(Auth.auth().currentUser?.displayName)
        
        //ローカルPush通知の呼び出し
        morningLocalNotification()
        afternoonLocalNotification()
        eveningLocalNotification()
    }
    
    //朝のローカルPush通知の作成
    func morningLocalNotification() {
        
        //ローカルPush通知のインスタンス作成
        let morningContent = UNMutableNotificationContent()
        var morningNotificationTime = DateComponents()
        let morningTrigger: UNNotificationTrigger
        
        //通知内容の設定
        morningContent.title    = "【お知らせ】朝のHappyNews更新"
        morningContent.subtitle = "新たなニュースを取得できます"
        morningContent.sound    = .default
        
        //通知時間の設定
        morningNotificationTime.hour = 7
        morningNotificationTime.minute = 0
        morningTrigger = UNCalendarNotificationTrigger(dateMatching: morningNotificationTime, repeats: false)
        
        //通知の表示
        let morningRequest = UNNotificationRequest(identifier: "LocalNotification", content: morningContent, trigger: morningTrigger)
        UNUserNotificationCenter.current().add(morningRequest, withCompletionHandler: nil)
    }
    
    //昼のローカルPush通知の作成
    @objc func afternoonLocalNotification() {
        
        //ローカルPush通知のインスタンス作成
        let afternoonContent = UNMutableNotificationContent()
        var afternoonNotificationTime = DateComponents()
        let afternoonTrigger: UNNotificationTrigger
        
        //通知内容の設定
        afternoonContent.title    = "【お知らせ】昼のHappyNews更新"
        afternoonContent.subtitle = "新たなニュースを取得できます"
        afternoonContent.sound    = .default
        
        //通知時間の設定
        afternoonNotificationTime.hour = 12
        afternoonNotificationTime.minute = 0
        afternoonTrigger = UNCalendarNotificationTrigger(dateMatching: afternoonNotificationTime, repeats: false)
        
        //通知の表示
        let afternoonRequest = UNNotificationRequest(identifier: "LocalNotification", content: afternoonContent, trigger: afternoonTrigger)
        UNUserNotificationCenter.current().add(afternoonRequest, withCompletionHandler: nil)
    }
    
    //夕方のローカルPush通知の作成
    @objc func eveningLocalNotification() {
        
        //ローカルPush通知のインスタンス作成
        let eveningContent = UNMutableNotificationContent()
        var eveningNotificationTime = DateComponents()
        let eveningTrigger: UNNotificationTrigger
        
        //通知内容の設定
        eveningContent.title    = "【お知らせ】夕方のHappyNews更新"
        eveningContent.subtitle = "新たなニュースを取得できます"
        eveningContent.sound    = .default
        
        //通知時間の設定
        eveningNotificationTime.hour = 17
        eveningNotificationTime.minute = 0
        eveningTrigger = UNCalendarNotificationTrigger(dateMatching: eveningNotificationTime, repeats: false)
        
        //通知の表示
        let eveningRequest = UNNotificationRequest(identifier: "LocalNotification", content: eveningContent, trigger: eveningTrigger)
        UNUserNotificationCenter.current().add(eveningRequest, withCompletionHandler: nil)
    }
}
