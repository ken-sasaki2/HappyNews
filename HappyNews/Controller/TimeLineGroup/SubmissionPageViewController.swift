//
//  SubmissionPageViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/08.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit

// タイムラインへの投稿と感情分析とFirestoreとのやりとりをおこなう
class SubmissionPageViewController: UIViewController {
    
    
    // MARK: - Property
    @IBOutlet weak var sendMessageButton: UIButton!
    
    

    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // 投稿ボタンの角丸
        sendMessageButton.layer.cornerRadius = 6
    }
    
    // MARK: - TapCancelButton
    // ×ボタンをタップすると呼ばれる
    @IBAction func tapCancelButton(_ sender: Any) {
        print("投稿をキャンセル")
        
        // 投稿画面を閉じる
        dismiss(animated: true, completion: nil)
    }
    
    
    // 投稿ボタンをタップすると呼ばれる
    // MARK: - TapSendMessage
    @IBAction func tapsendMessageButton(_ sender: Any) {
        print("投稿")
        
        // 感情分析モデルと通信
        
        // Joyかどうかで分岐
        
        // JoyならFirestoreへ保存して内容を反映
    }
}
