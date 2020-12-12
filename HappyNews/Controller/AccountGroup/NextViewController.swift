//
//  NextViewController.swift
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

class NextViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    //インスタンス作成
    @IBOutlet var table: UITableView!
    
    //セクションのタイトル
    let sectionTitleArray: [String] = ["設定", "このアプリについて", "アカウント"]
    
    //セクション毎のアイコンの配列
    let settingSectionIconArray: [String] = ["notification"]
    let appSectionIconArray    : [String] = ["review", "mail", "twitter", "version"]
    let accountSectionIconArray: [String] = ["logout"]
    
    //セクション毎のセルのラベル
    let settingCellLabelArray : [String] = ["通知の設定"]
    let appCellLabelArray     : [String] = ["レビュー", "ご意見・ご要望", "開発者 (Twitter)", "HappyNews ver. 1.0"]
    let accountCellLabelArray : [String] = ["ログアウト"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NavigationBarの呼び出し
        setAccountNavigationBar()
    }
    
    // MARK: - Navigation
    //アカウントページのNavigationBar設定
    func setAccountNavigationBar() {
        
        //NavigationBarのtitleとその色とフォント
        navigationItem.title = "アカウント"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19.0, weight: .medium)]
        
        //NavigationBarの色
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "ffa500")
        
        //一部NavigationBarがすりガラス？のような感じになるのでfalseで統一
        self.navigationController?.navigationBar.isTranslucent = false
        
        //NavigationBarの下線を消す
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        //ログイン後の'back'ボタンを削除
        self.navigationItem.hidesBackButton = true
    }
    
    // MARK: - TableView
    //セクションの数を決める
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitleArray.count
    }
    
    //セクションのヘッダーのタイトルを決める
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitleArray[section]
    }
    
    //セクションヘッダーの高さを決める
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    //セルの数を決める
    func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return settingSectionIconArray.count
        } else if section == 1 {
            return appSectionIconArray.count
        } else if section == 2 {
            return accountSectionIconArray.count
        } else{
            return 0
        }
    }
    
    //セルの高さを設定
    func tableView(_ table: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    //セルを構築
    func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //tableCellのIDでUITableViewCellのインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        if indexPath.section == 0 {
            
            //"設定"セクションのアイコン処理
            let settingSectionIcon = UIImage(named: settingSectionIconArray[indexPath.row])
            let settingIcon = cell.viewWithTag(1) as! UIImageView
                settingIcon.image = settingSectionIcon
            
            //設定セクションのラベル処理
            let settingLabel = cell.viewWithTag(2) as! UILabel
                settingLabel.text = settingCellLabelArray[indexPath.row]
                settingLabel.textColor = UIColor(hex: "333333")
            
        } else if indexPath.section == 1 {
            
            //"このアプリについて"セクションのアイコン処理
            let appSectionIcon = UIImage(named: appSectionIconArray[indexPath.row])
            let appIcon = cell.viewWithTag(1) as! UIImageView
                appIcon.image = appSectionIcon
            
            //"このアプリについて"セクションのラベル処理
            let appLabel = cell.viewWithTag(2) as! UILabel
                appLabel.text = appCellLabelArray[indexPath.row]
                appLabel.textColor = UIColor(hex: "333333")
            
        } else if indexPath.section == 2 {
            
            //"アカウント"セクションのアイコン処理
            let accountSectionIcon = UIImage(named: accountSectionIconArray[indexPath.row])
            let accountIcon = cell.viewWithTag(1) as! UIImageView
                accountIcon.image = accountSectionIcon
            
            //"アカウント"セクションのラベル処理
            let accountLabel = cell.viewWithTag(2) as! UILabel
                accountLabel.text = accountCellLabelArray[indexPath.row]
                accountLabel.textColor = UIColor.red
        }
        
        //セルを化粧
        cell.backgroundColor = UIColor.white
        
        //空のセルを削除
        table.tableFooterView = UIView(frame: .zero)
        
        //バージョンを表示するセルのタップを無効
        if appCellLabelArray[indexPath.row] == "HappyNews ver. 1.0" {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        }
        
        return cell
    }
    
    //セルをタップすると呼ばれる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //タップ時の選択色の常灯を消す
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        //セクション毎のタップアクションを分岐
        if indexPath.section == 0 {
            
            //"設定セクションの場合"
            switch indexPath.row {
            
            //通知機能
            case 0:
                print("通知設定")
            default:
                break
            }
            
        } else if indexPath.section == 1 {
            
            //"このアプリについて"セクションの場合
            switch indexPath.row {
            
            //レビュー機能
            case 0:
                //レビューを要求
                SKStoreReviewController.requestReview()
                
            //お問い合わせ機能
            case 1:
                //メールを送信できるかの確認
                if !MFMailComposeViewController.canSendMail() {
                    print("Mail services are not available")
                    return
                }
                
                //インスタンスの作成と委託
                let mailViewController = MFMailComposeViewController()
                    mailViewController.mailComposeDelegate = self
                
                //宛先の設定
                let toRecipients = ["nkeiisasa222@gmail.com"]
                
                //件名と宛先の表示
                mailViewController.setSubject("'HappyNews'へのご意見・ご要望")
                mailViewController.setToRecipients(toRecipients)
                mailViewController.setMessageBody("▼アプリの不具合などの連絡はこちら \n \n \n \n ▼機能追加依頼はこちら \n \n \n \n ▼その他ご要望はこちら", isHTML: false)
                
                self.present(mailViewController, animated: true, completion: nil)
                
            //Twitter紹介機能
            case 2:
                //TwitterのURLを定義して遷移
                let twitterURL = NSURL(string: "https://twitter.com/ken_sasaki2")
                if UIApplication.shared.canOpenURL(twitterURL! as URL) {
                    UIApplication.shared.open(twitterURL! as URL, options: [:], completionHandler: nil)
                }
            default:
                break
            }
            
        } else if indexPath.section == 2 {
            
            //"アカウント"セクションの場合
            switch indexPath.row {
            
            //ログアウト機能
            case 0:
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
                //サインアウトすると元の画面へ遷移
                self.navigationController?.popViewController(animated: true)
            default:
                break
            }
        }
    }
    
    //メール機能終了処理
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        //メールの結果で条件分岐
        switch result {
        case .cancelled:
            print("Email Send Cancelled")
            break
        case .saved:
            print("Email Saved as a Draft")
            break
        case .sent:
            print("Email Sent Successfully")
            break
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
