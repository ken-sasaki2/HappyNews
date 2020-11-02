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
        defaultSelectedIndex = 0
        reloadData()
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

