//
//  AnalyzerResult.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/25.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import Foundation

struct AnalyzerResult {
    
    var firstToneScore  : Float
    var firstScore      : Float
    var secondToneScore : Float
    var secondScore     : Float
    var firstToneName   : String
    var secondToneName  : String
    
    //構造体の初期化
    init(firstToneScore: Float, firstScore: Float, secondToneScore: Float, secondScore: Float, firstToneName:String, secondToneName: String) {
        
        self.firstToneScore  = firstToneScore
        self.firstScore      = firstScore
        self.secondToneScore = secondToneScore
        self.secondScore     = secondScore
        self.firstToneName   = firstToneName
        self.secondToneName  = secondToneName
        
    }
}
