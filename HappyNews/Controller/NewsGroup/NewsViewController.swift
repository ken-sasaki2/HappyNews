//
//  ViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/08/13.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import SegementSlide

class NewsViewController: UIViewController, XMLParserDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //NewsTableViewのインスタンス
    @IBOutlet var newsTable: UITableView!
    
    //XMLファイルを保存するプロパティ
    var xmlString: String?
    
    //XMLParserのインスタンスを作成
    var parser = XMLParser()
    
    //RSSのパース内の現在の要素名を取得する変数
    var currentElementName: String?

    //NewsItemsモデルのインスタンス作成
    var newsItems = [NewsItemsModel]()
    
    //RSSから取得するURLのパラメータを排除したURLを保存する値
    var imageParameter: String?
    
    //UserDefaultsのインスタンス
    var userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        //NavigationBarの呼び出し
        setNewsNavigationBar()
        //scrollViewDidScroll(scrollView)
        
        //XML解析を開始する
        settingXML()
    }
    
    //ニュースページのNavigationBar設定
    func setNewsNavigationBar() {
        
        //NavigationBarのtitleとその色とフォント
        navigationItem.title = "HapyNews"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19.0, weight: .semibold)]
        
        //NavigationBarの色
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "00AECC")
        
        //一部NavigationBarがすりガラス？のような感じになるのでfalseで統一
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    // MARK: - XML Parser
    //XMLファイルを特定してパースを開始する
    func settingXML(){

        //'社会'カテゴリのニュース（ニッポン放送）
        xmlString = "https://news.yahoo.co.jp/rss/media/nshaberu/all.xml"

        //XMLファイルをURL型のurlに変換
        let url:URL = URL(string: xmlString!)!

        //parserにurlを代入
        parser = XMLParser(contentsOf: url)!

        //XMLParserを委任
        parser.delegate = self

        //parseの開始
        parser.parse()
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
            //'link'と'image'はstringに分割で値が入るので初めて代入する値以外は取得しない
            let lastItem = newsItems[newsItems.count - 1]
            switch currentElementName {
            case "title":
                lastItem.title       = string
                print(lastItem.title)
            case "link":
                if lastItem.url == nil {
                    lastItem.url     = string
                } else {
                    break
                }
            case "pubDate":
                lastItem.pubDate     = string
            case "description":
                lastItem.description = string
            case "image":
                //パラメータを排除して取得する
                if lastItem.image == nil {
                    imageParameter = string
                    let imageURL = imageParameter!.components(separatedBy: "?")
                    lastItem.image = imageURL[0]
                } else {
                    break
                }
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

    //XML解析でエラーが発生した場合に呼ばれるメソッド
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("error:" + parseError.localizedDescription)
    }
    
    // MARK: - Table view data source
    //セルの数を設定
    func tableView(_ newsTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count
    }
    
    //セルの高さを設定
    func tableView(_ newsTable: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    //セルを構築
    func tableView(_ newsTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //XML解析から取得したニュースの値が入る
        let newsItem = newsItems[indexPath.row]
        
        //tableCellのIDでUITableViewCellのインスタンスを生成
        let cell = newsTable.dequeueReusableCell(withIdentifier: "newsTable", for: indexPath)
        
        //Tag番号(1)でサムネイルのインスタンス作成
        let thumbnail = cell.viewWithTag(1) as! UIImageView
        
        //サムネイルを化粧
        let placeholder  = UIImage(named: "placeholder")
        thumbnail.image = placeholder
        thumbnail.contentMode = .scaleAspectFill
        
        //Tag番号(2)でニュースタイトルのインスタンス作成
        let newsTitle = cell.viewWithTag(2) as! UILabel
        
        //ニュースタイトルを化粧
        newsTitle.text = newsItem.title
        newsTitle.textColor = UIColor(hex: "333333")
        newsTitle.numberOfLines = 3
        
        //Tag番号(3)でニュース発行時刻のインスタンスを作成
        let subtitle = newsTable.viewWithTag(3) as! UILabel
        
        //サブタイトルを化粧
        subtitle.text = newsItem.pubDate
        subtitle.textColor = UIColor(hex: "cccccc")
        
        //空のセルを削除
        newsTable.tableFooterView = UIView(frame: .zero)

        //tableaviewの背景
        cell.backgroundColor = UIColor.white
        
        return cell
    }
    
    //セルをタップした時呼ばれるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //タップ時の選択色の常灯を消す
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        //WebViewControllerのインスタンス作成
        let webViewController = WebViewController()
        
        //WebViewのNavigationControllerを定義
        let webViewNavigation = UINavigationController(rootViewController: webViewController)
        
        //WebViewをフルスクリーンに
        webViewNavigation.modalPresentationStyle = .fullScreen
        
        //タップしたセルを検知
        let tapCell = newsItems[indexPath.row]
        
        //検知したセルのurlを取得
        userDefaults.set(tapCell.url, forKey: "url")
        
        //webViewControllerへ遷移
        present(webViewNavigation, animated: true)
    }

    //スクロールでナビゲーションバーを隠す
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
//            navigationController?.setNavigationBarHidden(true, animated: true)
//        } else {
//            navigationController?.setNavigationBarHidden(false, animated: true)
//        }
//    }
}

