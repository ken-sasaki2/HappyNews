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
import StoreKit
import MessageUI

// アプリの設定や、レビューなどをおこなえるメニュー画面
class AccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    
    // MARK: - Property
    // インスタンス作成
    @IBOutlet var table: UITableView!
    
    // セクションのタイトル
    let sectionTitleArray: [String] = ["設定", "このアプリについて", "アカウント"]
    
    // セクション毎のアイコンの配列
    let settingSectionIconArray: [String] = ["notification"]
    let appSectionIconArray    : [String] = ["share", "review", "mail", "twitter", "version"]
    let accountSectionIconArray: [String] = ["logout"]
    
    // セクション毎のセルのラベル
    let settingCellLabelArray: [String] = ["通知の設定"]
    let appCellLabelArray    : [String] = ["シェア", "レビュー", "ご意見・ご要望", "開発者（Twitter）", "HappyNews ver. 1.0"]
    let accountCellLabelArray: [String] = ["ログアウト"]
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        // NavigationBarの呼び出し
        setAccountNavigationBar()
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
        
        // ログイン後の'back'ボタンを削除
        self.navigationItem.hidesBackButton = true
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
        
        // 設定セクションの場合
        if section == sectionTitleArray.firstIndex(of: "設定") {
            return settingSectionIconArray.count
        }
        
        // このアプリについてセクションの場合
        else if section == sectionTitleArray.firstIndex(of: "このアプリについて") {
            return appSectionIconArray.count
        }
        
        // アカウントセクションの場合
        else if section == sectionTitleArray.firstIndex(of: "アカウント") {
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
        
        // 設定セクションの場合
        if indexPath.section == sectionTitleArray.firstIndex(of: "設定") {
            
            // アイコンの設定
            let settingSectionIcon = UIImage(named: settingSectionIconArray[indexPath.row])
            let settingIcon = cell.viewWithTag(1) as! UIImageView
                settingIcon.image = settingSectionIcon
            
            // ラベルの設定
            let settingLabel = cell.viewWithTag(2) as! UILabel
                settingLabel.text = settingCellLabelArray[indexPath.row]
                settingLabel.textColor = UIColor(hex: "333333")
            
        }
        
        // このアプリについてセクションの場合
        else if indexPath.section == sectionTitleArray.firstIndex(of: "このアプリについて") {
            
            // アイコンの設定
            let appSectionIcon = UIImage(named: appSectionIconArray[indexPath.row])
            let appIcon = cell.viewWithTag(1) as! UIImageView
                appIcon.image = appSectionIcon
            
            // ラベルの設定
            let appLabel = cell.viewWithTag(2) as! UILabel
                appLabel.text = appCellLabelArray[indexPath.row]
                appLabel.textColor = UIColor(hex: "333333")
            
        }
        
        // アカウントセクションの場合
        else if indexPath.section == sectionTitleArray.firstIndex(of: "アカウント") {
            
            // アイコンの設定
            let accountSectionIcon = UIImage(named: accountSectionIconArray[indexPath.row])
            let accountIcon = cell.viewWithTag(1) as! UIImageView
                accountIcon.image = accountSectionIcon
            
            // ラベルの設定
            let accountLabel = cell.viewWithTag(2) as! UILabel
                accountLabel.text = accountCellLabelArray[indexPath.row]
                accountLabel.textColor = UIColor.red
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
    }
    
    // セルをタップすると呼ばれる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // タップ時の選択色の常灯を消す
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // セクション毎のタップアクションを分岐
        // "設定"セクションの場合
        if indexPath.section == sectionTitleArray.firstIndex(of: "設定") {

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
        
        // "アカウント"セクションの場合
        else if indexPath.section == sectionTitleArray.firstIndex(of: "アカウント") {
            
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
    //ログアウト機能
    func logoutAlert() {
        
        //アラートの作成
        let alert = UIAlertController(title: "ログアウトしますか？", message: "ログアウトすると通知の設定がリセットされます。", preferredStyle: .alert)
        
        // アラートのボタン
        alert.addAction(UIAlertAction(title: "キャンセル", style: .default))
        alert.addAction(UIAlertAction(title: "ログアウト", style: .destructive, handler: {
            action in
            
            // ログアウト機能
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }

            // ログインページのインスタンスを作成しNavigationを継承
            let loginView = LoginViewController()
            let loginViewController = UINavigationController(rootViewController: loginView)
            
            // モーダル画面をフルスクリーンに設定し遷移
            loginViewController.modalPresentationStyle = .fullScreen
            self.present(loginViewController, animated: true, completion: nil)
        }))
        
        // アラートの表示
        present(alert, animated: true, completion: nil)
    }
}
