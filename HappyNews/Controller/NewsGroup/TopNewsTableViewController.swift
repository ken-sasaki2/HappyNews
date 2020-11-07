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
    var languageTranslatorApiKey  = "iVzXO8cqVz1thlC0oh8oja_0fyLSfge9OOLGMBXC2OSA"
    var languageTranslatorVersion = "2018-05-01"
    var languageTranslatorURL     = "https://api.jp-tok.language-translator.watson.cloud.ibm.com"
    
    //ToneAnalyzerの認証キー
    var toneAnalyzerApiKey  = "Ko0MJXr7im33kpia3B_-7eiAtc2dL2lZVnWzbDoiJLFF"
    var toneAnalyzerVersion = "2017-09-21"
    var toneAnalyzerURL     = "https://api.jp-tok.tone-analyzer.watson.cloud.ibm.com"
    
    //LanguageTranslationModelから渡ってくる値
    var translationArray = [Translation]()
    
    //ToneAnalyzerModelから渡ってくる値
    var analyzerArray  = [Analyzer]()
    
    //JSON解析で使用
    var count = 0
    var toneAnalyzerText: String?

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
        let newsTextArray = [newsItems[newsItems.count - 1].description,
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
                             newsItems[newsItems.count - 14].description
                            ]
        
        //newsTextArrayの要素とAPILanguageTranslatorの認証コードで通信
        for i in 0...13 {
            
            let newsText = newsTextArray[i]
            
            let languageTranslatorModel = LanguageTranslatorModel(languageTranslatorApiKey: languageTranslatorApiKey, languageTranslatorVersion: languageTranslatorVersion,  languageTranslatorURL: languageTranslatorURL, newsText: newsText!)
            
            //LanguageTranslatorModelの委託とJSON解析をセット
            languageTranslatorModel.doneCatchTranslationProtocol = self
            languageTranslatorModel.setLanguageTranslator()
        }
    }
    
    //LanguageTranslatorModelから返ってきた値を処理
    func catchTranslation(arrayTranslationData: Array<Translation>, resultCount: Int) {
        
        translationArray = arrayTranslationData
        
        //返ってきた値をJSONに整形
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let jsonArray = try? encoder.encode(translationArray) else {
            fatalError("Failed to encode to JSON.")
        }
        
        //SwiftyJSONのJSON型に変換
        let jsonValue = JSON(jsonArray)
        
        //toneAnalysisText = 翻訳結果
        toneAnalyzerText = jsonValue[self.count]["translation"].string
        
        //startToneAnalyzerの呼び出し
        startToneAnalyzer()
    }
    
    // MARK: - ToneAnalyzer
    func startToneAnalyzer() {
        
        //toneAnalyzerTextとAPIToneAnalyzerの認証コードで通信
        let toneAnalyzerModel = ToneAnalyzerModel(toneAnalyzerApiKey: toneAnalyzerApiKey, toneAnalyzerVersion: toneAnalyzerVersion, toneAnalyzerURL: toneAnalyzerURL, toneAnalyzerText: toneAnalyzerText!)
        
        //ToneAnalyzerModelの委託とJSON解析をセット
        toneAnalyzerModel.doneCatchAnalyzerProtocol = self
        toneAnalyzerModel.setToneAnalyzer()
    }
    
    //返ってきた値を処理
    func catchAnalyzer(arrayAnalyzerData: Array<Analyzer>, resultCount: Int) {
        
        analyzerArray = arrayAnalyzerData
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
