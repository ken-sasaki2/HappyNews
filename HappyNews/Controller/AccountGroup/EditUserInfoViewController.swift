//
//  EditUserInfoViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/07.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit
import Kingfisher
import PKHUD

// アカウント情報を編集するクラス
class EditUserInfoViewController: UIViewController {
    
    
    // MARK: - Property
    // アカウント情報編集用のインスタンス
    @IBOutlet weak var editUserImage: UIImageView!
    
    // ユーザー名編集用TextFireldのインスタンス
    @IBOutlet weak var editUserNameTextField: UITextField!
    
    // アカウント情報更新用ボタンのインスタンス
    @IBOutlet weak var editUpdateButton: UIButton!
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TextFireldのデフォルト値
        editUserNameTextField.text = UserDefault.getUserName
        
        // アカウント画像のデフォルト値
        editUserImage.kf.setImage(with: URL(string: UserDefault.imageCapture!))
        
        // アカウント画像の角丸
        editUserImage.layer.masksToBounds = false
        editUserImage.layer.cornerRadius = editUserImage.frame.width/2
        editUserImage.clipsToBounds = true
        
        // 登録ボタンの角丸
        editUpdateButton.layer.cornerRadius = 6.0
        
        // Navigationbarの呼び出し
        setEditPageNavigationBar()
    }
    
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ユーザー情報編集ページではTabBarを非表示するように設定
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    // MARK: - Navigation
    // ニュースページのNavigationBarを設定
    func setEditPageNavigationBar() {
        
        // NavigationBarのタイトルとその色とフォント
        navigationItem.title = "アカウント情報編集"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19.0, weight: .semibold)]
        
        // NavigationBarの色
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "00AECC")
        
        // 一部NavigationBarがすりガラス？のような感じになるのでfalseで統一
        self.navigationController?.navigationBar.isTranslucent = false
        
        // NavigationBarの下線を削除
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    
    // MARK: - TapEditUpdateButton
    // 更新ボタンをタップすると呼ばれる
    @IBAction func tapEditUpdateButton(_ sender: Any) {
        
        // ユーザーに制約を知らせるアラートの設定
        let updateAlert = UIAlertController(title: "確認", message: "アカウント情報を変更しますか？", preferredStyle: .alert)
        
        // アラートのボタン
        updateAlert.addAction(UIAlertAction(title: "はい", style: .default, handler: {
            action in
            
            // ユーザー名の保存
            UserDefault.standard.set(self.editUserNameTextField.text, forKey: "userName")
            
            
            
            HUD.flash(.labeledSuccess(title: "変更完了", subtitle: nil), onView: self.view, delay: 0) { _ in
                
                // アカウントページへ遷移(戻る)
                self.navigationController?.popViewController(animated: true)
            }
        }))
        updateAlert.addAction(UIAlertAction(title: "いいえ", style: .destructive))
        
        // アラートの表示
        present(updateAlert, animated: true, completion: nil)
        
    }
}
