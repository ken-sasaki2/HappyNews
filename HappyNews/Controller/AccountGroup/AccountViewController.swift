//
//  SearchViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/10/02.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import UIKit
import AuthenticationServices
import CryptoKit
import Firebase
import PKHUD
import FirebaseAuth

class AccountViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    //認証リクエスト時に必要
    var currentNonce: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //通知を管理するオブジェクト
        let authOption: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOption) { (_, _) in
            print("success: Push notification OK")
        }
        
        //'AppleLogin'ボタンの作成,ボタンのタイプとデザインを設定
        let appleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
        
        //'AppleLogin'ボタンの配置場所の設定
        appleButton.frame = CGRect(x: 56, y: 395, width: 264, height: 50)
        
        //'AppleLogin'ボタンがタップされた時の挙動を記述してviewに反映
        appleButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
        view.addSubview(appleButton)
        
        //NavigationBarの呼び出し
        setAccountNavigationBar()
    }
    
    //'AppleLogin'ボタンをタップすると呼ばれる
    @objc func tap() {
        
        //nonce = リプレイ攻撃を防ぐ変数
        let nonce = randomNonceString()
        
        //currentNonce = 現在のnonce
        currentNonce = nonce
        let request = ASAuthorizationAppleIDProvider().createRequest()
            request.nonce = sha256(nonce)
        
        //Appleが認証済みかどうかのリクエストを投げる
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        //delegateを委託
        controller.delegate = self
        controller.presentationContextProvider = self
        
        //ここでリクエストを投げる
        controller.performRequests()
    }
    
    //appleIDCredential, credentials, nonce, appleIDToken, idTokenString
    //以上5点が存在するかどうかの確認をおこなう
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    //リプレイ攻撃(サイバーテロ？)防止②
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            break
        default:
            break
        }
        
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
        }
        
        //credential = （ ）内の値を元にサインインがおこなわれる
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        
        //Firebaseへのログインを
        Auth.auth().signIn(with: credential) { (authResult, error) in
            
            //エラー処理
            if let error = error {
                print(error)
                HUD.flash(.labeledError(title: "Unexpected errors", subtitle: "Try again."), delay: 0)
                return
            }
            if let authResult = authResult {
                
                HUD.flash(.labeledSuccess(title: "Login Completed", subtitle: nil), onView: self.view, delay: 0) { _ in
                    
                    self.performSegue(withIdentifier: "next", sender: nil)
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("error",error)
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    //アカウントページのNavigationBar設定
    func setAccountNavigationBar() {
        
        //NavigationBarのtitleとその色とフォント
        navigationItem.title = "アカウント"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20.0)]
        
        //NavigationBarの色
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "ffa500")
        
        //一部NavigationBarがすりガラス？のような感じになるのでfalseで統一
        self.navigationController?.navigationBar.isTranslucent = false
        
        //NavigationBarの下線を消す
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
}
