//
//  ChatMessageCell.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/04.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit

// カスタムセルを扱うクラス
class ChatMessageCell: UITableViewCell {
    
    
    // MARK: - Property
    // ユーザー名のインスタンス
    @IBOutlet weak var userName: UILabel!
    
    // チャットメッセージのインスタンス
    @IBOutlet weak var messageLabel: UILabel!
    
    // セルの背景のインスタンス
    @IBOutlet weak var backView: UIView!
    

    // MARK: - awakeFromNib
    // ロードされた時に呼ばれる
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 投稿内容のセルの角丸
        backView.layer.cornerRadius = 6.0
        
    }

    
    // MARK: - setSelected
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
