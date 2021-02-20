//
//  FavoriteNewsViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/20.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit
import UIKit
import Firebase
import FirebaseFirestore
import Kingfisher

// ニュースへのコメントを扱うクラス
class FavoriteNewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: - Property
    // TableViewのインスタンス
    @IBOutlet weak var favoriteNewsTable: UITableView!
    
    // 構造体のインスタンス
    var userInfomation        : [UserInfoStruct]  = []
    var favoriteNewsInfomation: [NewsInfoStruct]  = []
    
    // fireStoreのインスタンス
    let fireStoreDB = Firestore.firestore()
    

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        // delegateを委託
        favoriteNewsTable.delegate   = self
        favoriteNewsTable.dataSource = self
        
        // NavigationBarの呼び出し
        setFavoriteNewsNavigationBar()
    }
    
    
    // MARK: - ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // fireStoreDBからユーザー情報を取得する
        loadFavoriteNews()
        
        // タイムラインの更新(表示)をおこなう
        self.favoriteNewsTable.reloadData()
    }
    
    
    // MARK: - Navigation
    // ニュースページのNavigationBarを設定
    func setFavoriteNewsNavigationBar() {
        
        // NavigationBarのタイトルとその色とフォント
        navigationItem.title = "お気に入りニュース"
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
    
    
    // MARK: - LoadFavoriteNews
    // fireStoreDBからお気に入りニュースを取得する
    func loadFavoriteNews() {
        
        // 日時の早い順に値をsnapShotに保存
        fireStoreDB.collection(FirestoreCollectionName.newsInfomations).document(Auth.auth().currentUser!.uid).collection(FirestoreCollectionName.favoriteNews).getDocuments {
            (snapShot, error) in
            
            // 投稿情報を受け取る準備
            self.favoriteNewsInfomation = []
            
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
                    
                    // ニュース情報をインスタンス化して構造体に保存
                    let documentNewsTitle    = documentData["newsTitle"] as? String
                    let documentNewsSumbnail = documentData["newsSumbnail"] as? String
                    let documentNewsPubDat   = documentData["newsPubData"] as? String
                    let documentNewsURL      = documentData["newsURL"] as? String
                    let documentSender       = documentData["sender"] as? String
                    
                    let favoriteNewsInfo = NewsInfoStruct(newsTitle: documentNewsTitle!, newsSumbnail: documentNewsSumbnail!, newsPubData: documentNewsPubDat!, newsURL: documentNewsURL!, documentID: document.documentID, sender: documentSender!)
                    
                    // 取得したニュース情報 （NewsInfoStruct型）
                    self.favoriteNewsInfomation.append(favoriteNewsInfo)
                    
                    print("favoriteNewsInfomation: \(self.favoriteNewsInfomation)")
                    
                    // チャット投稿内容の更新
                    self.favoriteNewsTable.reloadData()
                }
            }
        }
    }
    
    
    // MARK: - TableView
    // セクションの数を設定
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // セクションのヘッダーのタイトルを設定
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionTitle = "お気に入り一覧"
        return sectionTitle
    }
    
    // セクションヘッダーの高さを設定
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    // セクションのテキストを設定
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // セクションのテキストのインスタンス
        let categoryLabel = UILabel()
        
        // セクションのテキストを化粧
        categoryLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        categoryLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        categoryLabel.textColor = UIColor.darkGray
        
        return categoryLabel
    }
    
    // セルの数を決める
    func tableView(_ favoriteNewsTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteNewsInfomation.count
    }
    
    // セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        // 投稿者が自身であった場合編集を許可
        if favoriteNewsInfomation[indexPath.row].sender == Auth.auth().currentUser?.uid {
            return true
        } else {
            return false
        }
    }
    
    // セルの削除とfireStoreDBから削除を設定
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let deleteID = favoriteNewsInfomation[indexPath.row].documentID

        // 投稿内容をfireStoreDBから削除
        fireStoreDB.collection(FirestoreCollectionName.newsInfomations).document(Auth.auth().currentUser!.uid).collection(FirestoreCollectionName.favoriteNews).document(deleteID).delete() {
            error in

            // エラー処理
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
                // タイムラインの更新(表示)をおこなう
                self.loadFavoriteNews()
            }
        }
    }
    
    // セルの高さを設定
    func tableView(_ newsTable: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {        
        return 360
    }
    
    // セルを構築
    func tableView(_ favoriteNewsTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // fireStoreDBから取得したニュースの値が入る
        let favoriteNews = favoriteNewsInfomation[indexPath.row]
        
        // tableCellのIDでUITableViewCellのインスタンスを生成
        let cell = favoriteNewsTable.dequeueReusableCell(withIdentifier: "favoriteNewsTable", for: indexPath)
        
        // Tag番号(1)〜(3)でインスタンス作成(サムネイル, タイトル, サブタイトル, コメントボタン)
        let thumbnail         = cell.viewWithTag(1) as! UIImageView
        let newsTitle         = cell.viewWithTag(2) as! UILabel
        let subtitle          = favoriteNewsTable.viewWithTag(3) as! UILabel
        
        // サムネイルで扱うインスタンス(画像URL, 待機画像）
        let thumbnailURL = URL(string: favoriteNews.newsSumbnail)
        let placeholder  = UIImage(named: "placeholder")
        
        // サムネイルの設定
        thumbnail.kf.setImage(with: thumbnailURL, placeholder: placeholder, options: [.transition(.fade(0.7))], progressBlock: nil)
        
        // サムネイルのアスペクト比を設定
        thumbnail.contentMode = .scaleToFill
        
        // ニュースのタイトルから社名を削除
        let replacingOccurrencesString = favoriteNews.newsTitle.replacingOccurrences(of: "(ABEMA TIMES)", with: "")
        
        // ニュースタイトルを化粧
        newsTitle.text = replacingOccurrencesString
        newsTitle.textColor = UIColor(hex: "333333")
        newsTitle.numberOfLines = 3
        
        // サブタイトルを化粧
        subtitle.text = favoriteNews.newsPubData
        subtitle.textColor = UIColor.gray
        
        // セルの境界線を削除
        favoriteNewsTable.separatorStyle = .none
        
        // tableViewの背景色とセルの背景色
        favoriteNewsTable.backgroundColor = UIColor(hex: "f4f8fa")
        cell.backgroundColor      = UIColor.white
        
        // 空のセルを削除
        favoriteNewsTable.tableFooterView = UIView(frame: .zero)
        
        return cell
    }
    
    // セルをタップすると呼ばれる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // タップ時の選択色の常灯を消す
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // WebViewControllerのインスタンス作成
        let webViewController = WebViewController()
        
        // WebViewのNavigationControllerを定義
        let webViewNavigation = UINavigationController(rootViewController: webViewController)
        
        // WebViewをフルスクリーンに
        webViewNavigation.modalPresentationStyle = .fullScreen
        
        // タップしたセルを検知
        let tapCell = self.favoriteNewsInfomation[indexPath.row]
        
        // 検知したセルのurlを取得
        UserDefault.standard.set(tapCell.newsURL, forKey: "url")
        
        // WebViewControllerへ遷移
        present(webViewNavigation, animated: true)
    }
}
