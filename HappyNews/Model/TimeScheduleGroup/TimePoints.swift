//
//  TimePoints.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/01/24.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import Foundation

// ▼関係するclass
// DateItems
// UpdateTimes

// API通信をおこなう分岐時間を定義
class TimePoints {
    
    // DateItems.dateFormatter =  class DateItems参照
    static var morningPoint     = DateItems.dateFormatter.date(from: "07:00:00")
    static var afternoonPoint   = DateItems.dateFormatter.date(from: "11:00:00")
    static var eveningPoint     = DateItems.dateFormatter.date(from: "17:00:00")
    static var nightPoint       = DateItems.dateFormatter.date(from: "23:59:59")
    static var lateAtNightPoint = DateItems.dateFormatter.date(from: "00:00:00")
}
