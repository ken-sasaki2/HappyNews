//
//  ViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/08/13.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import SegementSlide

//16進数color 機能拡張
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let v = Int("000000" + hex, radix: 16) ?? 0
        let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
        let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
        let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }
}

class NewsViewController: SegementSlideDefaultViewController {
    
    //テスト

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NavigationBarの呼び出し
        setNewsNavigationBar()
        scrollViewDidScroll(scrollView)
        
        //SegementSlideDefaultViewControllerの初期設定
        defaultSelectedIndex = 0
        reloadData()
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
        
        //NavigationBarの下線を消す
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    //スクロールでナビゲーションバーを隠す
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    //ニュースタブのコード
    override var titlesInSwitcher: [String] {
        
        return ["社会","スポーツ","エンタメ","ビジネス・経済","IT・化学"]
    }

    //コントローラーを返すメソッド
    override func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {

        switch index {
        case 0:
            return TopNewsTableViewController()
        case 1:
            return SuportsNewsTableViewController()
        case 2:
            return EntameNewsTableViewController()
        case 3:
            return BusinessNewsTableViewController()
        case 4:
            return TechnologyNewsTableViewController()
        default:
            return TopNewsTableViewController()
        }
    }
}

