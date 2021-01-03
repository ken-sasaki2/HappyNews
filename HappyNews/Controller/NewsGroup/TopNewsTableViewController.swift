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
import PKHUD
import Kingfisher

class TopNewsTableViewController: UITableViewController,SegementSlideContentScrollViewDelegate, XMLParserDelegate, DoneCatchTranslationProtocol, DoneCatchAnalyzerProtocol {
    
    //XMLParserのインスタンスを作成
    var parser = XMLParser()
    
    //NewsItemsモデルのインスタンス作成
    var newsItems = [NewsItemsModel]()
    
    //RSSのパース内の現在の要素名を取得する変数
    var currentElementName: String?
    
    //XMLファイルを保存するプロパティ
    var xmlString: String?
    
    //RSSのnewsを補完する配列
    var newsTextArray:[Any] = []
    
    //LanguageTranslatorの認証キー
    var languageTranslatorApiKey  = "J4LQkEl7BWhZL2QaeLzRIRSwlg4sna1J7-09opB-9Gqf"
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
    
    //RSSから取得するURLのパラメータを排除したURLを保存する値
    var imageParameter: String?
    
    //APIの更新がおこなわれたかを判断する変数
    var morningUpdate        : String?
    var afternoonUpdate      : String?
    var eveningUpdate        : String?
    var lateAtNightTimeUpdate: String?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        //tableaviewの背景
        tableView.backgroundColor = UIColor.white
        
        //XMLParseの処理
        //XMLファイルを特定
        let xmlArray = "https://news.yahoo.co.jp/rss/media/tvtnews/all.xml"
        
        let xmlString = xmlArray
        
        //XMLファイルをURL型のurlに変換
        let url:URL = URL(string: xmlString)!
        
        //parserにurlを代入
        parser = XMLParser(contentsOf: url)!
        
        //XMLParserを委任
        parser.delegate = self
        
        //parseの開始
        parser.parse()
    

