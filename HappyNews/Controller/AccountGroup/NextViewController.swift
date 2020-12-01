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

class NextViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    let appCellLabelArray     : [String] = ["レビュー", "お問い合わせ", "開発者(Twitter)", "HappyNews ver. 1.0"]
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
            
        } else if indexPath.section == 1 {
            
            //"このアプリについて"セクションのアイコン処理
            let appSectionIcon = UIImage(named: appSectionIconArray[indexPath.row])
            let appIcon = cell.viewWithTag(1) as! UIImageView
                appIcon.image = appSectionIcon
            
            //"このアプリについて"セクションのラベル処理
            let appLabel = cell.viewWithTag(2) as! UILabel
                appLabel.text = appCellLabelArray[indexPath.row]
            
        } else if indexPath.section == 2 {
            
            //"アカウント"セクションのアイコン処理
            let accountSectionIcon = UIImage(named: accountSectionIconArray[indexPath.row])
            let accountIcon = cell.viewWithTag(1) as! UIImageView
                accountIcon.image = accountSectionIcon
            
            //"アカウント"セクションのラベル処理
            let accountLabel = cell.viewWithTag(2) as! UILabel
                accountLabel.text = accountCellLabelArray[indexPath.row]
        }
        
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

        //セルのテキストを取得して分岐
        //"設定セクションの場合"
        switch settingCellLabelArray[indexPath.row] {
        case "通知の設定":
            print("0番")
        default:
            print("No Response")
        }
        
        //"このアプリについて"セクションの場合
        switch appCellLabelArray[indexPath.row] {
        case "レビュー":
            print("レビューがタップされました")
        case "お問い合わせ":
            print("お問い合わせがタップされました")
        case "開発者(Twitter)":
            print("開発者(Twitter)がタップされました")
        default:
            print("No Response")
        }
        
        //"アカウント"セクションの場合
        switch accountCellLabelArray[indexPath.row] {
        case "ログアウト":
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            //サインアウトすると元の画面へ遷移
            self.navigationController?.popViewController(animated: true)
        default:
            print("No Response")
        }
    }
}
