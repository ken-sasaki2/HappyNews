//
//  CommentInputAccessoryView.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/14.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit

// ▼関係するclass
// TimeLineCommentViewController

// MARK: - protocol
protocol CommentInputAccessoryViewProtocol {
    func tapedSendCommentButton(comment: String, sendTime: Date)
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
        
        // delegateを委託
        commentTextView.delegate = self
    }
    
    // 投稿ボタンをタップすると呼ばれる
    @IBAction func tapSendCommentButton(_ sender: Any) {
        
        // 投稿ボタンタップ時刻の取得（タップ時の現在時刻を取得したいのでDateTimesは使わない）
        let now = Date()
        
        // 地域とフォーマットを指定
        DateItems.dateFormatter.locale = Locale(identifier: "ja_JP")
        DateItems.dateFormatter .dateFormat = "yyyy年M月d日(EEEEE) H時m分s秒"
        
        // 一度String型に変換してDate型に変換
        let sendTimeString = DateItems.dateFormatter.string(from: now)
        let sendTime       = DateItems.dateFormatter.date(from: sendTimeString)
        
        // テキストビューのテキストを渡す
        commentInputAccessoryViewProtocol?.tapedSendCommentButton(comment: commentTextView.text, sendTime: sendTime!)
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
