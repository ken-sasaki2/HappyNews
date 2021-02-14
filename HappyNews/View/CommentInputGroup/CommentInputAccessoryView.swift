//
//  CommentInputAccessoryView.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/14.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit

// コメント送信箇所のUIを構築
class CommentInputAccessoryView: UIView {
    
    // コメント送信ボタンのインスタンス
    @IBOutlet weak var sendCommentButton: UIButton!
    
    // コメント入力用テキストビューのインスタンス
    @IBOutlet weak var commentTextView: UITextView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // viewに反映
        nibInit()
        setUpView()
        autoresizingMask = .flexibleHeight
    }
    
    // コメント送信箇所の化粧
    private func setUpView() {
        
        // テキストビューの化粧
        commentTextView.layer.cornerRadius = 15
        commentTextView.layer.borderColor = UIColor.gray.cgColor
        commentTextView.layer.borderWidth = 1
        
        // 送信ボタンの化粧
        sendCommentButton.layer.cornerRadius = 6
        sendCommentButton.imageView!.contentMode = .scaleAspectFill
        sendCommentButton.contentHorizontalAlignment = .fill
        sendCommentButton.contentVerticalAlignment = .fill
        sendCommentButton.isEnabled = false
        
        sendCommentButton.layer.cornerRadius = 6
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    // xibファイルをｖiewにセットする
    private func nibInit() {
        
        let nib = UINib(nibName: "CommentInputAccessoryView", bundle: nil)
        
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        // サイズを指定して反映
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
