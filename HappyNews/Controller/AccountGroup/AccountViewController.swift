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
    
    //この後やること
    //・全ての端末でbtnを画面中央に配置 ✔︎
    //・Sign In With Appleのサイズ調整 ✔︎
    //・日本語表記に変更
    //・アカウントページに必要なUI作成
    //→ログイン前はログインボタンの表示、ログイン後はログアウトボタンの表示、ログインすると通知を受け取れる説明

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UIviewのインスタンス作成(view)
        view = UIView()

        //viewの背景を設定
        view.backgroundColor = .white
        
        //通知を管理するオブジェクト
        let authOption: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOption) { (_, _) in
            print("success: Push notification OK")
        }

        //NavigationBarの呼び出し
        setAccountNavigationBar()
        
        //Sign In With Appleの呼び出し
        createSignInWithApple()
    }
    
    func createSignInWithApple() {
        
        //ボタンのタイプとデザインを設定
        let appleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
        
        //'Autosizing'を'AutoLayout' に変換
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        
        //ボタンがタップされた時の挙動を記述してviewに反映
        appleButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
        view.addSubview(appleButton)
        
        //ボタンのサイズを設定
        appleButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
        appleButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //全機種で画面中央に配置
        NSLayoutConstraint.activate([appleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                     appleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
    }
    
    //'Sign In With Apple'をタップすると呼ばれる
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
                HUD.flash(.labeledError(title: "予期せぬエラーが発生", subtitle: "もう一度お試しください。"), delay: 0)
                return
            }
            if let authResult = authResult {
                
                HUD.flash(.labeledSuccess(title: "ログイン完了", subtitle: nil), onView: self.view, delay: 0) { _ in
                    
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
