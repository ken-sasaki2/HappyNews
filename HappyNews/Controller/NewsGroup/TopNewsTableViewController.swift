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
    var currentElementName:String!
    
    //XMLファイルを保存するプロパティ
    var xmlString: String?
    
    //NewsItemsモデルのインスタンス作成
    var newsItems = [NewsItemsModel]()

    //LanguageTranslatorの認証キー
    var translatorApiKey  = "pLM8kVDHyCCa5t0IjajFd-rBmLB_jnmG3nl2mgdSsshM"
    var translatorVersion = "2018-05-01"
    var translatorURL     = "https://api.jp-tok.language-translator.watson.cloud.ibm.com"
    
    //ToneAnalyzerの認証キー
    var analysisApiKey  = "36bKQ1j2Aga5xtwTHJKFoGwbPfxLnDUk6M7Dt6qVEhmr"
    var analysisVersion = "2017-09-21"
    var analysisURL     = "https://api.jp-tok.tone-analyzer.watson.cloud.ibm.com"

    //分析用サンプルテキスト
    let sampleText = """
    【天皇賞・秋（日曜＝１１月１日、東京芝２０００メートル）新バージョンアップ作戦】偉業達成が続く秋のＧⅠシリーズ。第１６２回天皇賞・秋ではアーモンドアイによる芝ＧⅠ・８勝目に注目が集まるが、
    """
    
    //LanguageTranslationModelから渡ってくる値
    var translationArray = [Translation]()
    
    //ToneAnalyzerModelから渡ってくる値
    var analyzerArray  = [Analyzer]()
    
    //JSON解析で使用
    var count = 0
    var translationContent: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableaviewの背景
        tableView.backgroundColor = UIColor.white
        
        //XMLParseの処理
        //XMLファイルを特定
        xmlString = "https://news.yahoo.co.jp/pickup/rss.xml"
        
        //XMLファイルをURL型のurlに変換
        let url:URL = URL(string: xmlString!)!
        
        //parserにurlを代入
        parser = XMLParser(contentsOf: url)!
        
        //XMLParserを委任
        parser.delegate = self
        
        //parseの開始
        parser.parse()
        
        //翻訳機能開始
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
        return view.frame.size.height/8
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
                lastItem.title     = string
            case "link":
                lastItem.url       = string
            case "pubData":
                lastItem.pubDate   = string
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
    
    // MARK: - LanguageTranslator
    //LanguageTranslatorMode通信をおこなう
    func startTranslation() {
        
        //APILanguageTranslatorの認証コードをモデルへ渡す
        let languageTranslatorModel = LanguageTranslatorModel(translatorApiKey: translatorApiKey, translatorVersion: translatorVersion, translatorURL: translatorURL, sampleText: sampleText)
        
        //LanguageTranslatorModelの委託とJSON解析をset
        languageTranslatorModel.doneCatchTranslationProtocol = self
        languageTranslatorModel.setLanguageTranslator()
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
        let toneAnalyzerModel = ToneAnalyzerModel(analysisApiKey: analysisApiKey, analysisVersion: analysisVersion, analysisURL: analysisURL, analysisContent: translationContent!)
        
        //ToneAnalyzerModelの委託とJSON解析をset
        toneAnalyzerModel.doneCatchAnalyzerProtocol = self
        toneAnalyzerModel.setToneAnalyzer()
    }
    
    //渡ってきた値を処理
    func catchAnalyzer(arrayAnalyzerData: Array<Analyzer>, resultCount: Int) {
        
        analyzerArray = arrayAnalyzerData
    }
}
