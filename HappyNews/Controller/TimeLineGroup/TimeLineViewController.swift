//
//  TimeLineViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/08.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import Kingfisher

class TimeLineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: - Property
    // テーブルビューのインスタンス
    @IBOutlet weak var timeLineTable: UITableView!
    
    
    // MARK: - FireStore Property
    // fireStoreのインスタンス
    let fireStoreDB = Firestore.firestore()
    
    // fireStoreDBのコレクションが入る
    var roomName: String?
    
    // アプリ内から取得する画像データとユーザー名
    var aiconImageString: String?
    var userNameString  : String?
    
    // 構造体のインスタンス
    var timeLineMessages: [TimeLineMessage] = []
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // delegateを委託
        timeLineTable.delegate   = self
        timeLineTable.dataSource = self
        
        // カスタムセルの登録
        timeLineTable.register(UINib(nibName: "TimeLineTableViewCell", bundle: nil), forCellReuseIdentifier: "timeLineCustomCell")
        
        // カスタムセルの高さの初期値を設定し、セルごとに可変するセルを作成
        timeLineTable.estimatedRowHeight = 95
        timeLineTable.rowHeight = UITableView.automaticDimension
        
        // NavigationBarの呼び出し
        setTimeLineNavigationBar()
        
        // 投稿ボタンの呼び出し
        goSubmissionPage()
    }
    
    
    // MARK: - ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // fireStoreDBのコレクションを指定して解析
        roomName = "TimeLineMessage"
        
        // タイムラインの更新(表示)をおこなう
        loadTimeLine()
    }
    
    
    // MARK: - Navigation
    // タイムラインページのNavigationBarを設定
    func setTimeLineNavigationBar() {
        
        // NavigationBarのタイトルとその色とフォント
        navigationItem.title = "タイムライン"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19.0, weight: .semibold)]
        
        // NavigationBarの色
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "00AECC")
        
        // 一部NavigationBarがすりガラス？のような感じになるのでfalseで統一
        self.navigationController?.navigationBar.isTranslucent = false
        
        // NavigationBarの下線を削除
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    // スクロールでナビゲーションバーを隠す
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    
    // MARK: - LoadTimeLine
    // fireStoreDBから値を取得してタイムラインの更新(表示)をおこなう
    func loadTimeLine() {
        
        // 日時の早い順に値をsnapShotに保存
        fireStoreDB.collection(roomName!).order(by: "date").addSnapshotListener {
            (snapShot, error) in
            
            // 投稿情報を受け取る準備
            self.timeLineMessages = []
            
            // Firestoreの中身を確認
            print("snapShot: \(snapShot?.documents)")
            print("snapShot.count: \(snapShot?.documents.count)")
            
            // エラー処理
            if error != nil {
                
                print("Message acquisition error: \(error.debugDescription)")
                return
            }
            
            // snapShotの中に保存されている値を取得する
            if let snapShotDocuments = snapShot?.documents {
                
                for document in snapShotDocuments {
                    
                    // fireStoreDBのドキュメントのコレクションのインスタンス
                    let documentData = document.data()
                    
                    // '送信者ID', '本文'などをインスタンス化して新規メッセージとしてnewMessageに保存
                    let documentSender             = documentData["sender"] as? String
                    let documentBody               = documentData["body"] as? String
                    let documentAiconImage         = documentData["aiconImage"] as? String
                    let documentUserName           = documentData["userName"] as? String
                    let documentSendTime           = documentData["date"] as? Date
                    
                    let newMessage = TimeLineMessage(sender: documentSender!, body: documentBody!, aiconImage: documentAiconImage!, userName: documentUserName!)
                    
                    // 新規メッセージ （ChatMessage型）
                    self.timeLineMessages.append(newMessage)
                    
                    print("timeLineMessages: \(self.timeLineMessages)")
                    
                    // トップが最新になるようにチャット投稿内容の更新
                    self.timeLineMessages.reverse()
                    self.timeLineTable.reloadData()
                }
            }
        }
    }
    
    
    // MARK: - TableView
    // セクションの数を設定
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // セルの数を決める
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeLineMessages.count
    }
    
    // セルを構築
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // カスタムセルのIDでTimeLineTableViewCellのインスタンスを生成
        let cell = timeLineTable.dequeueReusableCell(withIdentifier: "timeLineCustomCell", for: indexPath) as! TimeLineTableViewCell
        
        // firestoreDBから取得した新規メッセージを保存
        let timeLineMessage = timeLineMessages[indexPath.row]
        
        // セルに表示する内容を設定
        cell.sendBody.text   = timeLineMessage.body
        cell.senderName.text = timeLineMessage.userName
//        cell.sendTime.text   = timeLineMessage.data
        cell.sendImageView.kf.setImage(with: URL(string: timeLineMessage.aiconImage))
        
        // セルとTableViewの背景色の設定
        cell.backgroundColor          = UIColor(hex: "f4f8fa")
        timeLineTable.backgroundColor = UIColor(hex: "f4f8fa")
        
        // 空のセルを削除
        timeLineTable.tableFooterView = UIView(frame: .zero)
        
        // セルのタップを無効
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    // セルをタップすると呼ばれる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // タップ時の選択色の常灯を消す
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    
    // MARK: - SendMessageButton
    // 投稿ページへ遷移するボタン
    func goSubmissionPage() {
        
        // 投稿ボタンのインスタンス
        let sendButton = UIButton()
        
        // 'Autosizing'を'AutoLayout'に変換
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        // ボタンを化粧
        sendButton.tintColor = .white
        sendButton.backgroundColor = UIColor(hex: "00AECC")
        sendButton.layer.cornerRadius = 25
        sendButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        
        // ボタンがタップされた時の挙動を記述してviewに反映
        sendButton.addTarget(self, action: #selector(tapSubmissionButton), for: .touchUpInside)
        self.view.addSubview(sendButton)

        // 以下、制約
        // sendButtonの下端をViewの下端から上に95pt
        sendButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -95).isActive = true
        
        // sendButtonの右端をViewの右端から左に15pt
        sendButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15).isActive = true
        
        // sendButtonの幅を50にする
        sendButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // sendButtonの高さを50にする
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    // 投稿ボタンをタップすると呼ばれる
    @objc func tapSubmissionButton() {
        
        // 投稿ページへ遷移
        self.performSegue(withIdentifier: "goSubmissionPage", sender: nil)
    }
    
    
    // MARK: - TimeLineUpdate
    // 更新ボタンをタップすると呼ばれる
    @IBAction func timeLineUpdate(_ sender: Any) {
        print("タップ")
    }
}
