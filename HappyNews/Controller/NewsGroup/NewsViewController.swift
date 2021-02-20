//
//  NewsViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/08/13.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import ToneAnalyzer
import LanguageTranslator
import SwiftyJSON
import PKHUD
import Kingfisher


// ▼参照しているclass
// NewsItems
// NewsCount
// UserDefault
// TimeScheduleModel
// DateItems
// LanguageTranslatorModel
// ToneAnalyzerModel
// WebViewController
// LocalNotificationModel

// XML解析をおこないニュースを取得、感情分析結果を受け取り、明るいニュースだけでUIを更新する主要クラス
class NewsViewController: UIViewController, XMLParserDelegate, UITableViewDataSource, UITableViewDelegate, DoneCatchTranslationProtocol, DoneCatchAnalyzerProtocol, DoneCatchTimeScheduleProtocol {
    
    
    // MARK: - XML Property
    // XMLファイルを保存
    var xmlString: String?
    
    // XMLParserのインスタンスを作成
    var parser = XMLParser()
    
    // XMLパース内の現在の要素名を取得する変数
    var currentElementName: String?
    
    // NewsItemsクラスのインスタンス作成
    var newsItems = [NewsItems]()
    
    // XMLファイルから取得するURLのパラメータを排除したURLを保存する値
    var imageParameter: String?
    
    
    // MARK: - LanguageTranslator Property
    // XMLファイルのニュースを保管する配列
    var newsTextArray: [String] = []
    
    // LanguageTranslationModelから渡ってくる値
    var translationArray      = [String]()
    var translationArrayCount = Int()
    
    
    // MARK: - ToneAnalyzer Property
    // ToneAnalyzerModelから渡ってくる値
    var joyCountArray = [Int]()
    
    // joyの要素と認定されたニュースの配列
    var joySelectionArray = [NewsItems]()
    
    
    // MARK: - Firebase Property
    // FireStoreのインスタンス
    let fireStoreDB = Firestore.firestore()
    
    // ニュースを取得する構造体のインスタンス
    var newsInfomation: [NewsInfoStruct] = []
    
    
    // MARK: - NewsTableView
    // NewsTableViewのインスタンス
    @IBOutlet var newsTable: UITableView!
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        // 前回起動時刻の確認
        print("前回起動時刻: \(UserDefault.lastActivation)")
        
        // ローカルpush通知の呼び出し
        LocalNotificationModel().morningNotification()
        LocalNotificationModel().afternoonNotification()
        LocalNotificationModel().eveningNotification()
        
        // NavigationBarの呼び出し
        setNewsNavigationBar()
        
