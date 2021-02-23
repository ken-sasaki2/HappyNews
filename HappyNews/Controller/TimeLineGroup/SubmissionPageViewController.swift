//
//  SubmissionPageViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/08.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import PKHUD

// ▼参照しているclass
// TimeLineMessage
// NewsCount
// UserDefault
// UserInfoStruct
// FirestoreCollectionName
// DateItems

// タイムラインへの投稿と感情分析とFirestoreとのやりとりをおこなう
class SubmissionPageViewController: UIViewController, DoneCatchTimeLineTranslationProtocol, DoneCatchTimeLineAnalyzerProtocol {
    
    
    // MARK: - Property
    @IBOutlet weak var sendMessageButton: UIButton!
    
    // テキストビューのインスタンス
    @IBOutlet weak var timeLineTextView: UITextView!
    
    // FireStoreのインスタンス
    let fireStoreDB = Firestore.firestore()
    
    // 構造体のインスタンス
    var timeLineMessages: [TimeLineMessage] = []
    var userInfomation  : [UserInfoStruct]  = []
    
    // 感情分析に投げる翻訳後のテキスト
    var toneAnalyzerText: String?
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // 投稿ボタンの角丸
        sendMessageButton.layer.cornerRadius = 6
        
        // テキストビューの化粧
        timeLineTextView.textColor = UIColor(hex: "333333")
        timeLineTextView.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        
        // キーボードを自動的に表示
        self.timeLineTextView.becomeFirstResponder()
        
