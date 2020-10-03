//
//  ViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/03.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        
//        addNavigationBar()
//        addNavBackView()
//    }
//    
//    //ｎavigationBarを作る
//    func addNavigationBar() {
//        
//        //Navigatonbarのインスタンスを作成してviewに入れる
//        let navigationbar = UINavigationBar()
//        self.view.addSubview(navigationbar)
//        
//        //navigationbarの背景を設定
//        navigationbar.setBackgroundImage(UIImage(), for: .default)
//        
//        //navigationbarのサイズを条件分岐
//        if #available(iOS 11.0, *) {
//            
//            navigationbar.frame.origin = self.view.safeAreaLayoutGuide.layoutFrame.origin
//            
//            navigationbar.frame.size = CGSize(width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: 44)
//        } else {
//            
//            //もしもiOS11よりも下だったら
//            navigationbar.frame.origin  = self.view.frame.origin
//            navigationbar.frame.size = CGSize(width: self.view.frame.width, height: 44)
//        }
//    }
//    
//    //navigationViewを作る
//    func addNavBackView() {
//        
//        //背景用のviewのインスタンスを生成してviewに入れる
//        let navigationView = UIView()
//        self.view.addSubview(navigationView)
//        
//        //背景を設定
//        navigationView.backgroundColor = UIColor.green
//        
//        //navigationBarの背景のサイズと位置を調整
//        if #available(iOS 11.0, *) {
//            
//            navigationView.frame.origin = self.view.safeAreaLayoutGuide.owningView!.frame.origin
//            
//            navigationView.frame.size = CGSize(width: self.view.safeAreaLayoutGuide.owningView!.frame.width, height: navigationBar.frame.origin.y + navigationBar.frame.height)
//
//        } else {
//            
//            navigationView.frame.origin = self.view.frame.origin
//            
//            navigationView.frame.size = CGSize(width: self.view.frame.width, height: navigationBar.frame.origin.y + navigationBar
//                                                .frame.height)
//        }
//    }
}
