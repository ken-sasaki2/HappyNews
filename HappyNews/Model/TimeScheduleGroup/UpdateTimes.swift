//
//  UpdateTimes.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/01/24.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import Foundation

//定時時刻の変換
class UpdateTimes {
    
   static var morningTime     = DateItems.dateFormatter.string(from: TimePoints.morningPoint!)
   static var afternoonTime   = DateItems.dateFormatter.string(from: TimePoints.afternoonPoint!)
   static var eveningTime     = DateItems.dateFormatter.string(from: TimePoints.eveningPoint!)
   static var nightTime       = DateItems.dateFormatter.string(from: TimePoints.nightPoint!)
   static var lateAtNightTime = DateItems.dateFormatter.string(from: TimePoints.lateAtNightPoint!)
}
