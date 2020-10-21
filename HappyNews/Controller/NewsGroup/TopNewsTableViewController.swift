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
import SwiftyJSON
import Alamofire

class TopNewsTableViewController: UITableViewController,SegementSlideContentScrollViewDelegate, XMLParserDelegate{
    
    //XMLParserのインスタンスを作成
    var parser = XMLParser()
    
    //RSSのパース内の現在の要素名を取得する変数
    var currentElementName:String!
    
    //NewsItems型のクラスが入る配列の宣言
    var newsItems = [NewsItems]()
    
    //JSONの配列取得で必要
    var count = 0
    
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
        
        //toneAnalyzer(感情分析)の呼び出し
        toneAnalyzer()
    }
    
    // MARK: - Watson ToneAnalyzer
    //ToneAnalyzer(感情分析)用メソッド
    func toneAnalyzer() {
        
        //WatsonAPIキーのインスタンス作成
        let authenticator = WatsonIAMAuthenticator(apiKey: "36bKQ1j2Aga5xtwTHJKFoGwbPfxLnDUk6M7Dt6qVEhmr")
        
        //WatsonAPIのversionとURLを定義
        let toneAnalyzer = ToneAnalyzer(version: "2017-09-21", authenticator: authenticator)
            toneAnalyzer.serviceURL = "https://api.jp-tok.tone-analyzer.watson.cloud.ibm.com"
        
        //分析用サンプルテキスト
        let sampleText = """
        Team, I know that times are tough! Product \
        sales have been disappointing for the past three \
        quarters. We have a competitive product, but we \
        need to do a better job of selling it!
        """
        
        //SSL検証を無効化(不要？)
        //toneAnalyzer.disableSSLVerification()
        
        //エラー処理
        toneAnalyzer.tone(toneContent: .text(sampleText)){
          response, error in
          if let error = error {
            switch error {
            case let .http(statusCode, message, metadata):
              switch statusCode {
              case .some(404):
                // Handle Not Found (404) exceptz1zion
                print("Not found")
              case .some(413):
                // Handle Request Too Large (413) exception
                print("Payload too large")
              default:
                if let statusCode = statusCode {
                  print("Error - code: \(statusCode), \(message ?? "")")
                }
              }
            default:
              print(error.localizedDescription)
            }
            return
          }
          //データ処理
          guard let result = response?.result else {
            print(error?.localizedDescription ?? "unknown error")
            return
          }
          //ステータスコードの定数を作成し条件分岐
          let statusCode = response?.statusCode
            switch statusCode == Optional(200)  {
                case true:
                    print("分析成功: \(statusCode)")
                    //分析結果の定数を作成
                    let analysisResult = result
                    
                    //JSONへ変換するencoderを用意
                    let encoder = JSONEncoder()
                    
                    //可読性を高めるためにJSONを整形
                    encoder.outputFormatting = .prettyPrinted
                    
                    //分析結果をJSONに変換
                    guard let jsonValue = try? encoder.encode(analysisResult) else {
                        fatalError("Failed to encode to JSON.")
                    }
                    
                    //JSONデータ確認
                    print("感情分析結果(JSON): \(String(bytes: jsonValue, encoding: .utf8)!)")
                    
//                    let toneScore = self.jsonValue["tones"][self.count]["score"].float
                    
                    //ヘッダーパラメータ
                    print(response?.headers as Any)
                    
                case false:
                    //ステータスコードの表示(200範囲は成功、400範囲は障害、500範囲は内部システムエラー)
                    print("分析失敗: \(statusCode)")
            }
        }
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
