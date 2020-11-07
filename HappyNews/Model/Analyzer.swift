//
//  AnalyzerResult.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/25.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import Foundation

struct Analyzer {
    
    var toneScore : Float?
    var toneName  : String?
    
    //構造体の初期化
    init(toneScore: Float?, toneName: String?) {
        self.toneScore = toneScore
        self.toneName  = toneName
    }
}
