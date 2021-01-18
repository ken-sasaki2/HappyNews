//
//  AuthenticationModel.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/01/17.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import Foundation


// MARK: - Protosol
protocol DoneCatchAuthenticationItem {
    func catchAuthenticationItem(languageTranslatorItem: String, toneAnalyzerItem: String)
}

class AuthenticationModel {


    // MARK: - Property
    //NewsViewControllerから受け取る値
    var receiveAuthentication: String?
    
    //NewsViewControllerへ返す値
    var languageTranslatorItem: String?
    var toneAnalyzerItem      : String?
    
    //プロトコルのインスタンス
    var doneCatchAuthenticationItem: DoneCatchAuthenticationItem?

    //APIKeyリクエストを受け取る
    init(authenticationRequest: String?) {
        receiveAuthentication = authenticationRequest
    }
    
    func setAuthentication() {
        
        doneCatchAuthenticationItem?.catchAuthenticationItem(languageTranslatorItem: "J4LQkEl7BWhZL2QaeLzRIRSwlg4sna1J7-09opB-9Gqf", toneAnalyzerItem: "zxsrTapH91XqPW0usWcg2-g0s1sQ6fIo9A1eiVZVRFU7")
    }
}