        // ユーザー情報を取得
        loadUserInfomation()
    }
    
    
    // MARK: - LoadUserInfo
    // fireStoreDBからユーザー情報を取得する
    func loadUserInfomation() {
        
        // 直列処理キュー作成
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue")
        
        // 直列処理開始
        dispatchGroup.enter()
        dispatchQueue.async(group: dispatchGroup) {
            
            // 日時の早い順に値をsnapShotに保存
            self.fireStoreDB.collection(FirestoreCollectionName.users).document(Auth.auth().currentUser!.uid).getDocument {
                (document, error) in
                
                // エラー処理
                if error != nil {
                    
                    print("UserInfo acquisition error: \(error.debugDescription)")
                    return
                }
                
                // document == fireStoreDBからdocumentIDを指定して取得
                if let document = document {
                    let dataDescription = document.data()
                    
                    // アカウント情報を受け取る準備
                    self.userInfomation = []
                    
                    // キー値を指定して値を取得
                    let documentUserName  = dataDescription!["userName"] as? String
                    let documentUserImage = dataDescription!["userImage"] as? String
                    let documentSender    = dataDescription!["sender"] as? String
                    
                    // 構造体にまとめてユーザー情報を保管
                    let userInfo = UserInfoStruct(userName: documentUserName!, userImage: documentUserImage!, sender: documentSender!)
                    
                    // UserInfoStruct型で保存してUIを更新
                    self.userInfomation.append(userInfo)
                    
                    print("userInfomation: \(self.userInfomation)")
                }
                // 直列処理終了
                dispatchGroup.leave()
            }
        }
    }
    
    
    // MARK: - TapCancelButton
    // ×ボタンをタップすると呼ばれる
    @IBAction func tapCancelButton(_ sender: Any) {
        
        // 投稿画面を閉じる
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - TapSendMessage
    // 投稿ボタンをタップすると呼ばれる
    @IBAction func tapsendMessageButton(_ sender: Any) {
        
        // 投稿内容が空でなければ
        if timeLineTextView.text.isEmpty != true {
            
            // 感情分析中であることをユーザーに伝える
            HUD.show(.labeledProgress(title: "Happyを分析中...", subtitle: nil))
            
            // 感情分析モデルと通信
            let timeLineTranslatorModel = TimeLineTranslatorModel(timeLineTranslatorApiKey: LANGUAGE_TRANSLATOR_CHARGEKEY, timeLineTranslatorVersion: LANGUAGE_TRANSLATOR_VERSION, timeLineTranslatorURL: LANGUAGE_TRANSLATOR_URL, timeLineBody: timeLineTextView.text)
            
            // プロトコルの委託と翻訳の開始
            timeLineTranslatorModel.doneCatchTimeLineTranslationProtocol = self
            timeLineTranslatorModel.setTimeLineTranslator()
        } else {
            
            // 投稿内容がnilであることをユーザーに伝えるアラートの設定
            let notTextAlert = UIAlertController(title: "投稿失敗", message: "テキストを入力してください。", preferredStyle: .alert)
            
            // アラートのボタン
            notTextAlert.addAction(UIAlertAction(title: "やり直す", style: .default))
            
            // アラートの表示
            self.present(notTextAlert, animated: true, completion: nil)
        }
    }
    
    // TimeLineTranslatorModelから値を受け取る
    func catchTranslation(timeLineTranslationText: String) {
        print("timeLineTranslationText: \(timeLineTranslationText)")
        
        // 翻訳結果を代入
        toneAnalyzerText = timeLineTranslationText
        
        // 翻訳結果で分岐
        if toneAnalyzerText != nil {
            
            // 感情分析を開始
            startTimeLineToneAnalyzer()
        }
    }
    
    
    // MARK: - StartTimeLineToneAnalyzer
    // TimeLineToneAnalyzerModelと通信をおこない、感情分析結果を保存する
    func startTimeLineToneAnalyzer() {
        
        // sampleとAPIToneAnalyzerの認証コードで通信
        let timeLineToneAnalyzerModel = TimeLineToneAnalyzerModel(toneAnalyzerApiKey: TONE_ANALYZER_CHARGEKEY, toneAnalyzerVersion: TONE_ANALYZER_VERSION, toneAnalyzerURL: TONE_ANALYZER_URL, toneAnalyzerText: toneAnalyzerText!)
        
        // プロトコルの委託と感情分析を開始
        timeLineToneAnalyzerModel.doneCatchTimeLineAnalyzerProtocol = self
        timeLineToneAnalyzerModel.setTimeLineToneAnalyzer()
    }
    
    // 感情分析結果を受け取りBool型で次の指示を実行
    func catchAnalyzer(joyOrOther: Bool) {
        
        // JoyならFirestoreへ保存して内容を反映
        if joyOrOther == true {
            
            // 非同期で処理を実行
            DispatchQueue.main.async {
                
                // 投稿ボタンタップ時刻の取得（タップ時の現在時刻を取得したいのでDateTimesは使わない）
                let now = Date()
                
                // 地域とフォーマットを指定
                DateItems.dateFormatter.locale = Locale(identifier: "ja_JP")
                DateItems.dateFormatter .dateFormat = "yyyy年M月d日(EEEEE) H時m分s秒"
                
                // 一度String型に変換してDate型に変換
                let sendTimeString = DateItems.dateFormatter.string(from: now)
                let sendTime       = DateItems.dateFormatter.date(from: sendTimeString)
                
                // 1. 送信者のuid
                // 2. 投稿内容
                // 3. アイコン画像
                // 4. ユーザー名
                // 5. 投稿日時
                // 計5点をfireStoreDBへ保存
                if let sender = Auth.auth().currentUser?.uid, let timeLineMessage = self.timeLineTextView.text {
                    
                    self.fireStoreDB.collection(FirestoreCollectionName.timeLineMessages).document().setData(["sender"     : sender,
                         "body"       : timeLineMessage,
                         "aiconImage" : self.userInfomation[NewsCount.zeroCount].userImage,
                         "userName"   : self.userInfomation[NewsCount.zeroCount].userName,
                         "createdTime": sendTime]) {
                        error in
                        
                        // エラー処理
                        if error != nil {
                            
                            print("Message save error: \(error.debugDescription)")
                            return
                        }
                    }
                    
                    // 感情分析が終了したことをユーザーに伝える
                    HUD.flash(.labeledSuccess(title: "投稿完了", subtitle: nil), onView: self.view, delay: 0) { _ in
                        
                        // 入力内容の削除
                        self.timeLineTextView.text = ""
                        
                        // 投稿画面を閉じる
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        } else {
            
            // 非同期で処理を実行
            DispatchQueue.main.async {
                
                // PKHUDの終了
                HUD.hide(animated: true)
                
                // 感情分析が終了したことをユーザーに伝えるアラートの設定
                let notJoyAlert = UIAlertController(title: "投稿失敗", message: "投稿内容はHappyと検知されませんでした。", preferredStyle: .alert)
                
                // アラートのボタン
                notJoyAlert.addAction(UIAlertAction(title: "やり直す", style: .default))
                
                // アラートの表示
                self.present(notJoyAlert, animated: true, completion: nil)
                
                // 入力内容の削除
                self.timeLineTextView.text = ""
            }
        }
    }
}
