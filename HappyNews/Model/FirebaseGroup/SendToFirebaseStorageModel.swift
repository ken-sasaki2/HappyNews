//
//  SendToFirebaseStorageModel.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/06.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import Foundation
import FirebaseStorage

// ▼関係するclass
// SaveUserInformationViewController
// EditUserInfoViewController

// 値を返す
protocol DoneCatchUserImageProtocol {
    func catchUserImage(url: String)
}

// FirebaseStorageに画像データを送信する
class SendToFirebaseStorageModel {
    
    // プロトコルのインスタンス
    var doneCatchUserImageProtocol: DoneCatchUserImageProtocol?
    
    init() {
        
    }
    
    // アカウント画像のデータを送信する
    func sendUserImageData(data: Data) {
        
        // Data型で渡ってきた値をUIImage型に変換してインスタンス化
        let imageData = UIImage(data: data)
        
        // imageDataをjpegに圧縮
        let userImage = imageData?.jpegData(compressionQuality: 0.1)
        
        // FirebaseStorageのフォルダを作成（一意性）
        let imageDataReference = Storage.storage().reference().child("userImage").child("\(UUID().uuidString + String(DateItems.date.timeIntervalSince1970)).jpg")
        
        // jpegに変換した画像データをFirebaseStorageに保存
        imageDataReference.putData(userImage!, metadata: nil) {
            (metaData, error) in
            
            // エラー処理
            if error != nil {
                
                print(error.debugDescription)
                return
            }
            
            // エラーでなければFirebaseStorageからURL型で画像データを取得
            imageDataReference.downloadURL {
                (url, error) in
                
                // エラー処理
                if error != nil {
                    
                    print(error.debugDescription)
                    return
                }
                
                // プロトコルを用いてFirebaseStorageから返ってきたURLを返す
                self.doneCatchUserImageProtocol?.catchUserImage(url: url!.absoluteString)
            }
        }
    }
}
