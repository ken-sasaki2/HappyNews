//
//  DateItems.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/01/24.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import Foundation

// ▼関係するclass
// TimeScheduleModel
// NewsViewControler
// TimePoints
// UpdateTimes

// 上記classで現在時刻の取得やフォーマットの変換時に共通で扱う
class DateItems {
    static var date                = Date()
    static var dateFormatter       = DateFormatter()
    static var outputDateFormatter = DateFormatter()
}
