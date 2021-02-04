//
//  ChatViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/04.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit
import Firebase

// チャットページの設定を行うクラス
class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: - Property
    // TableViewのインスタンス
    @IBOutlet weak var chatTable: UITableView!
    
    // textFieldのインスタンス
    @IBOutlet weak var messageTextField: UITextField!
    
    
    // MARK: - FireStore Property
    // fireStoreのインスタンス
    let fireStoreDB = Firestore.firestore()
    
    // firestoreのコレクションが入る
    var roomName: String?
    
    // 構造体のインスタンス
    var chatMessages: [ChatMessage] = []
    
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegateを委託
        chatTable.delegate   = self
        chatTable.dataSource = self

        // NavigationBarの呼び出し
        setChatNavigationBar()
    }
    

    // MARK: - Navigation
    // ニュースページのNavigationBarを設定
    func setChatNavigationBar() {
        
        // NavigationBarのタイトルとその色とフォント
        navigationItem.title = "チャットページ"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19.0, weight: .semibold)]
        
        // NavigationBarの色
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "00AECC")
        
        // 一部NavigationBarがすりガラス？のような感じになるのでfalseで統一
        self.navigationController?.navigationBar.isTranslucent = false
        
        // NavigationBarの下線を削除
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    
    // MARK: - LoadMessages
    // fireStoreDBから値を取得する
    func loadMessages(roomName: String) {
        
        // 日時の早い順に値をsnapShotに保存
        fireStoreDB.collection(roomName).order(by: "date").addSnapshotListener {
            (snapShot, error) in
            
            self.chatMessages = []
            
            // エラー処理
            if error != nil {
                
                print("Message acquisition error: \(error.debugDescription)")
                return
            }
            
            // snapShotの中に保存されている値を取得する
            if let snapShotDocuments = snapShot?.documents {
                
                for document in snapShotDocuments {
                    
                    // fireStoreDBのドキュメントのコレクション（body, date, sender)のインスタンス
                    let documentData = document.data()
                    
                    // 'sender', 'body' がnilでなければ新規メッセージとしてchatMessageに保存
                    if let documentSender = documentData["sender"] as? String, let documentBody = documentData["body"] as? String {
                        
                        let newMessage = ChatMessage(sender: documentSender, body: documentBody)
                        
                        // 新規メッセージ （ChatMessage型）
                        self.chatMessages.append(newMessage)
                        
                        // 非同期でUIの更新
                        DispatchQueue.main.async {
                            
                            // チャット投稿内容の更新
                            self.chatTable.reloadData()
                            
                            // 最新のメッセージまでスクロールする
                            let indexPath = IndexPath(row: self.chatMessages.count-1, section: 0)
                            self.chatTable.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
            }
        }
    }
    

    // MARK: - ChatTabelView
    // セルの数を設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    // セルを構築
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    // 送信ボタンをタップすると呼ばれる
    @IBAction func tapSendMessage(_ sender: Any) {
        print("送信ボタンをタップ")
        
        // textFieldのテキストとユーザーのemailを取得してfireStoreDBのフィールドに合わせて保存
        if let messageBody = messageTextField.text, let sender = Auth.auth().currentUser?.email {
            
            fireStoreDB.collection(roomName!).addDocument(data: ["sender": sender, "body": messageBody, "date": DateItems.date.timeIntervalSince1970]) {
                error in
                
                // エラー処理
                if error != nil {
                    
                    print("Message save error: \(error.debugDescription)")
                    return
                }
                
                // 非同期でUIを更新
                DispatchQueue.main.async {
                    
                    // fireStoreDBへの保存を終えたらtextFieldを空にしてキーボードを閉じる
                    self.messageTextField.text = ""
                    self.messageTextField.resignFirstResponder()
                }
            }
        }
        
    }
}