        // 時間割を確認
        startTimeSchedule()
    }
    
    
    // MARK: - Navigation
    // ニュースページのNavigationBarを設定
    func setNewsNavigationBar() {
        
        // NavigationBarのタイトルとその色とフォント
        navigationItem.title = "HapyNews"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19.0, weight: .semibold)]
        
        // NavigationBarの色
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "00AECC")
        
        // 一部NavigationBarがすりガラス？のような感じになるのでfalseで統一
        self.navigationController?.navigationBar.isTranslucent = false
        
        // NavigationBarの下線を削除
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    // スクロールでナビゲーションバーを隠す
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    
    // MARK: - TimeSchedule
    // TimeScheduleModelと通信をおこない、API通信orキャッシュでUI更新かどうかを決める
    func startTimeSchedule() {
        
        // TimeScheduleModelと通信をおこないプロトコルを委託
        let timeScheduleModel = TimeScheduleModel(date: DateItems.date)
        timeScheduleModel.doneCatchTimeScheduleProtocol = self
        timeScheduleModel.setTimeSchedule()
    }
    
    // TimeScheduleModelから返ってきた値の受け取り
    func catchTimeSchedule(updateOrCache: Bool) {
        
        if updateOrCache == true {
            print("API通信開始")
            
            // XMLパースを開始してニュース情報をクリアしてAPI通信を開始
            settingXML()
            removeNewsData()
        } else {
            print("キャッシュでUI更新")
            
            // XMLパースを開始してキャッシュでUI更新
            settingXML()
            loadNewsData()
        }
    }
    
    
    // MARK: - XML Parser
    // XMLファイルを設定してパースを開始する
    func settingXML(){
        
        // XML解析をおこなうニュース
        xmlString = "https://news.yahoo.co.jp/rss/media/abema/all.xml"
        
        // XMLファイルをURL型のurlに変換
        let xmlURL = URL(string: xmlString!)!
        
        // parserにurlを代入
        parser = XMLParser(contentsOf: xmlURL)!
        
        // XMLParserを委任
        parser.delegate = self
        
        // parseの開始
        parser.parse()
    }
    
    // XML解析を開始する場合(parser.parse())に呼ばれるメソッド
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElementName = nil
        
        if elementName == "item" {
            newsItems.append(NewsItems())
        } else {
            currentElementName = elementName
        }
    }
    
    // <item>の中身を判定するメソッド(要素の解析開始と値取得）
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if newsItems.count > 0 {
            
            // XMLファイルに特定のタグが存在する場合の処理
            // 'link'と'image'はstringに分割されて値が入るので初めて代入する値以外は取得しない
            let lastItem = newsItems[newsItems.count - 1]
            switch currentElementName {
            
            // <title>が存在した場合
            case "title":
                lastItem.title = string
                
            // <link>が存在した場合
            case "link":
                if lastItem.url == nil {
                    lastItem.url = string
                } else {
                    break
                }
                
            // <pubDate>が存在した場合
            case "pubDate":
                // inputString = ニュース発行時刻(XML純正)
                let inputString = string
                
                // 地域とフォーマットを指定してDate型に変換
                DateItems.dateFormatter.locale = Locale(identifier: "ja_JP")
                DateItems.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let inputDate = DateItems.dateFormatter.date(from: inputString)
                
                // lastItem.pubDate = inputDateのフォーマットを指定してString型で代入
                DateItems.outputDateFormatter.dateFormat = "yyyy年M月d日(EEEEE) H時m分s秒"
                lastItem.pubDate = DateItems.outputDateFormatter.string(from: inputDate!)
                
            // <image>が存在した場合
            case "image":
                // パラメータを排除して取得する
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
    
    // XMLファイルの各値の</item>に呼ばれるメソッド（要素の解析終了）
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //新しい箱を準備
        self.currentElementName = nil
    }
    
    //　XML解析でエラーが発生した場合に呼ばれるメソッド
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("error:" + parseError.localizedDescription)
    }
    
    
    // MARK: - RemoveNewsData
    // fireStoreDBからニュース情報を削除
    func removeNewsData() {
        
        fireStoreDB.collection("news").document().delete() {
            error in
            
            // エラー処理
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
                
                // API通信開始
                self.startTranslation()
            }
        }
    }
    
    
    // MARK: - LanguageTranslator
    // LanguageTranslatorModelと通信をおこない、翻訳結果を感情分析に投げる
    func startTranslation() {
        
        // 感情分析中であることをユーザーに伝える
        HUD.show(.labeledProgress(title: "Happyを分析中...", subtitle: nil))
        
        // XMLファイルのニュース順と整合性を合わせるためreversedを使用。$iは合わせた番号の可視化（50 = first, 1 = last）
        for i in (1...NewsCount.itemCount).reversed() {
            newsTextArray.append(newsItems[newsItems.count - i].title!.description + "$\(i)")
        }
        
        // XMLファイルのニュース順を確認
        print("newsTextArray: \(newsTextArray.debugDescription)")
        
        // LanguageTranslatorModelと通信
        let languageTranslatorModel = LanguageTranslatorModel(languageTranslatorApiKey: LANGUAGE_TRANSLATOR_APIKEY, languageTranslatorVersion: languageTranslatorVersion,  languageTranslatorURL: languageTranslatorURL, newsTextArray: newsTextArray)
        
        // LanguageTranslatorModelの委託とJSON解析をセット
        languageTranslatorModel.doneCatchTranslationProtocol = self
        languageTranslatorModel.setLanguageTranslator()
    }
    
    // LanguageTranslatorModelから返ってきた値の受け取り
    func catchTranslation(arrayTranslationData: Array<String>, resultCount: Int) {
        
        translationArray      = arrayTranslationData
        translationArrayCount = resultCount
        
        print("translationArray: \(translationArray.debugDescription)")
        
        // 配列内の要素を確認するとToneAnalyzerを呼び出す
        if translationArray != nil {
            
            // ToneAnalyzerの呼び出し
            startToneAnalyzer()
        } else {
            print("Failed because the value is nil.")
        }
    }
    
    
    // MARK: - ToneAnalyzer
    // ToneAnalyzerModelと通信をおこない、感情分析結果を保存する
    func startToneAnalyzer() {
        
        // translationArrayとAPIToneAnalyzerの認証コードで通信
        let toneAnalyzerModel = ToneAnalyzerModel(toneAnalyzerApiKey: TONE_ANALYZER_APIKEY, toneAnalyzerVersion: toneAnalyzerVersion, toneAnalyzerURL: toneAnalyzerURL, translationArray: translationArray)
        
        // ToneAnalyzerModelの委託とJSON解析をセット
        toneAnalyzerModel.doneCatchAnalyzerProtocol = self
        toneAnalyzerModel.setToneAnalyzer()
    }
    
    // ToneAnalyzerModelから返ってきた値の受け取り、fireStoreDBへ保存
    func catchAnalyzer(arrayAnalyzerData: Array<Int>) {
        
        // 感情分析結果の確認
        print("arrayAnalyzerData.count: \(arrayAnalyzerData.count)")
        print("arrayAnalyzerData: \(arrayAnalyzerData.debugDescription)")
        
        // 感情分析結果の保存
        //UserDefault.standard.set(arrayAnalyzerData, forKey: "joyCountArray")
        
        // ToneAnalyzerModelから返ってきた値をインスタンス化
        joyCountArray = arrayAnalyzerData
        
        // joyCountArrayの中身を検索し、一致 = 意図するニュースを代入
        for i in 0..<joyCountArray.count {
            
            // 'i'固定、その間に'y'を加算
            for y in 0..<NewsCount.itemCount {
                
                switch self.joyCountArray != nil {
                case self.joyCountArray[i] == y:
                    self.joySelectionArray.append(self.newsItems[y])
                default:
                    break
                }
            }
            print("joySelectionArray\([i]): \(self.joySelectionArray[i].title.debugDescription)")
            
            // 1. ニュースの画像
            // 2. ニュースのタイトル
            // 3. ニュースの発行時刻
            // 4. ニュースのリンクURL
            // 計4点をfirestoreDBに保存
            fireStoreDB.collection(FirestoreCollectionName.newsInfomations).document(Auth.auth().currentUser!.uid).collection(FirestoreCollectionName.news).document().setData(
                ["newsSumbnail" : self.joySelectionArray[i].image,
                 "newsTitle": self.joySelectionArray[i].title,
                 "newsPubData": self.joySelectionArray[i].pubDate,
                 "newsURL": self.joySelectionArray[i].url]) {
                (error) in
                
                // エラー処理
                if error != nil {
                    
                    print("News save error: \(error.debugDescription)")
                    return
                }
            }
        }
        // UIの更新を行うメソッドの呼び出し
        loadNewsData()
    }
    
    
    // MARK: - LoadNewsData
    // ニュースをfireStoreDBから取得
    func loadNewsData() {
        
        // 日時の早い順に値をsnapShotに保存
        fireStoreDB.collection(FirestoreCollectionName.newsInfomations).document(Auth.auth().currentUser!.uid).collection(FirestoreCollectionName.news).getDocuments {
            (snapShot, error) in
            
            // 投稿情報を受け取る準備
            self.newsInfomation = []
            
            // Firestoreの中身を確認
            print("snapShot: \(snapShot?.documents)")
            print("snapShot.count: \(snapShot?.documents.count)")
            
            // エラー処理
            if error != nil {
                
                print("Message acquisition error: \(error.debugDescription)")
                return
            }
            
            // snapShotの中に保存されている値を取得する
            if let snapShotDocuments = snapShot?.documents {
                
                for document in snapShotDocuments {
                    
                    // fireStoreDBのドキュメントのコレクションのインスタンス
                    let documentData = document.data()
                    
                    // ニュース情報をインスタンス化して構造体に保存
                    let documentNewsTitle    = documentData["newsTitle"] as? String
                    let documentNewsSumbnail = documentData["newsSumbnail"] as? String
                    let documentNewsPubDat   = documentData["newsPubData"] as? String
                    let documentNewsURL      = documentData["newsURL"] as? String
                    
                    let newsInfo = NewsInfoStruct(newsTitle: documentNewsTitle!, newsSumbnail: documentNewsSumbnail!, newsPubData: documentNewsPubDat!, newsURL: documentNewsURL!, documentID: document.documentID)
                    
                    // 取得したニュース情報 （NewsInfoStruct型）
                    self.newsInfomation.append(newsInfo)
                    
                    print("newsInfomation: \(self.newsInfomation)")
                    
                    // チャット投稿内容の更新
                    self.newsTable.reloadData()
                    
                    // 感情分析が終了したことをユーザーに伝える
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        HUD.show(.label("分析が終了しました"))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            HUD.hide(animated: true)
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - NewsTableView
    // セクションの数を設定
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // セクションのヘッダーのタイトルを設定
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionTitle = "ニュース提供: ABEMA TIMES"
        return sectionTitle
    }
    
    // セクションヘッダーの高さを設定
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    // セクションのテキストを設定
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // セクションのテキストのインスタンス
        let categoryLabel = UILabel()
        
        // セクションのテキストを化粧
        categoryLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        categoryLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        categoryLabel.textColor = UIColor.darkGray
        
        return categoryLabel
    }
    
    // セルの数を設定
    func tableView(_ newsTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsInfomation.count
    }
    
    // セルの高さを設定
    func tableView(_ newsTable: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // 除外ワードを設定して感情分析の誤評価をフォロー
        if newsInfomation[indexPath.row].newsTitle.contains("コロナ") == true || newsInfomation[indexPath.row].newsTitle.contains("重症者") == true || newsInfomation[indexPath.row].newsTitle.contains("感染") == true || newsInfomation[indexPath.row].newsTitle.contains("遺体") == true || newsInfomation[indexPath.row].newsTitle.contains("逮捕") == true || newsInfomation[indexPath.row].newsTitle.contains("容疑者") == true ||
            newsInfomation[indexPath.row].newsTitle.contains("重症者") == true ||
            newsInfomation[indexPath.row].newsTitle.contains("不倫") == true ||
            newsInfomation[indexPath.row].newsTitle.contains("死亡") == true ||
            newsInfomation[indexPath.row].newsTitle.contains("事故") == true || newsInfomation[indexPath.row].newsTitle.contains("デモ") == true || newsInfomation[indexPath.row].newsTitle.contains("緊急事態宣言") == true || newsInfomation[indexPath.row].newsTitle.contains("火事") == true {
            
            // 文字列検索で該当すれば'return 0.1'を設定することで事実上UIからセルを削除
            return 0.1
        } else {
            return 360
        }
    }
    
    // セルを構築
    func tableView(_ newsTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // XML解析から取得したニュースの値が入る
        let news = newsInfomation[indexPath.row]
        
        // tableCellのIDでUITableViewCellのインスタンスを生成
        let cell = newsTable.dequeueReusableCell(withIdentifier: "newsTable", for: indexPath)
        
        // Tag番号(1)〜(4)でインスタンス作成(サムネイル, タイトル, サブタイトル, コメントボタン)
        let thumbnail         = cell.viewWithTag(1) as! UIImageView
        let newsTitle         = cell.viewWithTag(2) as! UILabel
        let subtitle          = newsTable.viewWithTag(3) as! UILabel
        let addFavoriteButton = newsTable.viewWithTag(4) as! UIButton?
        
        // サムネイルで扱うインスタンス(画像URL, 待機画像）
        let thumbnailURL = URL(string: news.newsSumbnail)
        let placeholder  = UIImage(named: "placeholder")
        
        // サムネイルの設定
        thumbnail.kf.setImage(with: thumbnailURL, placeholder: placeholder, options: [.transition(.fade(0.7))], progressBlock: nil)
        
        // サムネイルのアスペクト比を設定
        thumbnail.contentMode = .scaleToFill
        
        // ニュースのタイトルから社名を削除
        let replacingOccurrencesString = news.newsTitle.replacingOccurrences(of: "(ABEMA TIMES)", with: "")
        
        // ニュースタイトルを化粧
        newsTitle.text = replacingOccurrencesString
        newsTitle.textColor = UIColor(hex: "333333")
        newsTitle.numberOfLines = 3
        
        // サブタイトルを化粧
        subtitle.text = news.newsPubData
        subtitle.textColor = UIColor.gray
        
        // セルの境界線を削除
        newsTable.separatorStyle = .none
        
        // tableViewの背景色とセルの背景色
        newsTable.backgroundColor = UIColor(hex: "f4f8fa")
        cell.backgroundColor      = UIColor.white
        
        // 空のセルを削除
        newsTable.tableFooterView = UIView(frame: .zero)
        
        // IndexPathを取得するためのaddTarget
        addFavoriteButton?.tag = indexPath.row
        addFavoriteButton?.addTarget(self, action: #selector(tapAddFavoriteButton(_:)), for: .touchUpInside)
        
        return cell
    }
    
    // セルをタップした時呼ばれるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // タップ時の選択色の常灯を消す
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // WebViewControllerのインスタンス作成
        let webViewController = WebViewController()
        
        // WebViewのNavigationControllerを定義
        let webViewNavigation = UINavigationController(rootViewController: webViewController)
        
        // WebViewをフルスクリーンに
        webViewNavigation.modalPresentationStyle = .fullScreen
        
        // タップしたセルを検知
        let tapCell = self.newsInfomation[indexPath.row]
        
        // 検知したセルのurlを取得
        UserDefault.standard.set(tapCell.newsURL, forKey: "url")
        
        // WebViewControllerへ遷移
        present(webViewNavigation, animated: true)
    }
    
    
    // MARK: - TapNewsCommentButton
    // セルの☆をタップすると呼ばれる
    @objc func tapAddFavoriteButton(_ sender: UIButton) {
        print("お気に入りへ追加")
        
        // タップしたコメントボタンのセルのindexPathのrowを取得する
        let favoriteButtonID = sender.tag
        
        
        // お気に入り追加を促すアラートの作成
        let favoriteAlert = UIAlertController(title: "お気に入りに追加しますか？",message: "お気に入りに追加するといつでもニュースを見返せます。", preferredStyle: .alert)
        
        // アラートのボタン
        favoriteAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        favoriteAlert.addAction(UIAlertAction(title: "追加", style: .default, handler: {
            action in
            
            // 1. ニュースの画像
            // 2. ニュースのタイトル
            // 3. ニュースの発行時刻
            // 4. ニュースのリンクURL
            // 計4点をお気に入りニュースとしてfireStorDBへニュースを保存する
            self.fireStoreDB.collection(FirestoreCollectionName.newsInfomations).document(Auth.auth().currentUser!.uid).collection(FirestoreCollectionName.favoriteNews).document().setData(
                ["newsSumbnail": self.newsInfomation[favoriteButtonID].newsSumbnail,
                 "newsTitle"   : self.newsInfomation[favoriteButtonID].newsTitle,
                 "newsPubData" : self.newsInfomation[favoriteButtonID].newsPubData,
                 "newsURL"     : self.newsInfomation[favoriteButtonID].newsURL]) {
                (error) in
                
                // エラー処理
                if error != nil {
                    
                    print("News save error: \(error.debugDescription)")
                    return
                }
            }
        }))
        
        // アラートの表示
        present(favoriteAlert, animated: true, completion: nil)
    }
    
    
    // MARK: - TapFavoritePageButton
    // NavigationBarの☆をタップすると呼ばれる
    @IBAction func tapFavoritePageButton(_ sender: Any) {
        print("お気に入りページへ")
        // お気に入りニュースページへ遷移
        self.performSegue(withIdentifier: "favoritePage", sender: nil)
    }
    
}
