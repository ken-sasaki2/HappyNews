//
//  TopNewsTableViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/08/13.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import SegementSlide

class WorldNewsTableViewController: UITableViewController,SegementSlideContentScrollViewDelegate, XMLParserDelegate{
    
    //XMLParserのインスタンスを作成
    var parser = XMLParser()
    
    //RSSのパース内の現在の要素名を取得する変数
    var currentElementName:String!
    
    //NewsItems型のクラスが入る配列の宣言
    var newsItems = [NewsItems]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableaviewの背景
        tableView.backgroundColor = UIColor.white
        
        //XMLParseの処理
        //XMLファイルを特定
        let xmlString = "https://headlines.yahoo.co.jp/rss/abema-c_int.xml"
        
        //XMLファイルをURL型のurlに変換
        let url:URL = URL(string: xmlString)!
        
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
        
        return view.frame.size.height/8
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
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        
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
    
    //XML解析を開始する場合(parser.parse())に呼ばれるメソッド
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElementName = nil
        
        if elementName == "item" {
            
            newsItems.append(NewsItems())
        } else {
            
            currentElementName = elementName
        }
    }
    
    //"item"の中身を判定するメソッド(要素の解析開始と値取得）
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if newsItems.count > 0 {
            
            //配列の番号を合わせる
            let lastItem = newsItems[newsItems.count - 1]
            
            switch currentElementName {
            case "title":
                lastItem.title   = string
            case "link":
                lastItem.url     = string
            case "pubData":
                lastItem.pubDate = string
            default:
                break
            }
        }
    }
    
    //RSS内のXMLファイルの各値の</item>に呼ばれるメソッド（要素の解析終了）
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        //新しい箱を準備
        self.currentElementName = nil
    }
    
    //XML解析が終わったら呼ばれるメソッド
    func parserDidEndDocument(_ parser: XMLParser) {
        
        //tableViewの更新
        tableView.reloadData()
    }
    
    //XML解析でエラーが発生した場合に呼ばれるメソッド
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("エラー:" + parseError.localizedDescription)
    }
    
    //セルをタップした時呼ばれるメソッド
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //WebViewControllerのインスタンス作成
        let webViewController = WebViewController()
        
        //モーダルで画面遷移
        webViewController.modalTransitionStyle = .coverVertical
        
        //タップしたセルを検知
        let tapCell = newsItems[indexPath.row]
        
        //検知したセルのurlを取得
        UserDefaults.standard.set(tapCell.url, forKey: "url")
        
        //webViewControllerで取り出す
        present(webViewController, animated: true, completion: nil)
    }
    
}


