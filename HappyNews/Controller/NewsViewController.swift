//
//  ViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/08/13.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import SegementSlide

class NewsViewController: SegementSlideDefaultViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SegementSlideDefaultViewControllerの初期設定
        reloadData()
        defaultSelectedIndex = 0
    }
    
    //ニュースタブのコード
    override var titlesInSwitcher: [String] {
        
        return ["トップ","エンタメ","スポーツ","ビジネス","テクノロジー","経済","政治","国際","地域","グルメ","どうぶつ","アニメ","アプリ・ゲーム"]
    }

    //コントローラーを返すメソッド
    override func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {

        switch index {
        case 0:
            return TopNewsTableViewController()
        case 1:
            return EntameNewsTableViewController()
        case 2:
            return SuportsNewsTableViewController()
        case 3:
            return BusinessNewsTableViewController()
        case 4:
            return TechnologyNewsTableViewController()
        case 5:
            return KeizaiNewsTableViewController()
        case 6:
            return SeiziNewsTableViewController()
        case 7:
            return WorldNewsTableViewController()
        case 8:
            return TiikiTableViewController()
        case 9:
            return GourmetNewsTableViewController()
        case 10:
            return AnimalNewsTableViewController()
        case 11:
            return AnimationNewsTableViewController()
        case 12:
            return AppGameNewsTableViewController()
        default:
            return TopNewsTableViewController()
        }
    }
}

