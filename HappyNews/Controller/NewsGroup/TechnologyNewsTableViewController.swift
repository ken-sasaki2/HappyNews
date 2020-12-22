//
//  TechnologyNewsTableViewController.swift
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
import PKHUD

class TechnologyNewsTableViewController: UITableViewController,SegementSlideContentScrollViewDelegate, XMLParserDelegate, DoneCatchTranslationProtocol, DoneCatchAnalyzerProtocol {
    
    //XMLParserのインスタンスを作成
    var parser    = XMLParser()
    
    //NewsItemsモデルのインスタンス作成
    var newsItems = [NewsItemsModel]()
    
    //RSSのパース内の現在の要素名を取得する変数
    var currentElementName: String?
    
    //XMLファイルを保存するプロパティ
    var xmlString: String?
    
    //RSSのnewsを補完する配列
    var newsTextArray:[Any] = []
    
    //LanguageTranslatorの認証キー
    var languageTranslatorApiKey  = "4P6g4OrgJTj9GjpqoAZa0an1l00sA82KvXBC8al71ZS1"
    var languageTranslatorVersion = "2018-05-01"
    var languageTranslatorURL     = "https://api.jp-tok.language-translator.watson.cloud.ibm.com"
    
    //ToneAnalyzerの認証キー
    var toneAnalyzerApiKey  = "nKytQRfDwDRxdfoDeWT8J5b6WSVHc-mBENfjuITXnYji"
    var toneAnalyzerVersion = "2017-09-21"
    var toneAnalyzerURL     = "https://api.jp-tok.tone-analyzer.watson.cloud.ibm.com"
    
    //LanguageTranslationModelから渡ってくる値
    var translationArray      = [String]()
    var translationArrayCount = Int()
    
    //ToneAnalyzerModelから渡ってくる値
    var joyCountArray = [Int]()
    
    //joyの要素と認定されたニュースの配列
    var joySelectionArray = [NewsItemsModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        //tableaviewの背景
        tableView.backgroundColor = UIColor.white
        
        //XMLParseの処理
        //XMLファイルを特定
        let xmlArray = "https://news.yahoo.co.jp/rss/media/techcrj/all.xml"
        
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
        
        //翻訳機能の呼び出し
        startTranslation()
    }
    
    // MARK: - XML Parser
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
            case "image":
                lastItem.image       = string
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
    