        timeComparison()
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
            //'link'と'image'はstringに分割で値が入るので初めて代入する値以外は取得しない
            let lastItem = newsItems[newsItems.count - 1]
            switch currentElementName {
            case "title":
                lastItem.title       = string
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
    
    //時間の比較とそれに合った処理をおこなう
    func timeComparison() {
        
        //やりたいこと
        //'07:00', '11:00', '17:00' 以降にアプリを起動するとAPI（News）を更新する
        //その時間間隔の中での更新は一度だけで、次の更新は特定の時刻が来るまでしない
        //なので、特定の時間間隔内で更新した情報はキャッシュに保存して表示しておく
        
        //実装手順(イメージの言語化)
        //アプリ起動時刻と前回起動時刻を比較して時間を超えているかどうかで処理をおこなう
        //条件に一致していればAPIを更新、また、更新した証をローカルに保存しておく？
        //そうでなければキャッシュを表示
        
        //現在時刻の取得
        let date = Date()
        let dateFormatter = DateFormatter()
        
        //日時のフォーマットと地域を指定
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone   = TimeZone(identifier: "Asia/Tokyo")
        
        //アプリ起動時刻を定義
        let currentTime = dateFormatter.string(from: date)
        print("現在時刻: \(currentTime)")
        
        //アプリ起動時刻の保存
        UserDefaults.standard.set(currentTime, forKey: "lastActivation")
        
        //定時時刻の設定
        let morningPoint     = dateFormatter.date(from: "07:00:00")
        let afternoonPoint   = dateFormatter.date(from: "11:00:00")
        let eveningPoint     = dateFormatter.date(from: "17:00:00")
        let nightPoint       = dateFormatter.date(from: "23:59:59")
        let lateAtNightPoint = dateFormatter.date(from: "00:00:00")
        
        //定時時刻の変換
        let morningTime     = dateFormatter.string(from: morningPoint!)
        let afternoonTime   = dateFormatter.string(from: afternoonPoint!)
        let eveningTime     = dateFormatter.string(from: eveningPoint!)
        let nightTime       = dateFormatter.string(from: nightPoint!)
        let lateAtNightTime = dateFormatter.string(from: lateAtNightPoint!)
        
        
        print("morningTime    : \(morningTime)")
        print("afternoonTime  : \(afternoonTime)")
        print("eveningTime    : \(eveningTime)")
        print("nightTime      : \(nightTime)")
        print("lateAtNightTime: \(lateAtNightTime)")
        
        //前回起動時刻の取り出し
        let lastActivation = UserDefaults.standard.string(forKey: "lastActivation")
        print("lastActivation: \(lastActivation)")
        
        //前回起動時刻と定時時刻の間隔で時間割（日付を無くして全て時間指定）
        //07:00以降11:00以前の場合
        if lastActivation!.compare(morningTime) == .orderedDescending && lastActivation!.compare(afternoonTime) == .orderedAscending {
            
            //morningUpdateがnilならAPIを更新、nilでなければキャッシュの表示
            if morningUpdate == nil {
                print("朝のAPI更新")
                
                morningUpdate         = "morningUpdate"
                lateAtNightTimeUpdate = nil
            } else {
                print("キャッシュの表示")
            }
        }
        
        //11:00以降17:00以前の場合
        else if lastActivation!.compare(afternoonTime) == .orderedDescending && lastActivation!.compare(eveningTime) == .orderedAscending {
            
            //afternoonUpdateがnilならAPIを更新、nilでなければキャッシュの表示
            if afternoonUpdate == nil {
                print("昼のAPI更新")
                
                afternoonUpdate = "afternoonUpdate"
                morningUpdate   = nil
            } else {
                print("キャッシュの表示")
            }
        }
        
        //17:00以降23:59:59以前の場合（1日の最後）
        else if lastActivation!.compare(eveningTime) == .orderedDescending && lastActivation!.compare(nightTime) == .orderedAscending {
            
            //eveningUpdateがnilならAPIを更新、nilでなければキャッシュの表示
            if eveningUpdate == nil {
                print("夕方のAPIの更新（日付変更以前）")
                
                eveningUpdate   = "eveningUpdate"
                afternoonUpdate = nil
            } else {
                print("キャッシュの表示")
            }
        }
        
        //00:00以降07:00以前の場合（日を跨いで初めて起動）
        else if lastActivation!.compare(lateAtNightTime) == .orderedDescending && lastActivation!.compare(morningTime) == .orderedAscending  {
            
            //lateAtNightTimeUpdateがnilならAPIを更新、nilでなければキャッシュの表示
            if lateAtNightTimeUpdate == nil {
                print("夕方のAPIの更新（日付変更以降）")
                
                lateAtNightTimeUpdate = "lateAtNightTimeUpdate"
                eveningUpdate         = nil
            } else {
                print("キャッシュの表示")
            }
        }
        
        //どの時間割にも当てはまらない場合
        else {
            print("キャッシュを表示しておく")
        }
    }
    
    // MARK: - LanguageTranslator
    func startTranslation() {
        
        //感情分析中であることをユーザーに伝える
        HUD.show(.labeledProgress(title: "Happyを分析中...", subtitle: nil))
        
        //XMLのニュースの順番と整合性を合わせるためreversedを使用。$iは合わせた番号の可視化（50 = first, 1 = last）
        for i in (1...50).reversed() {
            newsTextArray.append(newsItems[newsItems.count - i].title!.description + "$\(i)")
        }
        
        print("newsTextArray: \(newsTextArray.debugDescription)")
        
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
        
        //joyCountArrayの中身を検索し、一致 = 意図するニュースを代入
        for i in 0...joyCountArray.count - 1 {
            
            //'i' を使用したいが使用することで意図するニュースに相違が発生するのであえて冗長に
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    HUD.show(.label("分析が終了しました"))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
        
        //サムネイルのインスタンス(画像URL, 待機画像, 角丸）
        let thumbnailURL = URL(string: joySelectionArray[indexPath.row].image!.description)
        let placeholder  = UIImage(named: "placeholder")
        let cornerRadius = RoundCornerImageProcessor(cornerRadius: 20)
        
        //サムネイルの反映
        cell.imageView?.kf.setImage(with: thumbnailURL, placeholder: placeholder, options: [.processor(cornerRadius), .transition(.fade(0.2))])
        
        //サムネイルのサイズを統一（黄金比）
        cell.imageView?.image = cell.imageView?.image?.resize(_size: CGSize(width: 135, height: 85))
        
        //セルを化粧
        cell.backgroundColor = UIColor.white
        cell.textLabel?.text = newsItem.title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .medium)
        cell.textLabel?.textColor = UIColor(hex: "333")
        cell.textLabel?.numberOfLines = 2
        
        //空のセルを削除
        tableView.tableFooterView = UIView(frame: .zero)
        
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
        
        //WebViewのNavigationControllerを定義
        let webViewNavigation = UINavigationController(rootViewController: webViewController)
        
        //WebViewをフルスクリーンに
        webViewNavigation.modalPresentationStyle = .fullScreen
        
        //タップしたセルを検知
        let tapCell = joySelectionArray[indexPath.row]
        
        //検知したセルのurlを取得
        UserDefaults.standard.set(tapCell.url, forKey: "url")
        
        //webViewControllerへ遷移
        present(webViewNavigation, animated: true)
    }
}
