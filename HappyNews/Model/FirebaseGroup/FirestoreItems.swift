//
//  FirestoreItems.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/06.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import Foundation
import Firebase

// ▼関係するclass
// ChatViewController
// SaveUserInformationViewController

// 上記クラスで扱うFirestoreのインスタンス
class FirestoreItems {
    
   static var fireStoreDB = Firestore.firestore()
}
