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
    
    //セルのテキストとアイコンの配列
    let accountCellArray: [String] = ["通知の設定", "レビュー", "お問い合わせ", "開発者(Twitter)", "ログアウト",
                                      "HappyNews ver. 1.0"]
    let menuIconArray   : [String] = ["nofitication", "review", "mail", "twitter", "logout", "version"]

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
    //セルの数を決める
    func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountCellArray.count
    }
    
    //セルの高さを設定
    func tableView(_ table: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    //セルを構築
    func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
        //tableCellのIDでUITableViewCellのインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        //セルを化粧
        cell.backgroundColor = UIColor(hex: "ffffff")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        cell.textLabel?.textColor = UIColor(hex: "333333")
        cell.textLabel?.numberOfLines = 1
        
        //空のセルを削除
        table.tableFooterView = UIView(frame: .zero)
        
        //iconとして配列の要素を取り出す
        let icon = UIImage(named: menuIconArray[indexPath.row])
        
        //tag番号1でUIImageViewを指定してiconを反映
        let menuIcon = cell.viewWithTag(1) as! UIImageView
        menuIcon.image = icon
        
        //tag番号2でセルのテキストを設定してviewに反映
        let menuLabel = cell.viewWithTag(2) as! UILabel
            menuLabel.text = accountCellArray[indexPath.row]
        
        //バージョンを表示するセルのタップを無効
        if accountCellArray[indexPath.row] == "HappyNews ver. 1.0" {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        }
        
        return cell
    }
    
    //セルをタップすると呼ばれる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //セルのテキストを取得して分岐
        switch accountCellArray[indexPath.row] {
        case "通知の設定":
            print("0番")
        case "レビュー":
            print("1番")
        case "お問い合わせ":
            print("2番")
        case "開発者(Twitter)":
            print("3番")
        case "ログアウト":
            //ここでログアウト
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            //サインアウトすると元の画面へ遷移
            self.navigationController?.popViewController(animated: true)
        default:
            print("No response")
        }
    }
}
