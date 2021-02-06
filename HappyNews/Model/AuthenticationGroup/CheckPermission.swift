//
//  CheckPermission.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/06.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import Foundation
import Photos

// カメラにアクセスするかどうかを促す
class CheckPermission {
        
    func showCheckPermission() {
        
        PHPhotoLibrary.requestAuthorization {
            (status) in
            
            // 取得したstatusで分岐
            switch status {
            
            // 許可されている場合
            case .authorized:
                print("PhotoLibrary.request: authorized")
            
            // 拒否した場合
            case .denied:
                print("PhotoLibrary.request: denied")
            
            // 不確定の場合
            case .notDetermined:
                print("PhotoLibrary.request: notDetermined")
            
            // 制限されている場合
            case .restricted:
                print("PhotoLibrary.request: restricted")
            
            case .limited:
                print("PhotoLibrary.request: limited")
            @unknown default:
                break
            }
        }
    }
}
