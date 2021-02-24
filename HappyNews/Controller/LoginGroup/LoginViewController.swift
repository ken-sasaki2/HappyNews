//
//  LoginViewController.swift
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

// ログイン画面のUIとSignInWithAppleを設定
class LoginViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    
    // MARK: - Property
    // 認証リクエスト時に必要
    var currentNonce: String?

    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        // viewの背景を設定
        view = UIView()
        view.backgroundColor = UIColor(hex: "f4f8fa")
        
        // アプリのタイトルテキストの表示
        appTitleText()
        
        // ログイン案内テキストの表示
        signInGuideText()
        
        // 利用規約ボタンの表示
        termsOfUseText()
        
        // Sign In With Appleの呼び出し
        createSignInWithApple()
    }
    
    
    // MARK: - AppTitleText
    // アプリのタイトルテキスト
    func appTitleText() {
        
        let appTitle = UILabel()
        
        // 'Autosizing'を'AutoLayout'に変換
        appTitle.translatesAutoresizingMaskIntoConstraints = false
        
        // テキストの内容とフォントと色を設定し、中央揃えにしてviewに反映
        appTitle.text = "HappyNews"
        appTitle.font = UIFont.systemFont(ofSize: 56, weight: .bold)
        appTitle.textColor = UIColor(hex: "00AECC")
        appTitle.backgroundColor = UIColor.clear
        appTitle.textAlignment = NSTextAlignment.center
        view.addSubview(appTitle)
            
        // appTitleのY軸のAutoLayoutを設定
        let appTitleTopConstraint = NSLayoutConstraint(item: appTitle, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 170)
        
        // appTitleのX軸のAutoLayoutを設定
        let appTitleLeadingConstraint = NSLayoutConstraint(item: appTitle, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: self.view.frame.maxX/2)
        
        // appTitleの幅を設定
        let appTitleWidthConstraint = NSLayoutConstraint(item: appTitle, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.0, constant: 0)
        
        // AutoLayoutを反映
        self.view.addConstraint(appTitleTopConstraint)
        self.view.addConstraint(appTitleLeadingConstraint)
        self.view.addConstraint(appTitleWidthConstraint)
    }
    
    
    // MARK: - SignInGuideText
    // ログイン案内のテキスト
    func signInGuideText() {
        
        let signInGuide = UILabel()
        
        // 'Autosizing'を'AutoLayout'に変換
        signInGuide.translatesAutoresizingMaskIntoConstraints = false
        
        // テキストの内容とフォントと色を設定し、3行で中央揃えにしてviewに反映
        signInGuide.text = "ログインしてユーザー名と \n アカウント画像を設定しよう"
        signInGuide.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        signInGuide.textColor = UIColor(hex: "333333")
        signInGuide.backgroundColor = UIColor.clear
        signInGuide.numberOfLines = 3
        signInGuide.textAlignment = NSTextAlignment.center
        view.addSubview(signInGuide)
        	
        // signInGuideのY軸のAutoLayoutを設定
        let signInGuideTopConstraint = NSLayoutConstraint(item: signInGuide, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 340)
        
        // signInGuideのX軸のAutoLayoutを設定
        let signInGuideLeadingConstraint = NSLayoutConstraint(item: signInGuide, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: self.view.frame.maxX/2)
        
        // signInGuideの幅を設定
        let signInGuideWidthConstraint = NSLayoutConstraint(item: signInGuide, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.0, constant: 0)
        
        // AutoLayoutを反映
        self.view.addConstraint(signInGuideTopConstraint)
        self.view.addConstraint(signInGuideLeadingConstraint)
        self.view.addConstraint(signInGuideWidthConstraint)
    }
    
    
    // MARK: - TermsOfUseButton
    // 利用規約へ遷移するボタンの作成
    func termsOfUseText() {
        
        // ボタンのタイプとデザインを設定
        let termsOfUseButton = UIButton()
        
        // 'Autosizing'を'AutoLayout'に変換
        termsOfUseButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 利用規約ボタンを化粧
        termsOfUseButton.backgroundColor  = UIColor.clear
        termsOfUseButton.setTitle("利用規約", for: UIControl.State.normal)
        termsOfUseButton.setTitleColor(UIColor.link, for: .normal)
        termsOfUseButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        // ボタンがタップされた時の挙動を記述してviewに反映
        termsOfUseButton.addTarget(self, action: #selector(tapTermsOfUseButton(_:)), for: .touchUpInside)
        view.addSubview(termsOfUseButton)
        
        // appleButtonのY軸のAutoLayoutを設定
        let termsOfUseButtonTopConstraint = NSLayoutConstraint(item: termsOfUseButton, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 480)
        
        // appleButtonのX軸のAutoLayoutを設定
        NSLayoutConstraint.activate([termsOfUseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        
        // appleButtonの高さを設定
        termsOfUseButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        // appleButtonの幅を設定
        let termsOfUseButtonWidthConstraint = NSLayoutConstraint(item: termsOfUseButton, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.2, constant: 0)
        
        // AutoLayoutを反映
        self.view.addConstraint(termsOfUseButtonTopConstraint)
        self.view.addConstraint(termsOfUseButtonWidthConstraint)
    }
    
    
    // MARK: - Sign In With Apple
    // Sign In With Appleボタンの作成
    func createSignInWithApple() {
        
        // ボタンのタイプとデザインを設定
        let appleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
        
        // 'Autosizing'を'AutoLayout'に変換
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        
        // appleButtonの角丸
        appleButton.cornerRadius = 6.0
        
        // ボタンがタップされた時の挙動を記述してviewに反映
        appleButton.addTarget(self, action: #selector(loginTap), for: .touchUpInside)
        view.addSubview(appleButton)
        
        // appleButtonのY軸のAutoLayoutを設定
        let appleButtonTopConstraint = NSLayoutConstraint(item: appleButton, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 420)
        
        // appleButtonのX軸のAutoLayoutを設定
        NSLayoutConstraint.activate([appleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        
        // appleButtonの高さを設定
        appleButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        // appleButtonの幅を設定
        let appleButtonWidthConstraint = NSLayoutConstraint(item: appleButton, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.8, constant: 0)
        
        // AutoLayoutを反映
        self.view.addConstraint(appleButtonTopConstraint)
        self.view.addConstraint(appleButtonWidthConstraint)
    }
    
    
    // MARK: - TapTermsOfUseButton
    // 利用規約ボタンをタップすると遷移する
    @objc func tapTermsOfUseButton(_ sender: Any) {
        
        // WebViewControllerのインスタンス作成
        let termsOfUseViewController = TermsOfUseViewController()

        // WebViewのNavigationControllerを定義
        let termsOfUseViewNavigation = UINavigationController(rootViewController: termsOfUseViewController)

        // WebViewをフルスクリーンに
        termsOfUseViewNavigation.modalPresentationStyle = .fullScreen

         // 利用規約のリンク
        let termsOfUseLink = "https://peraichi.com/landing_pages/view/happynews"

        // 検知したセルのurlを取得
        UserDefault.standard.set(termsOfUseLink, forKey: "termsOfUseLink")
        
        // WebViewControllerへ遷移
        performSegue(withIdentifier: "termsOfUse", sender: nil)
    }
    
    
    // MARK: - LoginTap
    // Sign In With Appleをタップすると呼ばれる
    @objc func loginTap() {
        
        // nonce = リプレイ攻撃を防ぐ変数
        let nonce = randomNonceString()
        
        // currentNonce = 現在のnonce
        currentNonce = nonce
        let request = ASAuthorizationAppleIDProvider().createRequest()
            request.nonce = sha256(nonce)
        
        // Appleが認証済みかどうかのリクエストを投げる
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        // delegateを委託
        controller.delegate = self
        controller.presentationContextProvider = self
        
        // ここでリクエストを投げる
        controller.performRequests()
    }
    
    
    // MARK: - Setting Sign In With Apple
    // appleIDCredential, credentials, nonce, appleIDToken, idTokenString
    // 上記5点が存在するかどうかの確認をおこなう
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

    // リプレイ攻撃(サイバーテロ？)防止②
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
        
        // credential = ()内の値を元にサインインがおこなわれる
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        
        // Firebaseへのログイン
        Auth.auth().signIn(with: credential) {
            (authResult, error) in
            
            // 認証失敗の場合
            if let error = error {
                print(error)
                HUD.flash(.labeledError(title: "予期せぬエラーが発生", subtitle: "もう一度お試しください。"), delay: 0)
                return
            }
            
            // 認証成功の場合
            if let authResult = authResult {
                
                HUD.flash(.labeledSuccess(title: "ログイン完了", subtitle: nil), onView: self.view, delay: 0) { _ in
                    
                    // uidをインスタンス化して保存
                    let uid = Auth.auth().currentUser?.uid
                    UserDefault.standard.set(uid, forKey: "uid")
                    
                    // segueで画面遷移
                    self.performSegue(withIdentifier: "nextSaveUser", sender: nil)
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
}
