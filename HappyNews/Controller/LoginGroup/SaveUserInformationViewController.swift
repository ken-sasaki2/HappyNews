//
//  SaveUserInformationViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/05.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PKHUD

// ユーザー情報(ユーザー名 & アカウント画像)を保存する
class SaveUserInformationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DoneCatchUserImageProtocol {

    
    // MARK: - Property
    // アカウント画像のインスタンス
    @IBOutlet weak var userImage: UIImageView!
    
    // SendToFirebaseStorageModelから返ってくる値を保存
    var userImageString: String?
    
    // ユーザー名入力Fieldのインスタンス
    @IBOutlet weak var userNameTextField: UITextField!
    
    // 登録ボタンのインスタンス
    @IBOutlet weak var registerButton: UIButton!
    
    // Firestoreのインスタンス
    var fireStoreDB = Firestore.firestore()
    
    // fireStoreDBのコレクション名が入る
    var roomName: String?
    
    // FirebaseStorageへ画像データを送信するクラスのインスタンス
    var sendToFirebaseStorageModel = SendToFirebaseStorageModel()
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
        // viewの背景色を設定
        view.backgroundColor = UIColor(hex: "f4f8fa")
        
        // アカウント画像の角丸
        userImage.layer.masksToBounds = false
        userImage.layer.cornerRadius = userImage.frame.width/2
        userImage.clipsToBounds = true
        
        // 登録ボタンの角丸
        registerButton.layer.cornerRadius = 6.0
        
        // プロトコルの委託
        sendToFirebaseStorageModel.doneCatchUserImageProtocol = self

        // カメラにアクセスするかどうかを促すクラスの呼び出し
        let checkPermission = CheckPermission()
            checkPermission.showCheckPermission()
    }
    
    
    // MARK: - LaunchCamera
    // カメラを立ち上げる
    func launchCamera() {
        
        // カメラのインスタンス
        let camera: UIImagePickerController.SourceType = .camera
        
        // カメラの利用が可能か確認
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let cameraPicker               = UIImagePickerController()
                cameraPicker.allowsEditing = true
                cameraPicker.sourceType    = camera
                cameraPicker.delegate      = self
            
            // カメラ起動
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - LaunchAlbum
    // アルバムを立ち上げる
    func launchAlbum() {
        
        let album: UIImagePickerController.SourceType = .photoLibrary
        
        // アルバムの利用が可能か確認
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let albumPicker               = UIImagePickerController()
                albumPicker.allowsEditing = true
                albumPicker.sourceType    = album
                albumPicker.delegate      = self
            
            // アルバムを開く
            self.present(albumPicker, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - ImagePickerController
    // カメラで撮影 or アルバムで選択をすると呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if info[.originalImage] as? UIImage != nil {
            
            let selectedImage = info[.originalImage] as! UIImage
            userImage.image = selectedImage
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    // アラートのキャンセルボタンをタップすると呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - ShowImageAlert
    // アラートを表示する
    func showImageAlert() {
        
        // アラートのインスタンス
        let alertController = UIAlertController(title: "選択", message: "どちらを使用しますか?", preferredStyle: .actionSheet)
        
        // カメラを選択した場合
        let selectCamera = UIAlertAction(title: "カメラ", style: .default) {
            (alert) in
            
            self.launchCamera()
        }
        
        // アルバムを選択した場合
        let selectAlbum = UIAlertAction(title: "アルバム", style: .default) {
            (alert) in
            
            self.launchAlbum()
        }
        
        // キャンセルを選択した場合
        let selectCancel = UIAlertAction(title: "キャンセル", style: .cancel)
        
        
        // 各アクションを追加してアラートを表示
        alertController.addAction(selectCamera)
        alertController.addAction(selectAlbum)
        alertController.addAction(selectCancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - TapUserImage
    // アカウント画像をタップすると呼ばれる
    @IBAction func tapUserImage(_ sender: Any) {
        
        // アラートの表示
        showImageAlert()
    }
    
    // MARK: - TapSaveButton
    // 登録ボタンをタップすると呼ばれる
    @IBAction func tapRegisterButton(_ sender: Any) {
        
        // ユーザー名とアカウント画像の両方を確認すると呼ばれる
        if userNameTextField.text?.isEmpty != true && userImage.image != nil  {
            
            // ユーザー名の保存
            UserDefault.standard.set(userNameTextField.text, forKey: "userName")
            
            // UIImage型をData型に変換してインスタンス化
            let data = userImage.image!.jpegData(compressionQuality: 1.0)
            
            // sendToFirebaseStorageModelにアカウント画像を渡す
            self.sendToFirebaseStorageModel.sendUserImageData(data: data!)
            
            // 非同期でUIを更新
            DispatchQueue.main.async {
                
                // fireStoreDBへの保存を終えたらtextFieldを空にしてキーボードを閉じる
                self.userNameTextField.text = ""
                self.userNameTextField.resignFirstResponder()
            }
        } else {
            
            // ユーザーに制約を知らせるアラートの設定
            let registerAlert = UIAlertController(title: "登録失敗", message: "アカウント画像とユーザー名の両方が必要です。", preferredStyle: .alert)
            
            // アラートのボタン
            registerAlert.addAction(UIAlertAction(title: "やり直す", style: .default))
            
            // アラートの表示
            present(registerAlert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - CatchUserImage
    // SendToFirebaseStorageModelから値を受け取って画面遷移
    func catchUserImage(url: String) {
        
        // fireStoreDBのコレクション名
        roomName = "users"
        
        // アカウント登録作成日時を定義
        let nowCreate = Date()
        
        // 地域とフォーマットを指定
        DateItems.dateFormatter.locale = Locale(identifier: "ja_JP")
        DateItems.dateFormatter .dateFormat = "yyyy年M月d日(EEEEE) H時m分s秒"
        
        // 一度String型に変換してDate型に変換
        let createTimeString = DateItems.dateFormatter.string(from: nowCreate)
        let createdTime      = DateItems.dateFormatter.date(from: createTimeString)
        
        // 1. userName
        // 2. userImage
        // 3. sender(uid)
        // 4. createdTime
        // 計4点をfireStoreDBに保存して成功すれば遷移
        if let sender = Auth.auth().currentUser?.uid, let userName = UserDefault.getUserName {
            
            self.fireStoreDB.collection(self.roomName!).document(sender).setData(
                ["userName"   : userName,
                 "userImage"  : url,
                 "sender"     : sender,
                 "createdTime": createdTime]) {
                error in
                
                // エラー処理
                if error != nil {
                    
                    print("Message save error: \(error.debugDescription)")
                    return
                }
                
                HUD.flash(.labeledSuccess(title: "登録完了", subtitle: nil), onView: self.view, delay: 0) { _ in
                    // segueで画面遷移
                    self.performSegue(withIdentifier: "mainPage", sender: nil)
                }
            }
        }
    }
    
    
    // MARK: - TouchesBegan
    // viewタップでキーボードを閉じる（textField）
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
