//
//  TimeLineTableViewCell.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/08.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit

// カスタムセルを扱うクラス
class TimeLineTableViewCell: UITableViewCell {

    // MARK: - Property
    // タイムラインアイコンのインスタンス
    @IBOutlet weak var sendImageView: UIImageView!
    
    // タイムラインユーザー名のインスタンス
    @IBOutlet weak var senderName: UILabel!
    
    // タイムライン投稿内容のインスタンス
    @IBOutlet weak var sendBody: UILabel!
    
    // タイムライン投稿時間のインスタンス
    @IBOutlet weak var sendTime: UILabel!
    
    // 「いいね」ラベルのインスタンス
    // 「いいね」件数ラベルのインスタンス
    // 「いいね」ボタンのインスタンス
    
    // ロード直後に呼ばれる
    override func awakeFromNib() {
        super.awakeFromNib()
    
        // アイコンの角丸
        sendImageView.layer.cornerRadius = 22
    }

    // 選択状態と通常状態の状態アニメーション処理の処理
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // いいねが押されたら呼ばれる
    
    @IBAction func tapLikeButton(_ sender: Any) {
        print("「いいね」")
    }
    
}
