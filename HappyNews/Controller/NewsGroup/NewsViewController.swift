//
//  NewsViewController.swift
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
import Kingfisher

class NewsViewController: UIViewController, XMLParserDelegate, UITableViewDataSource, UITableViewDelegate, DoneCatchTranslationProtocol, DoneCatchAnalyzerProtocol, DoneCatchTimeScheduleProtocol {
    

    // MARK: - XML Property
    //XMLファイルを保存するプロパティ
    var xmlString: String?
    
    //XMLParserのインスタンスを作成
    var parser = XMLParser()
    
    //XMLパース内の現在の要素名を取得する変数
    var currentElementName: String?

    //NewsItemsモデルのインスタンス作成
    var newsItems = [NewsItemsModel]()
    
    //XMLから取得するURLのパラメータを排除したURLを保存する値
    var imageParameter: String?
    
    
    // MARK: - LanguageTranslator Property
    //XMLファイルのニュースを補完する配列
    var newsTextArray: [String] = []
    
    //LanguageTranslatorの認証キー
    var languageTranslatorApiKey  = "J4LQkEl7BWhZL2QaeLzRIRSwlg4sna1J7-09opB-9Gqf"
    var languageTranslatorVersion = "2018-05-01"
    var languageTranslatorURL     = "https://api.jp-tok.language-translator.watson.cloud.ibm.com"
    
    //LanguageTranslationModelから渡ってくる値
    var translationArray      = [String]()
    var translationArrayCount = Int()
    
    
    // MARK: - ToneAnalyzer Property
    //ToneAnalyzerの認証キー
    var toneAnalyzerApiKey  = "3Js4t4WMZzeIR_vqmFSsHiaP7Hrq39fw-t4yc5WqDDau"
    var toneAnalyzerVersion = "2017-09-21"
    var toneAnalyzerURL     = "https://api.jp-tok.tone-analyzer.watson.cloud.ibm.com"
    
    //ToneAnalyzerModelから渡ってくる値
    var joyCountArray = [Int]()
    
    //joyの要素と認定されたニュースの配列と検索する際のカウント
    var joySelectionArray = [NewsItemsModel]()
    var newsCount         = 50
    
    
    // MARK: - NewsTableView
    //NewsTableViewのインスタンス
    @IBOutlet var newsTable: UITableView!

    //セクションのタイトル
    let newsCategoryArray: [String] = ["社会", "スポーツ", "エンタメ", "ビジネス・経済", "IT・化学"]
    
    
    // MARK: - Other Property
    //UserDefaultsのインスタンス
    var userDefaults = UserDefaults.standard
    
    //現在時刻の取得とそのフォーマット
    var dateTime         = Date()
    var dateTimeFormat   = DateFormatter()
    var outputDateFormat = DateFormatter()
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        //前回起動時刻の確認
        print("前回起動時刻: \(userDefaults.string(forKey: "lastActivation"))")
        
        //NavigationBarの呼び出し
        setNewsNavigationBar()
        
