//
//  CommentInputAccessoryView.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/14.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit

// MARK: - protocol
protocol CommentInputAccessoryViewProtocol {
    func tapedSendCommentButton(comment: String)
}

// コメント送信箇所のUIを構築
class CommentInputAccessoryView: UIView {
    
    // コメント送信ボタンのインスタンス
    @IBOutlet weak var sendCommentButton: UIButton!
    
    // コメント入力用テキストビューのインスタンス
    @IBOutlet weak var commentTextView: UITextView!
    
    // プロトコルのインスタンス
    var commentInputAccessoryViewProtocol: CommentInputAccessoryViewProtocol?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // viewに反映
        nibInit()
        setUpView()
        autoresizingMask = .flexibleHeight
    }
    
    // commentTextViewの設定
    private func setUpView() {
        
        // テキストビューの化粧
        commentTextView.layer.cornerRadius = 15
        commentTextView.layer.borderColor = UIColor.gray.cgColor
        commentTextView.layer.borderWidth = 1
        commentTextView.textColor = UIColor(hex: "333333")
        commentTextView.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        // 初期状態は空でタップできない
        commentTextView.text = ""
        sendCommentButton.isEnabled = false
        
        // 委託
        commentTextView.delegate = self
    }
    
    // 投稿ボタンをタップすると呼ばれる
    @IBAction func tapSendCommentButton(_ sender: Any) {
        
        print("commentTextView.text: \(commentTextView.text)")
        
        // テキストビューのテキストを渡す
        commentInputAccessoryViewProtocol?.tapedSendCommentButton(comment: commentTextView.text)
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


// MARK: - extension
// テキストビューを委託して使用可能に
extension CommentInputAccessoryView: UITextViewDelegate {
    
    // テキストビューの入力を監視
    func textViewDidChange(_ textView: UITextView) {
        
        // テキストビューのテキストが空だったらで分岐
        if textView.text.isEmpty {
            
            sendCommentButton.isEnabled = false
        } else {
            sendCommentButton.isEnabled = true
        }
    }
}
