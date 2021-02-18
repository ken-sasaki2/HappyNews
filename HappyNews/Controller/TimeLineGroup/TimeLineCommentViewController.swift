//
//  TimeLineCommentViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/14.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import Kingfisher

// コメントページを扱うクラス
class TimeLineCommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CommentInputAccessoryViewProtocol {
    
    
    // MARK: - Property
    // TableViewのインスタンス
    @IBOutlet weak var commentTable: UITableView!
    
    // コメント送信用viewのインスタンス
    lazy var commentInputAccessoryView: CommentInputAccessoryView = {
        
        let view = CommentInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        
        // プロトコルを委託
        view.commentInputAccessoryViewProtocol = self
        
        return view
    }()
    
    // 構造体のインスタンス
    var commentStruct: [CommentStruct] = []
    
    // アプリ内から取得する画像データとユーザー名
    var aiconImageString: String?
    var userNameString  : String?
    
    
    // MARK: - FireStore Property
    // fireStoreのインスタンス
    let fireStoreDB = Firestore.firestore()
    
    // fireStoreDBのコレクションが入る
    var roomName: String?
    
    // 選択した投稿内容のdocumentIDを受け取る
    var idString: String?
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        // delegateを委託
        commentTable.delegate   = self
        commentTable.dataSource = self
        
        // アプリ内にアカウント画像データとユーザー名があれば代入
        if  UserDefault.imageCapture != nil && UserDefault.getUserName != nil {
            
            aiconImageString = UserDefault.imageCapture
            userNameString   = UserDefault.getUserName
        }
        
        // カスタムセルの登録
        commentTable.register(UINib(nibName: "TimeLineTableViewCell", bundle: nil), forCellReuseIdentifier: "timeLineCustomCell")
        
        // カスタムセルの高さの初期値を設定し、セルごとに可変するセルを作成
        commentTable.estimatedRowHeight = 95
        commentTable.rowHeight = UITableView.automaticDimension
    }
    
    
    // MARK: - ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // fireStoreDBのコレクションを指定
        roomName = "TimeLineMessage"
        
        // タイムラインの更新(表示)をおこなう
        loadComment()
    }
    
    
    // MARK: - LoadComment
    // fireStoreDBから値を取得してUIを更新
    func loadComment() {
        
        // 投稿日時の早い順に値をsnapShotに保存
        fireStoreDB.collection(roomName!).document(idString!).collection("comment").order(by: "createdTime", descending: true).addSnapshotListener {
            (snapShot, error) in
            
            // 投稿情報を受け取る準備
            self.commentStruct = []
            
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
                    
                    // 'ユーザー名', 'コメント'などをインスタンス化して新規コメントとしてnewCommentに保存
                    let documentUserName   = documentData["userName"] as? String
                    let documentAiconImage = documentData["aiconImage"] as? String
                    let documentComment    = documentData["comment"] as? String
                    let documentSender     = documentData["sender"] as? String
                    
                    // timestampを取得してDate型に変換
                    let timestamp: Timestamp = documentData["createdTime"] as! Timestamp
                    let dateValue = timestamp.dateValue()
                    
                    // 地域とスタイルを指定してString型へ変換
                    DateItems.dateFormatter.locale = Locale(identifier: "ja_JP")
                    DateItems.dateFormatter.dateStyle = .short
                    DateItems.dateFormatter.timeStyle = .short
                    let createdTime = DateItems.dateFormatter.string(from: dateValue)
                    
                    let newComment = CommentStruct(sender: documentSender!, comment: documentComment!, aiconImage: documentAiconImage!, userName: documentUserName!, createdTime: createdTime, documentID: document.documentID)
                    
                    // / 新規コメント （commentStruct型）
                    self.commentStruct.append(newComment)
                    
                    print("commentStruct: \(self.commentStruct)")
                    
                    // コメント投稿内容の更新
                    self.commentTable.reloadData()
                }
            }
        }
    }
    
    
    // MARK: - InputAccessoryView
    // CommentViewControllerにcommentInputAccessoryViewを反映
    override var inputAccessoryView: UIView? {
        get {
            return commentInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    
    // MARK: - TableView
    // セクションの数を設定
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // セルの数を決める
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentStruct.count
    }
    
    // セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        // 投稿者が自身であった場合編集を許可
        if commentStruct[indexPath.row].sender == UserDefault.getUID {
            return true
        } else {
            return false
        }
    }
    
    // セルの削除とfireStoreDBから削除を設定
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let deleteID = commentStruct[indexPath.row].documentID
        // 投稿内容をfireStoreDBから削除
        fireStoreDB.collection(roomName!).document(idString!).collection("comment").document(deleteID).delete() {
            error in
            
            // エラー処理
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
                // タイムラインの更新(表示)をおこなう
                self.commentTable.reloadData()
            }
        }
    }
    
    // セルを構築する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // カスタムセルのIDでTimeLineTableViewCellのインスタンスを生成
        let cell = commentTable.dequeueReusableCell(withIdentifier: "timeLineCustomCell", for: indexPath) as! TimeLineTableViewCell
        
        // firestoreDBから取得した新規コメントを取得
        let commentMessage = commentStruct[indexPath.row]
        
        // セルに表示する内容を設定
        cell.senderName.text = UserDefault.getUserName
        cell.sendBody.text   = commentMessage.comment
        cell.sendImageView.kf.setImage(with: URL(string: UserDefault.imageCapture!))
        cell.sendTime.text   = commentMessage.createdTime
        
        // 「コメントを見る」ラベルを削除
        cell.commentLabel.isHidden = true
        
        // セルとTableViewの背景色の設定
        cell.backgroundColor         = UIColor(hex: "f4f8fa")
        commentTable.backgroundColor = UIColor(hex: "f4f8fa")

        // 空のセルを削除
        commentTable.tableFooterView = UIView(frame: .zero)

        // セルのタップを無効
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    
    // MARK: - TapCloseCommentButton
    // ×ボタンをタップすると呼ばれる
    @IBAction func tapCloseCommentButton(_ sender: Any) {
        
        // コメントページを閉じる
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - TapedSendCommentButton
    // CommentInputAccessoryViewクラスから値を受け取る（送信内容）
    func tapedSendCommentButton(comment: String, sendTime: Date) {
        
        // 受け取った値をインスタンス化
        let commentBody = comment
        let createdTime = sendTime
        
        // 受け取った値がnilでなければ
        if commentBody != nil && createdTime != nil {
            
            // uidを取得してインスタンス化
            let sender = UserDefault.getUID
            
            // 受け取った送信内容を含めてfireStoreDBへ保存
            fireStoreDB.collection(roomName!).document(idString!).collection("comment").document().setData(["userName": userNameString, "aiconImage": aiconImageString, "comment": comment, "createdTime": createdTime, "sender": sender]
            )
            
            // fireStoreDBに保存をしたら入力内容を空にしてキーボードを閉じる
            commentInputAccessoryView.commentTextView.text = ""
            commentInputAccessoryView.commentTextView.resignFirstResponder()
        }
    }
}
