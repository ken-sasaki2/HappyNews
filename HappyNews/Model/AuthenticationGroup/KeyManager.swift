//
//  KeyManager.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/01/19.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import Foundation

//apiKey.plistから値を取得する構造体
struct KeyManager {

    //ファイル名と拡張子を指定してAPIKeyの保管場所を特定
    private let keyFilePath = Bundle.main.path(forResource: "apiKey", ofType: "plist")

    //特定した保管場所を'getValue'に渡す
    func getKeys() -> NSDictionary? {
        guard let keyFilePath = keyFilePath else {
            return nil
        }
        return NSDictionary(contentsOfFile: keyFilePath)
    }

    //APIKeyを返すメソッド
    func getValue(key: String) -> AnyObject? {
        guard let keys = getKeys() else {
            return nil
        }
        return keys[key]! as AnyObject
    }
}
