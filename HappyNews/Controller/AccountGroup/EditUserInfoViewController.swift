//
//  EditUserInfoViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/07.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit
import Kingfisher
import PKHUD

// アカウント情報を編集するクラス
class EditUserInfoViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, DoneCatchUserImageProtocol {
    
    
    // MARK: - Property
    // アカウント情報編集用のインスタンス
    @IBOutlet weak var editUserImage: UIImageView!
    
    // ユーザー名編集用TextFireldのインスタンス
    @IBOutlet weak var editUserNameTextField: UITextField!
    
    // アカウント情報更新用ボタンのインスタンス
    @IBOutlet weak var editUpdateButton: UIButton!
    
    // AccountViewControllerから値を受け取る
    var getUserImage: String?
    var getUserName : String?
    
    // FirebaseStorageへ画像データを送信するクラスのインスタンス
    var sendToFirebaseStorageModel = SendToFirebaseStorageModel()
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // プロトコルの委託
        sendToFirebaseStorageModel.doneCatchUserImageProtocol = self
        
        // アカウント画像の角丸
        editUserImage.layer.masksToBounds = false
        editUserImage.layer.cornerRadius = editUserImage.frame.width/2
        editUserImage.clipsToBounds = true
        
        // 登録ボタンの角丸
        editUpdateButton.layer.cornerRadius = 6.0
        
        // Navigationbarの呼び出し
        setEditPageNavigationBar()
    }
    
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ユーザー情報編集ページではTabBarを非表示するように設定
        self.tabBarController?.tabBar.isHidden = true
        
        // アカウント名のデフォルト値
        editUserNameTextField.text = getUserName
        
        // アカウント画像のデフォルト値
        editUserImage.kf.setImage(with: URL(string: getUserImage!))
    }
    
    
    // MARK: - Navigation
    // ニュースページのNavigationBarを設定
    func setEditPageNavigationBar() {
        
        // NavigationBarのタイトルとその色とフォント
        navigationItem.title = "アカウント情報編集"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19.0, weight: .semibold)]
        
        // NavigationBarの色
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "00AECC")
        
        // 一部NavigationBarがすりガラス？のような感じになるのでfalseで統一
        self.navigationController?.navigationBar.isTranslucent = false
        
        // NavigationBarの下線を削除
        self.navigationController?.navigationBar.shadowImage = UIImage()
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
            editUserImage.image = selectedImage
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
    // 編集用アカウント画像をタップすると呼ばれる
    @IBAction func tapeditUserImage(_ sender: Any) {
        
        // アラートの表示
        showImageAlert()
    }
    
    
    // MARK: - TapEditUpdateButton
    // 更新ボタンをタップすると呼ばれる
    @IBAction func tapEditUpdateButton(_ sender: Any) {
        
        // ユーザーに制約を知らせるアラートの設定
        let updateAlert = UIAlertController(title: "確認", message: "アカウント情報を変更しますか？", preferredStyle: .alert)
        
        // アラートのボタン
        updateAlert.addAction(UIAlertAction(title: "はい", style: .default, handler: {
            action in
            
            // ユーザー名の保存
            UserDefault.standard.set(self.editUserNameTextField.text, forKey: "userName")
            
            // UIImage型をData型に変換してインスタンス化
            let editData = self.editUserImage.image!.jpegData(compressionQuality: 1.0)
            
            // sendToFirebaseStorageModelにアカウント画像を渡す
            self.sendToFirebaseStorageModel.sendUserImageData(data: editData!)
        }))
        updateAlert.addAction(UIAlertAction(title: "いいえ", style: .destructive))
        
        // アラートの表示
        present(updateAlert, animated: true, completion: nil)
    }
    
    
    // MARK: - CatchUserImage
    // SendToFirebaseStorageModelから値を受け取って画面遷移で値を渡す
    func catchUserImage(url: String) {
        
        if url != nil {
            
            HUD.flash(.labeledSuccess(title: "変更完了", subtitle: nil), onView: self.view, delay: 0) { [self] _ in
                
                // NavigationControllerをインスタンス化
                let navigationVC = self.navigationController
                
                // 一つ前のViewControllerを取得する
                let accountVC = navigationVC?.viewControllers[(navigationVC?.viewControllers.count)!-2] as! AccountViewController
                
                // 値を渡す
                accountVC.setEditUserInfo(EditUserImage: url, EditUserName: editUserNameTextField.text!)
                
                // アカウントページへ遷移(戻る)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - TouchesBegan
    // viewタップでキーボードを閉じる（textField）
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
