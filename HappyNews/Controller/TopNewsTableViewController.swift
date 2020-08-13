//
//  TopNewsTableViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/08/13.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import SegementSlide

class TopNewsTableViewController: UITableViewController,SegementSlideContentScrollViewDelegate, XMLParserDelegate{
    
    //XMLParserのインスタンスを作成
    var parser = XMLParser()
    
    //RSSのパース内の現在の要素名を取得する変数
    var currentElementName:String!
    
    //NewsItems型のクラスが入る配列の宣言
    var newsItems = [NewsItems]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableaviewの背景
        tableView.backgroundColor = UIColor.lightGray
        
        //XMLParseの処理
        //XMLファイルを特定
        let yomiuriNews = "https://headlines.yahoo.co.jp/rss/ytv-dom.xml"
        
        //XMLファイルをURL型のurlに変換
        let url:URL = URL(string: yomiuriNews)!
        
        //parserにurlを代入
        parser = XMLParser(contentsOf: url)!
        
        //XMLParserを委任
        parser.delegate = self
        
        //parseの開始
        parser.parse()
    }

    // MARK: - Table view data source
    
    //tableViewを返すメソッド
    @objc var scrollView: UIScrollView {
        
        return tableView
    }

    //セルのセクションを決めるメソッド
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    //セルの数を決めるメソッド
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return newsItems.count
    }
    
    //セルの高さを決めるメソッド
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return view.frame.size.height/6
    }
    
    //セルを構築する際に呼ばれるメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //スタイルを2行にかつシンプリに
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell" )

        //RSS(yomiuriNews)の取得したニュースの値が入る
        let newsItem = newsItems[indexPath.row]
        
        //セルの背景
        cell.backgroundColor = UIColor.white
        
        //セルのテキスト
        cell.textLabel?.text = newsItem.title
        
        //セルのフォントタイプとサイズ
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        //セルのテキストカラー
        cell.textLabel?.textColor = UIColor.black
        
        //セルのテキストの行数
        cell.textLabel?.numberOfLines = 3
        
        //セルのサブタイトル
        cell.detailTextLabel?.text = newsItem.pubDate
        
        //サブタイトルのテキストカラー
        cell.detailTextLabel?.textColor = UIColor.gray

        return cell
    }
    
}
