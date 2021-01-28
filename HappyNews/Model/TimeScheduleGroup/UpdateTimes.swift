//
//  UpdateTimes.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/01/24.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import Foundation

// ▼関係するclass
// DateItems
// TimeScheduleModel

// API通信をおこなう分岐時間をString型に変換
class UpdateTimes {
    
    // DateItems.dateFormatter = class DateItems参照
    // TimePoints.xxxxx = class TimePointsを参照し、API通信をおこなう分岐時間を定義
    static var morningTime     = DateItems.dateFormatter.string(from: TimePoints.morningPoint!)
    static var afternoonTime   = DateItems.dateFormatter.string(from: TimePoints.afternoonPoint!)
    static var eveningTime     = DateItems.dateFormatter.string(from: TimePoints.eveningPoint!)
    static var nightTime       = DateItems.dateFormatter.string(from: TimePoints.nightPoint!)
    static var lateAtNightTime = DateItems.dateFormatter.string(from: TimePoints.lateAtNightPoint!)
}
