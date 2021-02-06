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
    
    // fireStoreDBのコレクション名が入る
    var roomName: String?
    
    // FirebaseStorageへ画像データを送信するクラスのインスタンス
    var sendToFirebaseStorageModel = SendToFirebaseStorageModel()
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ダークモード適用を回避
        self.overrideUserInterfaceStyle = .light
        
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
        
        // fireStoreDBのコレクションを指定して解析
        roomName = "userName"
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
        
        // ユーザー名とアカウント画像がnilでなければ呼ばれる
        if userNameTextField.text?.isEmpty != true, let userImageValue = userImage.image {
            
            FirestoreItems.fireStoreDB.collection(roomName!).addDocument(data: ["userName": userNameTextField.text]) {
                error in
                
                // エラー処理
                if error != nil {
                    
                    print("Message save error: \(error.debugDescription)")
                    return
                }
                
                // UIImage型をData型に変換してインスタンス化
                let data = userImageValue.jpegData(compressionQuality: 1.0)
                
                // sendToFirebaseStorageModelにアカウント画像を渡す
                self.sendToFirebaseStorageModel.sendUserImageData(data: data!)
                
                // 非同期でUIを更新
                DispatchQueue.main.async {
                    
                    // fireStoreDBへの保存を終えたらtextFieldを空にしてキーボードを閉じる
                    self.userNameTextField.text = ""
                    self.userNameTextField.resignFirstResponder()
                }
            }
        } else {
            
            print("User name is empty")
        }
    }
    
    
    // MARK: - CatchUserImage
    // SendToFirebaseStorageModelから値を受け取って画面遷移
    func catchUserImage(url: String) {
        
        // 返ってきた値をインスタンス化
        userImageString = url
        print("userImageString: \(userImageString)")
        
        if userImageString != nil {
            
            HUD.flash(.labeledSuccess(title: "登録完了", subtitle: nil), onView: self.view, delay: 0) { _ in
                
                // segueで画面遷移
                self.performSegue(withIdentifier: "mainPage", sender: nil)
            }
        }
    }
}
