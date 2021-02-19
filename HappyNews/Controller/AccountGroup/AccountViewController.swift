//
//  AccountViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/11/30.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import StoreKit
import MessageUI
import Kingfisher

// アプリの設定や、レビューなどをおこなえるメニュー画面
class AccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    
    // MARK: - Property
    // TableViewのインスタンス
    @IBOutlet var table: UITableView!
    
    // Firestoreのインスタンス
    var fireStoreDB = Firestore.firestore()
    
    // fireStoreDBのコレクション名
    var roomName: String?
    
    // 構造体のインスタンス
    var userInfomation: [UserInfoStruct] = []
    
    // セクションのタイトル
    let sectionTitleArray: [String] = ["アカウント情報", "設定", "このアプリについて", "ログアウト"]
    
    // セクション毎のアイコンの配列
    let settingSectionIconArray : [String] = ["notification"]
    let appSectionIconArray     : [String] = ["share", "review", "mail", "twitter", "version"]
    let accountSectionIconArray : [String] = ["logout"]
    
    // セクション毎のセルのラベル
    var userInfoCellLabelArray: [String] = ["ユーザー名"]
    let settingCellLabelArray : [String] = ["通知の設定"]
    let appCellLabelArray     : [String] = ["シェア", "レビュー", "ご意見・ご要望", "開発者（Twitter）", "HappyNews ver. 1.0"]
    let accountCellLabelArray: [String] = ["ログアウト"]
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        // fireStoreDBのコレクション名
        roomName = "users"
        
        // NavigationBarの呼び出し
        setAccountNavigationBar()
    }
    
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ユーザー情報編集ページから戻ってきた場合にTabBarを表示するように設定
        self.tabBarController?.tabBar.isHidden = false
        
        // NavigationBarのbackボタンのタイトルを編集
        self.navigationItem.backButtonTitle = ""
        
        // ユーザー情報の取得
        loadUserInfomation()
    }
    
    
    // MARK: - Navigation
    // アカウントページのNavigationBarを設定
    func setAccountNavigationBar() {
        
        // NavigationBarのタイトルとその色とフォント
        navigationItem.title = "アカウント"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19.0, weight: .semibold)]
        
        // NavigationBarの色
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "00AECC")
        
        // 一部NavigationBarがすりガラス？のような感じになるのでfalseで統一
        self.navigationController?.navigationBar.isTranslucent = false
        
        // NavigationBarの下線を削除
        self.navigationController?.navigationBar.shadowImage = UIImage()
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
            self.fireStoreDB.collection(self.roomName!).document(Auth.auth().currentUser!.uid).getDocument {
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
                    self.table.reloadData()
                    
                    print("userInfomation: \(self.userInfomation)")
                }
                // 直列処理終了
                dispatchGroup.leave()
            }
        }
    }
    
    
    // MARK: - TableView
    // セクションの数を決める
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitleArray.count
    }
    
    // セクションのヘッダーのタイトルを決める
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitleArray[section]
    }
    
    // セクションヘッダーの高さを決める
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    // セルの数を決める
    func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // "アカウント情報"セクションの場合
        if section == sectionTitleArray.firstIndex(of: "アカウント情報") {
            return settingSectionIconArray.count
        }
        
        // "設定"セクションの場合
        else if section == sectionTitleArray.firstIndex(of: "設定") {
            return settingSectionIconArray.count
        }
        
        // "このアプリについて"セクションの場合
        else if section == sectionTitleArray.firstIndex(of: "このアプリについて") {
            return appSectionIconArray.count
        }
        
        // "ログアウト"セクションの場合
        else if section == sectionTitleArray.firstIndex(of: "ログアウト") {
            return accountSectionIconArray.count
        } else{
            return 0
        }
    }
    
    // セルの高さを設定
    func tableView(_ table: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    // セルを構築
    func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // tableCellのIDでUITableViewCellのインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        // Tag番号(1)〜(2)でインスタンス作成(アイコン, セルの名前)
        let settingIcon  = cell.viewWithTag(1) as! UIImageView
        let settingLabel = cell.viewWithTag(2) as! UILabel
        
        if userInfomation.count > NewsCount.zeroCount {
            
            let user = userInfomation[0]
            
            // "アカウント情報"セクションの場合
            if indexPath.section == sectionTitleArray.firstIndex(of: "アカウント情報") {
                
                // Kingfisherを用いてアカウント画像を変換してデータを反映
                settingIcon.kf.setImage(with: URL(string: user.userImage))
                
                // アカウント画像の角丸
                settingIcon.layer.masksToBounds = true
                settingIcon.layer.cornerRadius = settingIcon.frame.width/2
                settingIcon.clipsToBounds = true
                
                // ラベルの設定
                settingLabel.text      = user.userName
                settingLabel.font      = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
                settingLabel.textColor = UIColor(hex: "333333")
            }
            
            // "設定"セクションの場合
            else if indexPath.section == sectionTitleArray.firstIndex(of: "設定") {
                
                // アイコンの設定
                let settingSectionIcon = UIImage(named: settingSectionIconArray[indexPath.row])
                settingIcon.image = settingSectionIcon
                
                // ラベルの設定
                settingLabel.text      = settingCellLabelArray[indexPath.row]
                settingLabel.textColor = UIColor(hex: "333333")
            }
            
            // "このアプリについて"セクションの場合
            else if indexPath.section == sectionTitleArray.firstIndex(of: "このアプリについて") {
                
                // アイコンの設定
                let appSectionIcon = UIImage(named: appSectionIconArray[indexPath.row])
                settingIcon.image = appSectionIcon
                
                // ラベルの設定
                settingLabel.text      = appCellLabelArray[indexPath.row]
                settingLabel.textColor = UIColor(hex: "333333")
            }
            
            // "ログアウト"セクション"の場合
            else if indexPath.section == sectionTitleArray.firstIndex(of: "ログアウト") {
                
                // アイコンの設定
                let accountSectionIcon = UIImage(named: accountSectionIconArray[indexPath.row])
                settingIcon.image = accountSectionIcon
                
                // ラベルの設定
                settingLabel.text      = accountCellLabelArray[indexPath.row]
                settingLabel.textColor = UIColor.red
            }
            
            // セルとTableViewの背景色の設定
            cell.backgroundColor  = UIColor(hex: "f4f8fa")
            table.backgroundColor = UIColor(hex: "f4f8fa")
            
            // 空のセルを削除
            table.tableFooterView = UIView(frame: .zero)
            
            // バージョンを表示するセルのタップを無効
            if appCellLabelArray[indexPath.row] == appCellLabelArray[4] {
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            }
            
            return cell
        } else {
            return cell
        }
    }
    
    // セルをタップすると呼ばれる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // タップ時の選択色の常灯を消す
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // セクション毎のタップアクションを分岐
        // "アカウント情報"セクションの場合
        if indexPath.section == sectionTitleArray.firstIndex(of: "アカウント情報") {

            switch indexPath.row {
            // ユーザー名のセルをタップした場合
            case userInfoCellLabelArray.firstIndex(of: userInfoCellLabelArray[0]):
                //performSegue(withIdentifier: "editUserInfo", sender: UserInfoStruct(userName: changeUsername!, UserImage: changeUserImage!))
                
                // ユーザー情報編集ページへ画面遷移
                performSegue(withIdentifier: "editUserInfo", sender: nil)
                break
            default:
                break
            }
        }
        
        // "設定"セクションの場合
        else if indexPath.section == sectionTitleArray.firstIndex(of: "設定") {
        
            switch indexPath.row {
            // "通知の設定"セルをタップした場合
            case settingCellLabelArray.firstIndex(of: "通知の設定"):
                transitionSettingPage()
            default:
                break
            }
            
        }
        
        // "このアプリについて"セクションの場合
        else if indexPath.section == sectionTitleArray.firstIndex(of: "このアプリについて") {
            
            switch indexPath.row {
            // "シェア"セルをタップした場合
            case appCellLabelArray.firstIndex(of: "シェア"):
                shareFunction()
                
            // "レビュー"セルをタップした場合
            case appCellLabelArray.firstIndex(of: "レビュー"):
                reviewFunction()
                
            // "ご意見・ご要望"セルをタップした場合
            case appCellLabelArray.firstIndex(of: "ご意見・ご要望"):
                mailFunction()
                
            // "開発者（Twitter）"セルをタップした場合
            case appCellLabelArray.firstIndex(of: "開発者（Twitter）"):
                twitterFunction()
            default:
                break
            }
            
        }
        
        // "ログアウト"セクションの場合
        else if indexPath.section == sectionTitleArray.firstIndex(of: "ログアウト") {
            
            switch indexPath.row {
            // "ログアウト"セルをタップした場合
            case accountCellLabelArray.firstIndex(of: "ログアウト"):
                logoutAlert()
            default:
                break
            }
        }
    }
    
    
    // MARK: - Notification
    // 通知設定機能、端末の設定ページへ遷移
    func transitionSettingPage() {
        let url = URL(string: "app-settings:root=General&path=com.ken.HappyNews")
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    
    // MARK: - Share
    // Twitterシェア機能
    func shareFunction() {
        
        // Twitterシェア用テキスト
        let shareText = "『話題のAIを使ったニュース?!』 \n いますぐ'HappyNews'をダウンロードしよう! \n AppStoreURL"
        
        // URLクエリ内で使用できる文字列に変換
        guard let encodedText = shareText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let tweetURL = URL(string: "https://twitter.com/intent/tweet?text=\(encodedText)") else { return }
        
        // URLに載せてシェア画面を起動
        UIApplication.shared.open(tweetURL, options: [:], completionHandler: nil)
    }
    
    
    // MARK: - Review
    // レビュー機能、ユーザーにレビューを要求
    func reviewFunction() {
        SKStoreReviewController.requestReview()
    }
    
    
    // MARK: - Mail
    // ご意見・ご要望機能
    func mailFunction() {
        
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
        mailViewController.setSubject("'HappyNews'へのご意見・ご要望")
        mailViewController.setToRecipients(toRecipients)
        mailViewController.setMessageBody("▼アプリの不具合などの連絡はこちら \n \n \n \n ▼機能追加依頼はこちら \n \n \n \n ▼その他ご要望はこちら", isHTML: false)
        
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
    
    
    // MARK: - Twitter
    // Twitter紹介機能
    func twitterFunction() {
        
        // 開発者のTwitterアカウントをURL型で定義
        let twitterURL = URL(string: "https://twitter.com/ken_sasaki2")
        
        // twitterURLで遷移、ユーザーのTwitterアカウントが存在しない場合は作成を促す
        if UIApplication.shared.canOpenURL(twitterURL! as URL) {
            UIApplication.shared.open(twitterURL! as URL, options: [:], completionHandler: nil)
        }
    }
    
    
    // MARK: - Logout
    // ログアウト機能
    func logoutAlert() {
        
        // アラートの作成
        let logoutAlert = UIAlertController(title: "ログアウトしますか？",message: "ログアウトするとアプリ内の情報が \n リセットされます。", preferredStyle: .alert)
        
        // アラートのボタン
        logoutAlert.addAction(UIAlertAction(title: "キャンセル", style: .default))
        logoutAlert.addAction(UIAlertAction(title: "ログアウト", style: .destructive, handler: {
            action in
            
            // ログアウト機能(削除する情報4点)
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                
                // 1. UserDefaultsに保存したデータを全削除
                UserDefault.standard.removeAll()
                
                // 2. fireStoreDBに保存したユーザー情報を削除
                self.fireStoreDB.collection("users").document(Auth.auth().currentUser!.uid).delete() {
                    error in
                    
                    // エラー処理
                    if let error = error {
                        print("Error removing document: \(error)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
                
                // 3. fireStoreDBに保存したTimeLine投稿内容を削除
                // 4. ニュースに投稿したコメント内容を削除
                
                // LoginViewControllerへ遷移
                self.performSegue(withIdentifier: "goLogin", sender: nil)
                
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }))
        
        // アラートの表示
        present(logoutAlert, animated: true, completion: nil)
    }
}
