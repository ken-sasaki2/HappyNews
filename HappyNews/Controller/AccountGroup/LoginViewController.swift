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

class LoginViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    
    //MARK: - Property
    //認証リクエスト時に必要
    var currentNonce: String?

    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        //UIviewのインスタンス作成(view)
        view = UIView()

        //viewの背景を設定
        view.backgroundColor = UIColor(hex: "ffffff")
        
        //通知を管理するオブジェクト
        let authOption: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOption) { (_, _) in
            print("success: Push notification OK")
        }

        //NavigationBarの呼び出し
        setAccountNavigationBar()
        
        //ログイン案内テキストの表示
        signInGuideText()
        
        //Sign In With Appleの呼び出し
        createSignInWithApple()
        
        //キャンセルボタンの呼び出し
        createLoginCancelButton()
    }
    
    
    // MARK: - Navigation
    //アカウントページのNavigationBar設定
    func setAccountNavigationBar() {
        
        //NavigationBarのtitleとその色とフォント
        navigationItem.title = "ログインページ"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19, weight: .semibold)]
        
        //NavigationBarの色
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "00AECC")
        
        //一部NavigationBarがすりガラス？のような感じになるのでfalseで統一
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    
    // MARK: - SignInGuideText
    //'Sign In With Apple'上のテキスト
    func signInGuideText() {
        
        let signInGuide = UILabel()
        
        //'Autosizing'を'AutoLayout' に変換
        signInGuide.translatesAutoresizingMaskIntoConstraints = false
        
        //テキストの内容とフォントと色を設定し、中央揃えにしてviewに反映
        signInGuide.text = "ログインして通知設定を保存しましょう。"
        signInGuide.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        signInGuide.textColor = UIColor(hex: "333333")
        signInGuide.backgroundColor = UIColor.clear
        signInGuide.textAlignment = NSTextAlignment.center
        view.addSubview(signInGuide)
        	
        //signInGuideのY軸のAutoLayoutを設定
        let signInGuideTopConstraint = NSLayoutConstraint(item: signInGuide, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 27)
        
        //signInGuideのX軸のAutoLayoutを設定
        let signInGuideLeadingConstraint = NSLayoutConstraint(item: signInGuide, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: self.view.frame.maxX/2)
        
        //signInGuideの幅を設定
        let signInGuideWidthConstraint = NSLayoutConstraint(item: signInGuide, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.0, constant: 0)
        
        //AutoLayoutを反映
        self.view.addConstraint(signInGuideTopConstraint)
        self.view.addConstraint(signInGuideLeadingConstraint)
        self.view.addConstraint(signInGuideWidthConstraint)
    }
    
    
    // MARK: - Sign In With Apple
    //'Sign In With Apple' ボタンの作成
    func createSignInWithApple() {
        
        //ボタンのタイプとデザインを設定
        let appleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
        
        //'Autosizing'を'AutoLayout' に変換
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        
        //appleButtonの角丸
        appleButton.cornerRadius = 6.0
        
        //ボタンがタップされた時の挙動を記述してviewに反映
        appleButton.addTarget(self, action: #selector(loginTap), for: .touchUpInside)
        view.addSubview(appleButton)
        
        //appleButtonのY軸のAutoLayoutを設定
        let appleButtonTopConstraint = NSLayoutConstraint(item: appleButton, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 67)
        
        //appleButtonのX軸のAutoLayoutを設定
        NSLayoutConstraint.activate([appleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        
        //appleButtonの高さを設定
        appleButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        //appleButtonの幅を設定
        let appleButtonWidthConstraint = NSLayoutConstraint(item: appleButton, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.8, constant: 0)
        
        //AutoLayoutを反映
        self.view.addConstraint(appleButtonTopConstraint)
        self.view.addConstraint(appleButtonWidthConstraint)
    }
    
    
    // MARK: - CreateLoginCancelButton
    //ログインキャンセルボタンの作成
    func createLoginCancelButton() {
        
        //インスタンス作成
        let cancelButton = UIButton()
        
        //'Autosizing'を'AutoLayout' に変換
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        //cancelButtonのテキストとサイズ
        cancelButton.setTitle("キャンセル", for: UIControl.State.normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        
        //cancelButtonの文字色と背景色
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.backgroundColor = UIColor.gray
        
        //cancelButtonの角丸
        cancelButton.layer.cornerRadius = 6.0
        
        //cancelButtonのアクションとviewに反映
        cancelButton.addTarget(self, action: #selector(cancelTap), for: .touchUpInside)
        view.addSubview(cancelButton)

        //cancelButtonのy軸（縦）のAutoLayoutを設定
        let cancelButtonTopConstraint = NSLayoutConstraint(item: cancelButton, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 127)

        //cancelButtonのx軸（横）のAutoLayoutを設定
        NSLayoutConstraint.activate([cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)])

        //cancelButtonの高さを設定
        cancelButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        //cancelButtonの幅を設定
        let cancelButtonWidthConstraint = NSLayoutConstraint(item: cancelButton, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.8, constant: 0)

        //AutoLayoutを反映
        self.view.addConstraint(cancelButtonTopConstraint)
        self.view.addConstraint(cancelButtonWidthConstraint)
    }
    
    
    // MARK: - LoginTap
    //'Sign In With Apple'をタップすると呼ばれる
    @objc func loginTap() {
        
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
    
    
    // MARK: - CancelTap
    //キャンセルボタンをタップすると呼ばれる
    @objc func cancelTap() {
        
        //タブバーのインスタンスを取得
        if let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
            
            //ニュースタブを選択状態にする（0が一番左）
            DispatchQueue.main.async {
                tabBarController.selectedIndex = 0
            }
        }
        //モーダル画面を閉じる
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Setting Sign In With Apple
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
                    
                    self.dismiss(animated: true, completion: nil)
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