    // MARK: - LanguageTranslator
    func startTranslation() {
        
        //感情分析中であることをユーザーに伝える
        HUD.show(.labeledProgress(title: "Happyを分析中...", subtitle: nil))
        
        //XMLのニュースの順番と整合性を合わせるためreversedを使用。$iは合わせた番号の可視化（50 = first, 1 = last）
        for i in (1...50).reversed() {
            newsTextArray.append(newsItems[newsItems.count - i].title!.description + "$\(i)")
        }
        
        print(newsTextArray)
        
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
        
        print(translationArray)
        
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
    func catchAnalyzer(arrayAnalyzerData: Array<Int>) {
        
        joyCountArray = arrayAnalyzerData
        print("joyCountArray.count: \(joyCountArray.count)")
        print("joyCountArray: \(joyCountArray.debugDescription)")
        
        for i in 0...joyCountArray.count - 1 {
                
                switch self.joyCountArray != nil {
                case self.joyCountArray[i] == 0:
                    self.joySelectionArray.append(self.newsItems[0])
                case self.joyCountArray[i] == 1:
                    self.joySelectionArray.append(self.newsItems[1])
                case self.joyCountArray[i] == 2:
                    self.joySelectionArray.append(self.newsItems[2])
                case self.joyCountArray[i] == 3:
                    self.joySelectionArray.append(self.newsItems[3])
                case self.joyCountArray[i] == 4:
                    self.joySelectionArray.append(self.newsItems[4])
                case self.joyCountArray[i] == 5:
                    self.joySelectionArray.append(self.newsItems[5])
                case self.joyCountArray[i] == 6:
                    self.joySelectionArray.append(self.newsItems[6])
                case self.joyCountArray[i] == 7:
                    self.joySelectionArray.append(self.newsItems[7])
                case self.joyCountArray[i] == 8:
                    self.joySelectionArray.append(self.newsItems[8])
                case self.joyCountArray[i] == 9:
                    self.joySelectionArray.append(self.newsItems[9])
                case self.joyCountArray[i] == 10:
                    self.joySelectionArray.append(self.newsItems[10])
                case self.joyCountArray[i] == 11:
                    self.joySelectionArray.append(self.newsItems[11])
                case self.joyCountArray[i] == 12:
                    self.joySelectionArray.append(self.newsItems[12])
                case self.joyCountArray[i] == 13:
                    self.joySelectionArray.append(self.newsItems[13])
                case self.joyCountArray[i] == 14:
                    self.joySelectionArray.append(self.newsItems[14])
                case self.joyCountArray[i] == 15:
                    self.joySelectionArray.append(self.newsItems[15])
                case self.joyCountArray[i] == 16:
                    self.joySelectionArray.append(self.newsItems[16])
                case self.joyCountArray[i] == 17:
                    self.joySelectionArray.append(self.newsItems[17])
                case self.joyCountArray[i] == 18:
                    self.joySelectionArray.append(self.newsItems[18])
                case self.joyCountArray[i] == 19:
                    self.joySelectionArray.append(self.newsItems[19])
                case self.joyCountArray[i] == 20:
                    self.joySelectionArray.append(self.newsItems[20])
                case self.joyCountArray[i] == 21:
                    self.joySelectionArray.append(self.newsItems[21])
                case self.joyCountArray[i] == 22:
                    self.joySelectionArray.append(self.newsItems[22])
                case self.joyCountArray[i] == 23:
                    self.joySelectionArray.append(self.newsItems[23])
                case self.joyCountArray[i] == 24:
                    self.joySelectionArray.append(self.newsItems[24])
                case self.joyCountArray[i] == 25:
                    self.joySelectionArray.append(self.newsItems[25])
                case self.joyCountArray[i] == 26:
                    self.joySelectionArray.append(self.newsItems[26])
                case self.joyCountArray[i] == 27:
                    self.joySelectionArray.append(self.newsItems[27])
                case self.joyCountArray[i] == 28:
                    self.joySelectionArray.append(self.newsItems[28])
                case self.joyCountArray[i] == 29:
                    self.joySelectionArray.append(self.newsItems[29])
                case self.joyCountArray[i] == 30:
                    self.joySelectionArray.append(self.newsItems[30])
                case self.joyCountArray[i] == 31:
                    self.joySelectionArray.append(self.newsItems[31])
                case self.joyCountArray[i] == 32:
                    self.joySelectionArray.append(self.newsItems[32])
                case self.joyCountArray[i] == 33:
                    self.joySelectionArray.append(self.newsItems[33])
                case self.joyCountArray[i] == 34:
                    self.joySelectionArray.append(self.newsItems[34])
                case self.joyCountArray[i] == 35:
                    self.joySelectionArray.append(self.newsItems[35])
                case self.joyCountArray[i] == 36:
                    self.joySelectionArray.append(self.newsItems[36])
                case self.joyCountArray[i] == 37:
                    self.joySelectionArray.append(self.newsItems[37])
                case self.joyCountArray[i] == 38:
                    self.joySelectionArray.append(self.newsItems[38])
                case self.joyCountArray[i] == 39:
                    self.joySelectionArray.append(self.newsItems[39])
                case self.joyCountArray[i] == 40:
                    self.joySelectionArray.append(self.newsItems[40])
                case self.joyCountArray[i] == 41:
                    self.joySelectionArray.append(self.newsItems[41])
                case self.joyCountArray[i] == 42:
                    self.joySelectionArray.append(self.newsItems[42])
                case self.joyCountArray[i] == 43:
                    self.joySelectionArray.append(self.newsItems[43])
                case self.joyCountArray[i] == 44:
                    self.joySelectionArray.append(self.newsItems[44])
                case self.joyCountArray[i] == 45:
                    self.joySelectionArray.append(self.newsItems[45])
                case self.joyCountArray[i] == 46:
                    self.joySelectionArray.append(self.newsItems[46])
                case self.joyCountArray[i] == 47:
                    self.joySelectionArray.append(self.newsItems[47])
                case self.joyCountArray[i] == 48:
                    self.joySelectionArray.append(self.newsItems[48])
                case self.joyCountArray[i] == 49:
                    self.joySelectionArray.append(self.newsItems[49])
                default:
                    print("Unable to detect joy.")
                }
                print("joySelectionArray\([i]): \(self.joySelectionArray[i].title.debugDescription)")
        }
        
        if joySelectionArray.count == joyCountArray.count {
            
            //メインスレッドでUIの更新
            DispatchQueue.main.async {
                //tableViewの更新
                self.tableView.reloadData()
                
                //感情分析が終了したことをユーザーに伝える
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    HUD.show(.label("分析が終了しました"))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        HUD.hide(animated: true)
                    }
                }
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
        return joySelectionArray.count
    }
    
    //セルの高さを決めるメソッド
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height/6
    }
    
    //セルを構築する際に呼ばれるメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //RSSで取得したニュースの値が入る
        let newsItem = joySelectionArray[indexPath.row]
        
        //セルのスタイルを設定
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell" )
        
        for i in 0...joySelectionArray.count - 1 {
            //サムネイルの設定
            cell.imageView?.image = UIImage(url: "https://amd-pctr.c.yimg.jp/r/iwiz-amd/20201213-00008363-entame-000-1-view.jpg?w=450&h=300&q=90&exp=10800&pri=l")
        }
        
        cell.imageView?.image = cell.imageView?.image?.resize(_size: CGSize(width: 120, height: 100))
    
        //セルを化粧
        cell.backgroundColor = UIColor.white
        cell.textLabel?.text = newsItem.title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .medium)
        cell.textLabel?.textColor = UIColor(hex: "333")
        
        //空のセルを削除
        tableView.tableFooterView = UIView(frame: .zero)
        
        cell.textLabel?.numberOfLines = 2
        
        //インスタンス作成
        let dateFormatter = DateFormatter()
        
        //フォーマット設定
        dateFormatter.dateFormat = "yyyy'年'M'月'd'日('EEEEE') 'H'時'm'分's'秒'"

        //ロケール設定（日本語・日本国固定）
        dateFormatter.locale = Locale(identifier: "ja_JP")

        //タイムゾーン設定（日本標準時固定）
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        //Date型 → string型
        let pubDateString = dateFormatter.string(from: Date())
        
        //セルのサブタイトル
        cell.detailTextLabel?.text = pubDateString
        cell.detailTextLabel?.textColor = UIColor.gray
        
        return cell
    }
    
    //セルをタップした時呼ばれるメソッド
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //タップ時の選択色の常灯を消す
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
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