        //時間割を確認
        startTimeSchedule()
    }
    
    
    // MARK: - Navigation
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
    
    //スクロールでナビゲーションバーを隠す
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    
    // MARK: - TimeSchedule
    //TimeScheduleModelと通信をおこない、API通信orキャッシュ利用かどうかを決める
    func startTimeSchedule() {
        
        //TimeScheduleModelと通信をおこないプロトコルを委託
        let timeScheduleModel = TimeScheduleModel(dateTime: dateTime, dateTimeFormat: dateTimeFormat)
            timeScheduleModel.doneCatchTimeScheduleProtocol = self
            timeScheduleModel.setTimeSchedule()
    }
    
    //TimeScheduleModelから返ってきた値の受け取り
    func catchTimeSchedule(updateOrCache: Bool) {
        
        if updateOrCache == true {
            print("API通信開始")
            
            //XMLパースを開始してAPI通信を開始
            settingXML()
            startTranslation()
            
        } else {
            print("キャッシュでUI更新")
            
            //XMLパースを開始してキャッシュでリロード
            settingXML()
            reloadNewsData()
//            startTranslation()
        }
    }
    
    
    // MARK: - XML Parser
    //XMLファイルを特定してパースを開始する
    func settingXML(){

        //XML解析をおこなうニュースの配列
        //ニッポン放送
        //テレビ東京スポーツ
        //ザ・テレビジョン
        //東洋経済オンライン
        //TechCrunch Japan
        let xmlArray = "https://news.yahoo.co.jp/rss/media/entame/all.xml"
        
        
        //"https://news.yahoo.co.jp/rss/media/tvtokyos/all.xml",
        //"https://news.yahoo.co.jp/rss/media/the_tv/all.xml",
        //"https://news.yahoo.co.jp/rss/media/toyo/all.xml",
        //"https://news.yahoo.co.jp/rss/media/techcrj/all.xml"
        
        //xmlArrayのニュースを取り出す
        //for i in 0...xmlArray.count - 1  {
            xmlString = xmlArray
            
            //XMLファイルをURL型のurlに変換
            let url:URL = URL(string: xmlString!)!
            
            //parserにurlを代入
            parser = XMLParser(contentsOf: url)!
            
            //XMLParserを委任
            parser.delegate = self
            
            //parseの開始
            parser.parse()
        //}
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
                lastItem.title      = string
            case "link":
                if lastItem.url == nil {
                    lastItem.url    = string
                } else {
                    break
                }
            case "pubDate":
                //inputString = ニュース発行時刻(XML純正)
                let inputString       = string
                
                //地域とフォーマットを指定してDate型に変換
                dateTimeFormat.locale = Locale(identifier: "ja_JP")
                dateTimeFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let inputDate = dateTimeFormat.date(from: inputString)
                
                //lastItem.pubDate = inputDateのフォーマットを指定してString型で代入
                outputDateFormat.dateFormat = "yyyy年M月d日(EEEEE) H時m分s秒"
                lastItem.pubDate = outputDateFormat.string(from: inputDate!)
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
    
    //XMLファイルの各値の</item>に呼ばれるメソッド（要素の解析終了）
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //新しい箱を準備
        self.currentElementName = nil
    }

    //XML解析でエラーが発生した場合に呼ばれるメソッド
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("error:" + parseError.localizedDescription)
    }
    
    
    // MARK: - LanguageTranslator
    //LanguageTranslatorModelと通信をおこない、翻訳結果を感情分析に投げる
    func startTranslation() {
        
        //感情分析中であることをユーザーに伝える
        HUD.show(.labeledProgress(title: "Happyを分析中...", subtitle: nil))
        
        //XMLのニュースの順番と整合性を合わせるためreversedを使用。$iは合わせた番号の可視化（50 = first, 1 = last）
        for i in (1...50).reversed() {
            newsTextArray.append(newsItems[newsItems.count - i].title!.description + "$\(i)")
        }
        
        print("newsTextArray: \(newsTextArray.debugDescription)")
        
        //LanguageTranslatorModelと通信
        let languageTranslatorModel = LanguageTranslatorModel(languageTranslatorApiKey: languageTranslatorApiKey, languageTranslatorVersion: languageTranslatorVersion,  languageTranslatorURL: languageTranslatorURL, newsTextArray: newsTextArray)
        
        //LanguageTranslatorModelの委託とJSON解析をセット
        languageTranslatorModel.doneCatchTranslationProtocol = self
        languageTranslatorModel.setLanguageTranslator()
    }
    
    //LanguageTranslatorModelから返ってきた値の受け取り
    func catchTranslation(arrayTranslationData: Array<String>, resultCount: Int) {
        
        translationArray      = arrayTranslationData
        translationArrayCount = resultCount
        
        print("translationArray: \(translationArray.debugDescription)")
        
        //配列内の要素を確認するとToneAnalyzerを呼び出す
        if translationArray != nil {
            
            //ToneAnalyzerの呼び出し
            startToneAnalyzer()
        } else {
            print("Failed because the value is nil.")
        }
    }

    
    // MARK: - ToneAnalyzer
    //ToneAnalyzerModelと通信をおこない、感情分析結果を保存する
    func startToneAnalyzer() {
        //translationArrayとAPIToneAnalyzerの認証コードで通信
        let toneAnalyzerModel = ToneAnalyzerModel(toneAnalyzerApiKey: toneAnalyzerApiKey, toneAnalyzerVersion: toneAnalyzerVersion, toneAnalyzerURL: toneAnalyzerURL, translationArray: translationArray)
        
        //ToneAnalyzerModelの委託とJSON解析をセット
        toneAnalyzerModel.doneCatchAnalyzerProtocol = self
        toneAnalyzerModel.setToneAnalyzer()
    }
    
    //ToneAnalyzerModelから返ってきた値の受け取り
    func catchAnalyzer(arrayAnalyzerData: Array<Int>) {
        
        //感情分析結果の確認
        print("arrayAnalyzerData.count: \(arrayAnalyzerData.count)")
        print("arrayAnalyzerData: \(arrayAnalyzerData.debugDescription)")
        
        //感情分析結果の保存
        userDefaults.set(arrayAnalyzerData, forKey: "joyCountArray")
        
        //UIの更新を行うメソッドの呼び出し
        reloadNewsData()
    }

    //感情分析結果を用いて新たにNewsの配列を作成し、UIの更新を行う
    func reloadNewsData() {
        
        //感情分析結果の取り出し
        joyCountArray = userDefaults.array(forKey: "joyCountArray") as! [Int]
        print("joyCountArray: \(joyCountArray)")
        
        //joyCountArrayの中身を検索し、一致 = 意図するニュースを代入
        for i in 0...joyCountArray.count - 1 {
            
            //'i'固定、その間に'y'を加算
            for y in 0...newsCount - 1 {
                
                switch self.joyCountArray != nil {
                case self.joyCountArray[i] == y:
                    self.joySelectionArray.append(self.newsItems[y])
                default:
                    break
                }
            }
            print("joySelectionArray\([i]): \(self.joySelectionArray[i].title.debugDescription)")
        }
   
        //感情分析結果と新たに作成した配列の比較
        if joySelectionArray.count == joyCountArray.count {
            
            //メインスレッドでUIの更新
            DispatchQueue.main.async {
                
                //tableViewの更新
                self.newsTable.reloadData()
                
                //感情分析が終了したことをユーザーに伝える
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    HUD.show(.label("分析が終了しました"))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        HUD.hide(animated: true)
                    }
                }
            }
        }
    }
    
    
    // MARK: - NewsTableView
    //セクションの数を設定
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return newsCategoryArray.count
//    }
//
//    //セクションのヘッダーのタイトルを設定
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return newsCategoryArray[section]
//    }
//
//    //セクションヘッダーの高さを設定
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }
//
//    //セクションのテキストを設定
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        //セクションのテキストのインスタンス
//        let categoryLabel = UILabel()
//
//        //セクションのテキストを化粧
//        categoryLabel.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
//        categoryLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
//        categoryLabel.textColor = UIColor(hex: "333333")
//
//        return categoryLabel
//    }
    
    //セルの数を設定
    func tableView(_ newsTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return joySelectionArray.count
    }
    
    //セルの高さを設定
    func tableView(_ newsTable: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 360
    }

    //セルを構築
    func tableView(_ newsTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //XML解析から取得したニュースの値が入る
        let joyNewsItem = joySelectionArray[indexPath.row]
        
        //tableCellのIDでUITableViewCellのインスタンスを生成
        let cell = newsTable.dequeueReusableCell(withIdentifier: "newsTable", for: indexPath)
        
        //Tag番号(1)〜(3)でインスタンス作成(サムネイル, タイトル, サブタイトル)
        let thumbnail = cell.viewWithTag(1) as! UIImageView
        let newsTitle = cell.viewWithTag(2) as! UILabel
        let subtitle = newsTable.viewWithTag(3) as! UILabel
        
        //ニュース会社名を末尾指定で取得
        //let suffix1 = joyNewsItem.title?.description.suffix(10)
        
        // MARK: - ニッポン放送
        //取得したニュース会社名を検索し、含んでいる場合はセクション毎に振り分ける
        //        if suffix1!.contains("ニッポン放送") {
        //
        //            if indexPath.section == 0 {
        
        //サムネイルで扱うインスタンス(画像URL, 待機画像）
        let thumbnailURL = URL(string: joyNewsItem.image!.description)
        let placeholder  = UIImage(named: "placeholder")
        
        //サムネイルの設定
        thumbnail.kf.setImage(with: thumbnailURL, placeholder: placeholder, options: [.transition(.fade(0.7))], progressBlock: nil)
        
        //サムネイルのアスペクト比を設定
        thumbnail.contentMode = .scaleAspectFill
        
        //ニュースタイトルを化粧
        newsTitle.text = joyNewsItem.title
        newsTitle.textColor = UIColor(hex: "333333")
        newsTitle.numberOfLines = 3
        
        //サブタイトルを化粧
        subtitle.text = joyNewsItem.pubDate
        subtitle.textColor = UIColor.gray
//            }
//        }
        
        
        // MARK: - テレビ東京スポーツ
//        else if suffix1!.contains("テレビ東京スポーツ") {
//
//            if indexPath.section == 1 {
//
//                //サムネイルの化粧で扱うインスタンス(画像URL, 待機画像）
//                let thumbnailURL = URL(string: joyNewsItem.image!.description)
//                let placeholder  = UIImage(named: "placeholder")
//
//                //サムネイルの設定
//                thumbnail.kf.setImage(with: thumbnailURL, placeholder: placeholder, options: [.transition(.fade(0.2))])
//
//                //サムネイルを化粧
//                thumbnail.contentMode = .scaleAspectFill
//
//                //ニュースタイトルを化粧
//                newsTitle.text = joyNewsItem.title
//                newsTitle.textColor = UIColor(hex: "333333")
//                newsTitle.numberOfLines = 3
//
//                //サブタイトルを化粧
//                subtitle.text = joyNewsItem.pubDate
//                subtitle.textColor = UIColor.gray
//            }
//        }
//
//
//        // MARK: - ザ・テレビジョン
//        else if suffix1!.contains("ザ・テレビジョン") {
//
//            if indexPath.section == 2 {
//
//                //サムネイルの化粧で扱うインスタンス(画像URL, 待機画像）
//                let thumbnailURL = URL(string: joyNewsItem.image!.description)
//                let placeholder  = UIImage(named: "placeholder")
//
//                //サムネイルの設定
//                thumbnail.kf.setImage(with: thumbnailURL, placeholder: placeholder, options: [.transition(.fade(0.2))])
//
//                //サムネイルを化粧
//                thumbnail.contentMode = .scaleAspectFill
//
//                //ニュースタイトルを化粧
//                newsTitle.text = joyNewsItem.title
//                newsTitle.textColor = UIColor(hex: "333333")
//                newsTitle.numberOfLines = 3
//
//                //サブタイトルを化粧
//                subtitle.text = joyNewsItem.pubDate
//                subtitle.textColor = UIColor.gray
//            }
//        }
//
//
//        // MARK: - 東洋経済オンライン
//        else if suffix1!.contains("東洋経済オンライン") {
//
//            if indexPath.section == 3 {
//
//                //サムネイルの化粧で扱うインスタンス(画像URL, 待機画像）
//                let thumbnailURL = URL(string: joyNewsItem.image!.description)
//                let placeholder  = UIImage(named: "placeholder")
//
//                //サムネイルの設定
//                thumbnail.kf.setImage(with: thumbnailURL, placeholder: placeholder, options: [.transition(.fade(0.2))])
//
//                //サムネイルを化粧
//                thumbnail.contentMode = .scaleAspectFill
//
//                //ニュースタイトルを化粧
//                newsTitle.text = joyNewsItem.title
//                newsTitle.textColor = UIColor(hex: "333333")
//                newsTitle.numberOfLines = 3
//
//                //サブタイトルを化粧
//                subtitle.text = joyNewsItem.pubDate
//                subtitle.textColor = UIColor.gray
//            }
//        }
//
//
//        // MARK: - TechCrunch Japan
//        else if suffix1!.contains("TechCrunch Japan") {
//
//            if indexPath.section == 4 {
//
//                //サムネイルの化粧で扱うインスタンス(画像URL, 待機画像）
//                let thumbnailURL = URL(string: joyNewsItem.image!.description)
//                let placeholder  = UIImage(named: "placeholder")
//
//                //サムネイルの設定
//                thumbnail.kf.setImage(with: thumbnailURL, placeholder: placeholder, options: [.transition(.fade(0.2))])
//
//                //サムネイルを化粧
//                thumbnail.contentMode = .scaleAspectFill
//
//                //ニュースタイトルを化粧
//                newsTitle.text = joyNewsItem.title
//                newsTitle.textColor = UIColor(hex: "333333")
//                newsTitle.numberOfLines = 3
//
//                //サブタイトルを化粧
//                subtitle.text = joyNewsItem.pubDate
//                subtitle.textColor = UIColor.gray
//            }
//        }
        
        //セルの境目の線を削除
        newsTable.separatorStyle = .none
        
        //newsTable.backgroundColor = UIColor.white
        
        //空のセルを削除
        newsTable.tableFooterView = UIView(frame: .zero)

        //tableviewの背景
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
        let tapCell = joySelectionArray[indexPath.row]
        
        //検知したセルのurlを取得
        userDefaults.set(tapCell.url, forKey: "url")
        
        //webViewControllerへ遷移
        present(webViewNavigation, animated: true)
    }
}

