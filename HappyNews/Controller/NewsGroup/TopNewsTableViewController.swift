//
//  TopNewsTableViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/08/13.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import SegementSlide
import ToneAnalyzer
import LanguageTranslator
import SwiftyJSON

class TopNewsTableViewController: UITableViewController,SegementSlideContentScrollViewDelegate, XMLParserDelegate, DoneCatchTranslationProtocol, DoneCatchAnalyzerProtocol {
    
    //XMLParserのインスタンスを作成
    var parser = XMLParser()
    
    //RSSのパース内の現在の要素名を取得する変数
    var currentElementName: String?
    
    //XMLファイルを保存するプロパティ
    var xmlString: String?
    
    //NewsItemsモデルのインスタンス作成
    var newsItems = [NewsItemsModel]()

    //LanguageTranslatorの認証キー
    var languageTranslatorApiKey  = "4cVyLBvPe85CWqge5F99RdCR2GHoIwLjzAQW7eNYtmyt"
    var languageTranslatorVersion = "2018-05-01"
    var languageTranslatorURL     = "https://api.jp-tok.language-translator.watson.cloud.ibm.com"
    
    //ToneAnalyzerの認証キー
    var toneAnalyzerApiKey  = "OjvQ7LPUlMtgqbjjAosaeuvWA0UbHbruHX4M00Bf6Ofa"
    var toneAnalyzerVersion = "2017-09-21"
    var toneAnalyzerURL     = "https://api.jp-tok.tone-analyzer.watson.cloud.ibm.com"
    
    //LanguageTranslationModelから渡ってくる値
    var translationArray      = [String]()
    var translationArrayCount = Int()
    
    //ToneAnalyzerModelから渡ってくる値
    var joyCountArray          = [Any]()
    var arrayAnalyzerDataCount = Int()
    
    //JSON解析で使用
    var count = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableaviewの背景
        tableView.backgroundColor = UIColor.white
        
        //XMLParseの処理
        //XMLファイルを特定
        let xmlArray = "https://news.yahoo.co.jp/rss/media/entame/all.xml"
        
        //for i in 0...1 {
        
        let xmlString = xmlArray
        
        //XMLファイルをURL型のurlに変換
        let url:URL = URL(string: xmlString)!
        
        //parserにurlを代入
        parser = XMLParser(contentsOf: url)!
        
        //XMLParserを委任
        parser.delegate = self
        
        //parseの開始
        parser.parse()
        //}
        
