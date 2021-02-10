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


// タイムラインへの投稿と感情分析とFirestoreとのやりとりをおこなう
class SubmissionPageViewController: UIViewController, DoneCatchTimeLineTranslationProtocol, DoneCatchTimeLineAnalyzerProtocol {
    
    
    
    // MARK: - Property
    @IBOutlet weak var sendMessageButton: UIButton!
    
    // テキストビューのインスタンス
    @IBOutlet weak var timeLineTextView: UITextView!
    
    // FireStoreのインスタンス
    let fireStoreDB = Firestore.firestore()
    
    // fireStoreDBのコレクションが入る
    var roomName: String?
    
    // アプリ内から取得する画像データとユーザー名
    var aiconImageString: String?
    var userNameString  : String?
    
    // 構造体のインスタンス
    var chatMessages: [ChatMessage] = []
    
    // 感情分析に投げる翻訳後のテキスト
    var toneAnalyzerText: String?
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // アプリ内にアカウント画像データとユーザー名があれば代入
        if  UserDefault.imageCapture != nil && UserDefault.getUserName != nil {
            
            aiconImageString = UserDefault.imageCapture
            userNameString   = UserDefault.getUserName
        }

        // 投稿ボタンの角丸
        sendMessageButton.layer.cornerRadius = 6
        
        // テキストビューの化粧
        timeLineTextView.textColor = UIColor(hex: "333333")
        timeLineTextView.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        
        // キーボードを自動的に表示
        self.timeLineTextView.becomeFirstResponder()
        
        // fireStoreDBのコレクションを指定して解析
        roomName = "TimeLineMessage"
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
        print("投稿")
        
        // 感情分析中であることをユーザーに伝える
        HUD.show(.labeledProgress(title: "Happyを分析中...", subtitle: nil))
        
        // 感情分析モデルと通信
        let timeLineTranslatorModel = TimeLineTranslatorModel(timeLineTranslatorApiKey: LANGUAGE_TRANSLATOR_APIKEY, timeLineTranslatorVersion: languageTranslatorVersion, timeLineTranslatorURL: languageTranslatorURL, timeLineBody: timeLineTextView.text)
        
        // プロトコルの委託と翻訳の開始
        timeLineTranslatorModel.doneCatchTimeLineTranslationProtocol = self
        timeLineTranslatorModel.setTimeLineTranslator()
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
        let timeLineToneAnalyzerModel = TimeLineToneAnalyzerModel(toneAnalyzerApiKey: TONE_ANALYZER_APIKEY, toneAnalyzerVersion: toneAnalyzerVersion, toneAnalyzerURL: toneAnalyzerURL, toneAnalyzerText: toneAnalyzerText!)
        
        // プロトコルの委託と感情分析を開始
        timeLineToneAnalyzerModel.doneCatchTimeLineAnalyzerProtocol = self
        timeLineToneAnalyzerModel.setTimeLineToneAnalyzer()
    }
    
    // 感情分析結果を受け取りBool型で次の指示を実行
    func catchAnalyzer(joyOrOther: Bool) {
        
        if joyOrOther == true {
            print("評価: Joy")
            
            // 非同期で処理を実行
            DispatchQueue.main.async {
                
                // JoyならFirestoreへ保存して内容を反映
                // テキストビューのテキストとユーザーのIDを取得してfireStoreDBのフィールドに合わせて保存
                if let sender = Auth.auth().currentUser?.uid {
                    
                    self.fireStoreDB.collection(self.roomName!).addDocument(data: ["sender": sender, "body": self.timeLineTextView.text, "aiconImage": self.aiconImageString, "userName": self.userNameString, "date": DateItems.date]) {
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
            print("評価: NotJoy")
            
            // 感情分析が終了したことをユーザーに伝える
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                HUD.show(.label("Happyと評価されませんでした。 \n 別の内容を投稿してください。"))
                
                // 入力内容の削除
                self.timeLineTextView.text = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    HUD.hide(animated: true)
                }
            }
        }
    }
}
