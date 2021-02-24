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
import PKHUD
import MessageUI

// ▼参照しているclass
// TimeLineMessage
// NewsCount
// UserDefault
// UserInfoStruct
// FirestoreCollectionName
// DateItems

class TimeLineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    
    // MARK: - Property
    // テーブルビューのインスタンス
    @IBOutlet weak var timeLineTable: UITableView!
    
    
    // MARK: - FireStore Property
    // fireStoreのインスタンス
    let fireStoreDB = Firestore.firestore()
    
    // 構造体のインスタンス
    var timeLineMessages: [TimeLineMessage] = []
    var userInfomation  : [UserInfoStruct]  = []
    var blockUsers      : [BlockUsers]      = []
    
    
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
        
        // ブロッツしたユーザーを取得する
        searchBlockUser()
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
    
    // MARK: - SearchBlockUser
    func searchBlockUser() {
        
        fireStoreDB.collection(FirestoreCollectionName.users).document(Auth.auth().currentUser!.uid).collection(FirestoreCollectionName.blockUsers).getDocuments {
            (snapShot, error) in
            
            // ブロックしたユーザー情報を受け取る準備
            self.blockUsers = []
            
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
                    
                    // fireStoreDBから値を取得してblockUserInfoに保存
                    let documentBlockUserID   = documentData["blockUserID"] as? String
                    let documentBlockUserName = documentData["blockUserName"] as? String
                    
                    let blockUserInfo = BlockUsers(blockUserID: documentBlockUserID!, blockUserName: documentBlockUserName!)
                    
                    // ブロックしたユーザ一覧（BlockUsers型）
                    self.blockUsers.append(blockUserInfo)
                    
                    print("blockUsers: \(self.blockUsers)")
                    
                    // タイムラインの更新(表示)をおこなう
                    self.loadTimeLine()
                }
            }
                    
        }
    }
    
    
    // MARK: - LoadTimeLine
    // fireStoreDBから値を取得してタイムラインの更新(表示)をおこなう
    func loadTimeLine() {
        
        // 日時の早い順に値をsnapShotに保存
        fireStoreDB.collection(FirestoreCollectionName.timeLineMessages).order(by: "createdTime", descending: true).addSnapshotListener {
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
                    
                    // timestampを取得してDate型に変換
                    let timestamp: Timestamp = documentData["createdTime"] as! Timestamp
                    let dateValue = timestamp.dateValue()
                    
                    // 地域とスタイルを指定してString型へ変換
                    DateItems.dateFormatter.locale = Locale(identifier: "ja_JP")
                    DateItems.dateFormatter.dateStyle = .short
                    DateItems.dateFormatter.timeStyle = .short
                    let createdTime = DateItems.dateFormatter.string(from: dateValue)
                    
                    let newMessage = TimeLineMessage(sender: documentSender!, body: documentBody!, aiconImage: documentAiconImage!, userName: documentUserName!, documentID: document.documentID, createdTime: createdTime)
                    
                    // ブロックユーザーを検索
                    for i in 0..<self.blockUsers.count {
                        
                        // ブロックユーザーの投稿は新規メッセージとして追加しない
                        if self.blockUsers[i].blockUserID != newMessage.sender {
                            
                            // 新規メッセージ （ChatMessage型）
                            self.timeLineMessages.append(newMessage)
                        } else {
                            break
                        }
                    }
                    
                    print("timeLineMessages: \(self.timeLineMessages)")
                    
                    // チャット投稿内容の更新
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
    
    // セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // セルの編集アクションをカスタム
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // 自身の投稿内容を削除するアクションをカスタム
        let deleteAction = UITableViewRowAction(style: .default, title: "削除", handler: {
            (rowAction, indexPath) in
            
            // 削除するセルのDdokyumenntoID
            let deleteID = self.timeLineMessages[indexPath.row].documentID
            
            // 投稿内容をfireStoreDBから削除
            self.fireStoreDB.collection(FirestoreCollectionName.timeLineMessages).document(deleteID).delete() {
                error in
                
                // エラー処理
                if let error = error {
                    print("Error removing document: \(error)")
                } else {
                    print("Document successfully removed!")
                    // タイムラインの更新(表示)をおこなう
                    self.loadTimeLine()
                }
            }
        })
        
        // 他ユーザーをブロックするアクションをカスタム
        let blockAction = UITableViewRowAction(style: .default, title: "ブロック", handler: {
            (rowAction, indexPath) in
            
            // fireStoreDBにブロックしたユーザー情報を保存
            self.fireStoreDB.collection(FirestoreCollectionName.users).document(Auth.auth().currentUser!.uid).collection(FirestoreCollectionName.blockUsers).document().setData(
                ["blockUserID"   : self.timeLineMessages[indexPath.row].sender,
                 "blockUserName" : self.timeLineMessages[indexPath.row].userName
                ]) {
                error in
                
                // エラー処理
                if error != nil {
                    
                    print("Message save error: \(error.debugDescription)")
                    return
                }
            }
        })
        
        // カスタムアクションの背景色
        deleteAction.backgroundColor = UIColor.red
        blockAction.backgroundColor  = UIColor.blue
        
        // 投稿内容がカレントユーザーの場合はブロックをfalse、そうでない場合は削除をfalse
        if self.timeLineMessages[indexPath.row].sender == Auth.auth().currentUser?.uid {
            return [deleteAction]
        } else {
            return [blockAction]
        }
        
        return [deleteAction, blockAction]
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
        cell.sendTime.text   = timeLineMessage.createdTime
        cell.sendImageView.kf.setImage(with: URL(string: timeLineMessage.aiconImage))
        
        // セルとTableViewの背景色の設定
        cell.backgroundColor          = UIColor(hex: "f4f8fa")
        timeLineTable.backgroundColor = UIColor(hex: "f4f8fa")
        
        // 空のセルを削除
        timeLineTable.tableFooterView = UIView(frame: .zero)
        
        return cell
    }
    
    // セルをタップすると呼ばれる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // タップ時の選択色の常灯を消す
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // コメントページへ遷移
        self.performSegue(withIdentifier: "commentPage", sender: indexPath.row)
    }
    
    // segue遷移を設定し、遷移先に値を渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // セグエの識別子を確認
        if segue.identifier == "commentPage" {
            
            // 遷移先のインスタンスとindexPath.rowを指定
            if let nextCommentPage = segue.destination as? TimeLineCommentViewController, let index = sender as? Int {
                
                // 値を渡す
                nextCommentPage.idString = timeLineMessages[index].documentID
            }
        }
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

        // タイムラインを更新中であることをユーザーに伝える
        HUD.show(.labeledProgress(title: "更新中", subtitle: nil))
        
        // タイムラインの更新
        loadTimeLine()
        
        // PKHUDの終了
        HUD.hide(animated: true)
    }
    
    
    @IBAction func tapReportButton(_ sender: Any) {
        
        // メールを送信できるかどうかの確認
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        
        // インスタンスの作成と委託
        let mailViewController = MFMailComposeViewController()
            mailViewController.mailComposeDelegate = self
        
        // 宛先の設定
        let toRecipients = ["nkeiisasa222@gmail.com"]
        
        // 件名と宛先の表示
        mailViewController.setSubject("'HappyNews'タイムライン及びそのコメント投稿内容の通報")
        mailViewController.setToRecipients(toRecipients)
        mailViewController.setMessageBody("1. 通報する投稿の内容 \n 2. 通報するユーザー名 \n 3. 通報する投稿の時間 \n 4. その他不快なコンテンツに対する連絡　\n \n ▼ 計4点を記載してご連絡ください。 \n 1. \n 2. \n 3. \n 4.", isHTML: false)
        
        self.present(mailViewController, animated: true, completion: nil)
    }
    
    // メール機能終了処理
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // メールの結果で条件分岐
        switch result {
        
        // キャンセルの場合
        case .cancelled:
            print("Email Send Cancelled")
            break
            
        // 下書き保存の場合
        case .saved:
            print("Email Saved as a Draft")
            break
            
        // 送信成功の場合
        case .sent:
            print("Email Sent Successfully")
            break
            
        // 送信失敗の場合
        case .failed:
            print("Email Send Failed")
            break
        default:
            break
        }
        //メールを閉じる
        controller.dismiss(animated: true, completion: nil)
    }
}
