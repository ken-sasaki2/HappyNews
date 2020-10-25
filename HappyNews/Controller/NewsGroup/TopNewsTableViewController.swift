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

class TopNewsTableViewController: UITableViewController,SegementSlideContentScrollViewDelegate, XMLParserDelegate, DoneCatchTranslationProtocol{

    //XMLParserのインスタンスを作成
    var parser = XMLParser()
    
    //RSSのパース内の現在の要素名を取得する変数
    var currentElementName:String!
    
    //NewsItemsモデルのインスタンス作成
    var newsItems = [NewsItems]()
    
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
    Team, I know that times are tough! Product sales have been disappointing for the past three quarters. We have a competitive product, but we need to do a better job of selling it!
    """
    
    //JSON解析で使用
    var count = 0
    
    //LanguageTranslationModelから渡ってくる値
    var translationArray = [Translation]()
    var translation      = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableaviewの背景
        tableView.backgroundColor = UIColor.white
        
        //XMLParseの処理
        //XMLファイルを特定
        let xmlString = "https://news.yahoo.co.jp/pickup/rss.xml"
        
        //XMLファイルをURL型のurlに変換
        let url:URL = URL(string: xmlString)!
        
        //parserにurlを代入
        parser = XMLParser(contentsOf: url)!
        
        //XMLParserを委任
        parser.delegate = self
        
        //parseの開始
        parser.parse()
        
        startTranslation()
    }
    
    //LanguageTranslatorMode通信をおこなう
    func startTranslation() {
        
        //APILanguageTranslatorの認証コードをモデルへ渡す
        let languageTranslatorModel = LanguageTranslatorModel(translatorApiKey: translatorApiKey, translatorVersion: translatorVersion, translatorURL: translatorURL, sampleText: sampleText)
        
        //LanguageTranslatorModelを委任
        languageTranslatorModel.doneCatchTranslationProtocol = self
        
        languageTranslatorModel.setLanguageTranslator()
    }
    
    //渡って値を処理
    func catchData(arrayData: Array<Translation>, resultCount: Int) {
        
        translationArray = arrayData
        
        //翻訳結果確認
        print("*****翻訳結果確認(Modelから受け渡し)*****")
        print("テスト: \(translationArray)")
        print("")
    }
    
    //ToneAnalyzerModelと通信をおこなう
    func startToneAnalyzer() {

        //APIToneAnalyzerの認証コードをモデルへ渡す
        let toneAnalyzerModel = ToneAnalyzerModel(analysisApiKey: analysisApiKey, analysisVersion: analysisVersion, analysisURL: analysisURL, sampleText: sampleText)

        //LanguageTranslatorModel.setLanguageTranslator()
    }
    
    
    // MARK: - LanguageTranslator
    //翻訳機能
//    func languageTranslator() {
//
//        //APIを認証するためのキーとversionとurlを定義
//        let translatorKey         = WatsonIAMAuthenticator(apiKey:"pLM8kVDHyCCa5t0IjajFd-rBmLB_jnmG3nl2mgdSsshM")
//        let translator            = LanguageTranslator(version: "2018-05-01", authenticator: translatorKey)
//            translator.serviceURL = "https://api.jp-tok.language-translator.watson.cloud.ibm.com"
//
//        //enからjaに翻訳（リクエスト送信）
//        translator.translate(text: [sampleText], modelID: "en-ja") {
//            response, error in
//
//            //エラー処理
//            if let error = error {
//                switch error {
//                case let .http(statusCode, message, metadata):
//                  switch statusCode {
//                  case .some(404):
//                    // Handle Not Found (404) exception
//                    print("Not found")
//                  case .some(413):
//                    // Handle Request Too Large (413) exception
//                    print("Payload too large")
//                  default:
//                    if let statusCode = statusCode {
//                      print("Error - code: \(statusCode), \(message ?? "")")
//                    }
//                  }
//                default:
//                  print(error.localizedDescription)
//                }
//                return
//              }
//
//            //データ処理
//            guard let translationResult = response?.result else {
//                print(error?.localizedDescription ?? "unknown error")
//                return
//            }
//
//            //レスポンスの結果で条件分岐
//            let responseCode = response?.statusCode
//            switch responseCode == Optional(200) {
//            case true:
//                //翻訳のデータをJSON形式に変換
//                let encoder = JSONEncoder()
//                encoder.outputFormatting = .prettyPrinted
//                guard let translationJSON = try? encoder.encode(translationResult) else {
//                    fatalError("Failed to encode to JSON.")
//                }
//
//                //JSONデータ確認
//                print("translationJSON: \(String(bytes: translationJSON, encoding: .utf8)!)")
//
//                //JSON解析(translation)
//                let translationValue = JSON(translationJSON)
//                let translation      = translationValue["translations"][self.count]["translation"].string
//
//                //翻訳結果確認
//                print("*****翻訳結果確認*****")
//                print("translation: \(translation)")
//                print("")
//
//            case false:
//                //ステータスコードの表示(200範囲は成功、400範囲は障害、500範囲は内部システムエラー)
//                print("translation failure: \(responseCode)")
//            }
//        }
//    }

    // MARK: - ToneAnalyzer
//    //感情分析
//    func toneAnalyzer() {
//        
//        //APIを認証するためのキーとversionとurlを定義
//        let toneAnalyzerKey         = WatsonIAMAuthenticator(apiKey:"36bKQ1j2Aga5xtwTHJKFoGwbPfxLnDUk6M7Dt6qVEhmr")
//        let toneAnalyzer            = ToneAnalyzer(version: "2017-09-21", authenticator: toneAnalyzerKey)
//            toneAnalyzer.serviceURL = "https://api.jp-tok.tone-analyzer.watson.cloud.ibm.com"
//
//        //sampleTextを分析（リクエスト送信）
//        toneAnalyzer.tone(toneContent: .text(sampleText)) {
//          response, error in
//
//          //エラー処理
//          if let error = error {
//            switch error {
//            case let .http(statusCode, message, metadata):
//                switch statusCode {
//                case .some(404):
//                    // Handle Not Found (404) exceptz1zion
//                    print("Not found")
//                case .some(413):
//                    // Handle Request Too Large (413) exception
//                    print("Payload too large")
//            default:
//                if let statusCode = statusCode {
//                    print("Error - code: \(statusCode), \(message ?? "")")
//                }
//            }
//            default:
//              print(error.localizedDescription)
//            }
//            return
//          }
//
//          //データ処理
//          guard let toneAnalysisResult = response?.result else {
//            print(error?.localizedDescription ?? "unknown error")
//            return
//          }
//
//          //レスポンスの結果で条件分岐
//          let statusCode = response?.statusCode
//            switch statusCode == Optional(200) {
//            case true:
//                //分析結果のデータをJSON形式に変換
//                let encoder = JSONEncoder()
//                encoder.outputFormatting = .prettyPrinted
//                guard let toneAnalysisJSON = try? encoder.encode(toneAnalysisResult) else {
//                    fatalError("Failed to encode to JSON.")
//                }
//
//                //JSONデータ確認
//                print("toneAnalysisJSON: \(String(bytes: toneAnalysisJSON, encoding: .utf8)!)")
//
//                //JSON解析(score)&小数点を切り上げて取得
//                let toneAnalysisValue = JSON(toneAnalysisJSON)
//                let firstToneScore    = toneAnalysisValue["document_tone"]["tones"][self.count]["score"].float
//                let firstScore        = ceil(firstToneScore! * 100)/100
//
//                let secondToneScore   = toneAnalysisValue["document_tone"]["tones"][self.count+1]["score"].float
//                let secondScore       = ceil(secondToneScore! * 100)/100
//
//                //JSON解析(tone_name)
//                let firstToneName  = toneAnalysisValue["document_tone"]["tones"][self.count]["tone_name"].string
//                let secondToneName = toneAnalysisValue["document_tone"]["tones"][self.count+1]["tone_name"].string
//
//                //感情分析結果確認
//                print("*****感情分析結果確認*****")
//                print("score     : \(firstScore)")
//                print("score     : \(secondScore)")
//                print("tone_name : \(firstToneName)")
//                print("tone_name : \(secondToneName)")
//
//            case false:
//                //ステータスコードの表示(200範囲は成功、400範囲は障害、500範囲は内部システムエラー)
//                print("analysis failure: \(statusCode)")
//            }
//        }
//    }

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
}
