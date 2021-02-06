//
//  SaveUserInformationViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/05.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit

// ユーザー情報(ユーザー名 & アカウント画像)を保存する
class SaveUserInformationViewController: UIViewController {

    
    // MARK: - Property
    // アカウント画像のインスタンス
    @IBOutlet weak var userImage: UIImageView!
    
    // ユーザー名入力Fieldのインスタンス
    @IBOutlet weak var userName: UITextField!
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    // MARK: - TapSaveButton
    // 保存ボタンをタップすると呼ばれる
    @IBAction func tapSaveButton(_ sender: Any) {
        print("保存をタップ")
    }
}
