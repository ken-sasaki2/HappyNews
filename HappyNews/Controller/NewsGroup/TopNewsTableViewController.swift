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
    var translatorApiKey  = "6C5IxuHFxAFA7ZPTY9QEHf6onkhoSvo-_4TMh-Tu-kJC"
    var translatorVersion = "2018-05-01"
    var translatorURL     = "https://api.jp-tok.language-translator.watson.cloud.ibm.com"
    
    //ToneAnalyzerの認証キー
    var analysisApiKey  = "0cPs9esGLbUGBqaHn5oGRI8BH8h86uP3-gnlKkUqD6_F"
    var analysisVersion = "2017-09-21"
    var analysisURL     = "https://api.jp-tok.tone-analyzer.watson.cloud.ibm.com"
    
    //LanguageTranslationModelから渡ってくる値
    var translationArray = [Translation]()
    
    //ToneAnalyzerModelから渡ってくる値
    var analyzerArray  = [Analyzer]()
    
    //JSON解析で使用
    var count = 0
    var translationContent: String?
    var analyzer          : String?
    var score             : Float?
    var name              : String?
    var tonesArray        : Any = []
    var joyArray          : Any = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableaviewの背景
        tableView.backgroundColor = UIColor.white
        
        //XMLParseの処理
        //XMLファイルを特定
        let xmlArray = "https://news.yahoo.co.jp/rss/media/sanspo/all.xml"
//
//        for i in 0...0 {
        
        let xmlString = xmlArray
        
        //XMLファイルをURL型のurlに変換
        let url:URL = URL(string: xmlString)!
        
        //parserにurlを代入
        parser = XMLParser(contentsOf: url)!
        
        //XMLParserを委任
        parser.delegate = self
        
        //parseの開始
        parser.parse()
//        }
        
        //翻訳の呼び出し
//        startTranslation()
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
    //LanguageTranslatorMode通信をおこなう
    func startTranslation() {
        
        //XMLの要素を配列に保管
        let textArray = [newsItems[newsItems.count - 1].description,
                         newsItems[newsItems.count - 2].description,
                         newsItems[newsItems.count - 3].description,
                         newsItems[newsItems.count - 4].description,
                         newsItems[newsItems.count - 5].description,
                         newsItems[newsItems.count - 6].description,
                         newsItems[newsItems.count - 7].description,
                         newsItems[newsItems.count - 8].description,
                         newsItems[newsItems.count - 9].description,
                         newsItems[newsItems.count - 10].description,
                         newsItems[newsItems.count - 11].description,
                         newsItems[newsItems.count - 12].description,
                         newsItems[newsItems.count - 13].description,
                         newsItems[newsItems.count - 14].description,
                         newsItems[newsItems.count - 15].description,
                         newsItems[newsItems.count - 16].description,
                         newsItems[newsItems.count - 17].description,
                         newsItems[newsItems.count - 18].description,
                         newsItems[newsItems.count - 19].description,
                         newsItems[newsItems.count - 20].description,
                         newsItems[newsItems.count - 21].description,
                         newsItems[newsItems.count - 22].description,
                         newsItems[newsItems.count - 23].description,
                         newsItems[newsItems.count - 24].description,
                         newsItems[newsItems.count - 25].description,
                         newsItems[newsItems.count - 26].description,
                         newsItems[newsItems.count - 27].description,
                         newsItems[newsItems.count - 28].description,
                         newsItems[newsItems.count - 29].description,
                         newsItems[newsItems.count - 30].description,
                         newsItems[newsItems.count - 31].description,
                         newsItems[newsItems.count - 32].description,
                         newsItems[newsItems.count - 33].description,
                         newsItems[newsItems.count - 34].description,
                         newsItems[newsItems.count - 35].description,
                         newsItems[newsItems.count - 36].description,
                         newsItems[newsItems.count - 37].description,
                         newsItems[newsItems.count - 38].description,
                         newsItems[newsItems.count - 39].description,
                         newsItems[newsItems.count - 40].description,
                         newsItems[newsItems.count - 41].description,
                         newsItems[newsItems.count - 42].description,
                         newsItems[newsItems.count - 43].description,
                         newsItems[newsItems.count - 44].description,
                         newsItems[newsItems.count - 45].description,
                         newsItems[newsItems.count - 46].description,
                         newsItems[newsItems.count - 47].description,
                         newsItems[newsItems.count - 48].description,
                         newsItems[newsItems.count - 49].description,
                         newsItems[newsItems.count - 50].description
                        ]
        
        //textArrayの中身を順にLanguageTranslatorModelへ通信
        for i in 0...49 {
            let translationText = textArray[i]
            
            //APILanguageTranslatorの認証コードをモデルへ渡す
            let languageTranslatorModel = LanguageTranslatorModel(translatorApiKey: translatorApiKey, translatorVersion: translatorVersion, translatorURL: translatorURL, translationText: translationText!)
            
            //LanguageTranslatorModelの委託とJSON解析をset
            languageTranslatorModel.doneCatchTranslationProtocol = self
            languageTranslatorModel.setLanguageTranslator()
        }
    }
    
    //渡ってきた値を処理
    func catchTranslation(arrayTranslationData: Array<Translation>, resultCount: Int) {
        
        translationArray = arrayTranslationData
        
        //渡ってきた値をJSONに変換
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let jsonValue = try? encoder.encode(translationArray) else {
            fatalError("Failed to encode to JSON.")
        }
        
        //JSON解析(jsonValue)
        let json = JSON(jsonValue)
        translationContent = json[self.count]["translation"].string
        
        //startToneAnalyzerの呼び出し
        startToneAnalyzer()
    }
    
    // MARK: - ToneAnalyzer
    //ToneAnalyzerModelと通信をおこなう
    func startToneAnalyzer() {
        
        //APIToneAnalyzerの認証コードをモデルへ渡す
        let toneAnalyzerModel = ToneAnalyzerModel(analysisApiKey: analysisApiKey, analysisVersion: analysisVersion, analysisURL: analysisURL, translationContent: translationContent!)
        
        //ToneAnalyzerModelの委託とJSON解析をset
        toneAnalyzerModel.doneCatchAnalyzerProtocol = self
        toneAnalyzerModel.setToneAnalyzer()
    }
    
    //渡ってきた値を処理
    func catchAnalyzer(arrayAnalyzerData: Array<Analyzer>, resultCount: Int) {
        
        analyzerArray = arrayAnalyzerData
        
        //渡ってきた値をJSONに変換
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let tones = try? encoder.encode(analyzerArray) else {
            fatalError("Failed to encode to JSON.")
        }
        
        //JSON解析(jsonValue)
        let json = JSON(tones)
        print("sasasa: \(json)")
//        score = json[self.count]["firstScore"].float
//        name  = json[self.count]["firstToneName"].string
        
//        tonesArray = [score, name] as [Any]
//        print("kenken: \(tonesArray)")
    }
    
    //セルを構築する際に呼ばれるメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
            //スタイルを2行にかつシンプルに
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell" )

            //RSSで取得したニュースの値が入る
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