        //LanguageTranslatorの呼び出し
        startTranslation()
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
        return view.frame.size.height/7
    }
    
    //XML解析を開始する場合(parser.parse())に呼ばれるメソッド
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElementName = nil
        
        if elementName == "item" {
            newsItems.append(NewsItemsModel())
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
                lastItem.title       = string
            case "link":
                lastItem.url         = string
            case "pubDate":
                lastItem.pubDate     = string
            case "description":
                lastItem.description = string
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
        print("error:" + parseError.localizedDescription)
    }
    
    // MARK: - LanguageTranslator
    func startTranslation() {
        
        //XMLのdescriptionを配列に保管
        let newsTextArray = [newsItems[newsItems.count - 1].title,
                             newsItems[newsItems.count - 2].title,
                             newsItems[newsItems.count - 3].title,
                             newsItems[newsItems.count - 4].title,
                             newsItems[newsItems.count - 5].title,
                             newsItems[newsItems.count - 6].title,
                             newsItems[newsItems.count - 7].title,
                             newsItems[newsItems.count - 8].title,
                             newsItems[newsItems.count - 9].title,
                             newsItems[newsItems.count - 10].title,
                             newsItems[newsItems.count - 11].title,
                             newsItems[newsItems.count - 12].title,
                             newsItems[newsItems.count - 13].title,
                             newsItems[newsItems.count - 14].title,
                             newsItems[newsItems.count - 15].title,
                             newsItems[newsItems.count - 16].title,
                             newsItems[newsItems.count - 17].title,
                             newsItems[newsItems.count - 18].title,
                             newsItems[newsItems.count - 19].title,
                             newsItems[newsItems.count - 20].title,
                             newsItems[newsItems.count - 21].title,
                             newsItems[newsItems.count - 22].title,
                             newsItems[newsItems.count - 23].title,
                             newsItems[newsItems.count - 24].title,
                             newsItems[newsItems.count - 25].title,
                             newsItems[newsItems.count - 26].title,
                             newsItems[newsItems.count - 27].title,
                             newsItems[newsItems.count - 28].title,
                             newsItems[newsItems.count - 29].title,
                             newsItems[newsItems.count - 30].title,
                             newsItems[newsItems.count - 31].title,
                             newsItems[newsItems.count - 32].title,
                             newsItems[newsItems.count - 33].title,
                             newsItems[newsItems.count - 34].title,
                             newsItems[newsItems.count - 35].title,
                             newsItems[newsItems.count - 36].title,
                             newsItems[newsItems.count - 37].title,
                             newsItems[newsItems.count - 38].title,
                             newsItems[newsItems.count - 39].title,
                             newsItems[newsItems.count - 40].title,
                             newsItems[newsItems.count - 41].title,
                             newsItems[newsItems.count - 42].title,
                             newsItems[newsItems.count - 43].title,
                             newsItems[newsItems.count - 44].title,
                             newsItems[newsItems.count - 45].title,
                             newsItems[newsItems.count - 46].title,
                             newsItems[newsItems.count - 47].title,
                             newsItems[newsItems.count - 48].title,
                             newsItems[newsItems.count - 49].title,
                             newsItems[newsItems.count - 50].title
                            ]
            
        //LanguageTranslatorModelへ通信
        let languageTranslatorModel = LanguageTranslatorModel(languageTranslatorApiKey: languageTranslatorApiKey, languageTranslatorVersion: languageTranslatorVersion,  languageTranslatorURL: languageTranslatorURL, newsTextArray: newsTextArray)
            
            //LanguageTranslatorModelの委託とJSON解析をセット
            languageTranslatorModel.doneCatchTranslationProtocol = self
            languageTranslatorModel.setLanguageTranslator()
    }
    
    //LanguageTranslatorModelから返ってきた値の受け取り
    func catchTranslation(arrayTranslationData: Array<String>, resultCount: Int) {
        
        translationArray      = arrayTranslationData
        translationArrayCount = resultCount
        
        //print(translationArray)
        
        //配列内の要素を確認するとToneAnalyzerを呼び出す
        if translationArray != nil {
            
            //ToneAnalyzerの呼び出し
            startToneAnalyzer()
        } else {
            print("Failed because the value is nil.")
        }
    }
    
    // MARK: - ToneAnalyzer
    func startToneAnalyzer() {
        
        //translationArrayとAPIToneAnalyzerの認証コードで通信
        let toneAnalyzerModel = ToneAnalyzerModel(toneAnalyzerApiKey: toneAnalyzerApiKey, toneAnalyzerVersion: toneAnalyzerVersion, toneAnalyzerURL: toneAnalyzerURL, translationArray: translationArray)
        
        //ToneAnalyzerModelの委託とJSON解析をセット
        toneAnalyzerModel.doneCatchAnalyzerProtocol = self
        toneAnalyzerModel.setToneAnalyzer()
    }
    
    //ToneAnalyzerModelから返ってきた値の受け取り
    func catchAnalyzer(arrayAnalyzerData: Array<Any>) {
        
        joyCountArray = arrayAnalyzerData
        
        print("joyCountArray.count: \(joyCountArray.count)")
        print("joyCountArray: \(joyCountArray.debugDescription)")
    }
    
    //セルを構築する際に呼ばれるメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //RSSで取得したニュースの値が入る
        let newsItem = newsItems[indexPath.row]
        
        //セルのスタイルを設定
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell" )
            
        //セルを化粧
        cell.backgroundColor = UIColor.white
        cell.textLabel?.text = newsItem.title
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.numberOfLines = 3
            
        //セルのサブタイトル
        cell.detailTextLabel?.text = newsItem.pubDate
        cell.detailTextLabel?.textColor = UIColor.gray

        return cell
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
