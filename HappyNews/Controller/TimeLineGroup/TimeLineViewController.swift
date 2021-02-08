//
//  TimeLineViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/08.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit

class TimeLineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: - Property
    // テーブルビューのインスタンス
    @IBOutlet weak var timeLineTable: UITableView!
    
    
    var item = [
            ["content": "2020年\nが\n終わります。\n今年も\n良い\n一年\nでした。", "date": Date().timeIntervalSince1970 - 313123123, "name": "斎藤"],
            ["content": "良いお年をお過ごしください。", "date": Date().timeIntervalSince1970 - 123212312, "name": "本田"],
            ["content": "新年明けましておめでとうございます。", "date": Date().timeIntervalSince1970 - 20000000, "name": "鈴木"],
            ["content": "お年玉を1万円あげます。", "date": Date().timeIntervalSince1970 - 2323232, "name": "川崎"],
            ["content": "2021年はもっと勉強を頑張ります。", "date": Date().timeIntervalSince1970 - 13213, "name": "三菱"],
            ["content": "今年は本厄なので気を引き締めます。", "date": Date().timeIntervalSince1970 - 3333, "name": "豊田"],
            ["content": "今年もよろしくお願いします。", "date": Date().timeIntervalSince1970 - 10, "name": "武田"]
        ]
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // delegateを委託
        timeLineTable.delegate   = self
        timeLineTable.dataSource = self
        
        // カスタムセルの登録
        timeLineTable.register(UINib(nibName: "TimeLineTableViewCell", bundle: nil), forCellReuseIdentifier: "timeLineCustomCell")
        
        // カスタムセルの高さの初期値を設定し、セルごとに可変するセルを作成
        timeLineTable.estimatedRowHeight = 95
        timeLineTable.rowHeight = UITableView.automaticDimension
        
        // 最新投稿内容をTopに変更
        item = item.reversed()
        
        // NavigationBarの呼び出し
        setTimeLineNavigationBar()
        
        // 投稿ボタンの呼び出し
        goSubmissionPage()
    }
    
    
    // MARK: - Navigation
    // タイムラインページのNavigationBarを設定
    func setTimeLineNavigationBar() {
        
        // NavigationBarのタイトルとその色とフォント
        navigationItem.title = "タイムライン"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19.0, weight: .semibold)]
        
        // NavigationBarの色
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "00AECC")
        
        // 一部NavigationBarがすりガラス？のような感じになるのでfalseで統一
        self.navigationController?.navigationBar.isTranslucent = false
        
        // NavigationBarの下線を削除
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    // スクロールでナビゲーションバーを隠す
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    
    // MARK: - TableView
    // セクションの数を設定
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // セルの数を決める
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return item.count
    }
    
    // セルを構築
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // カスタムセルのIDでTimeLineTableViewCellのインスタンスを生成
        let cell = timeLineTable.dequeueReusableCell(withIdentifier: "timeLineCustomCell", for: indexPath) as! TimeLineTableViewCell
        
        // 現在時刻の取得
        let now = DateItems.date.timeIntervalSince1970
        
        let past = item[indexPath.row]["date"] as! TimeInterval
        
        cell.sendTime.text   = DateItems.timeCheck(now: now, past: past)
        cell.sendBody.text   = (item[indexPath.row]["content"] as! String)
        cell.senderName.text = (item[indexPath.row]["name"] as! String)
        
        // セルとTableViewの背景色の設定
        cell.backgroundColor          = UIColor(hex: "f4f8fa")
        timeLineTable.backgroundColor = UIColor(hex: "f4f8fa")
        
        // 空のセルを削除
        timeLineTable.tableFooterView = UIView(frame: .zero)
        
        // セルのタップを無効
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    // セルをタップすると呼ばれる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // タップ時の選択色の常灯を消す
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    
    // MARK: - SendMessageButton
    // 投稿ページへ遷移するボタン
    func goSubmissionPage() {
        
        // 投稿ボタンのインスタンス
        let sendButton = UIButton()
        
        // 'Autosizing'を'AutoLayout'に変換
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        // ボタンを化粧
        sendButton.tintColor = .white
        sendButton.backgroundColor = UIColor(hex: "00AECC")
        sendButton.layer.cornerRadius = 25
        sendButton.setImage(UIImage(systemName: "plus"), for: .normal)
        
        // ボタンがタップされた時の挙動を記述してviewに反映
        sendButton.addTarget(self, action: #selector(tapSubmissionButton), for: .touchUpInside)
        self.view.addSubview(sendButton)

        // 以下、制約
        // sendButtonの下端をViewの下端から上に95pt
        sendButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -95).isActive = true
        
        // sendButtonの右端をViewの右端から左に15pt
        sendButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15).isActive = true
        
        // sendButtonの幅を50にする
        sendButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // sendButtonの高さを50にする
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    // 投稿ボタンをタップすると呼ばれる
    @objc func tapSubmissionButton() {
        
        // 投稿ページへ遷移
        self.performSegue(withIdentifier: "goSubmissionPage", sender: nil)
    }
}
