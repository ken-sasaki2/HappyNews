//
//  SaveUserInformationViewController.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2021/02/05.
//  Copyright © 2021 佐々木　謙. All rights reserved.
//

import UIKit

// ユーザー情報(ユーザー名 & アカウント画像)を保存する
class SaveUserInformationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    // MARK: - Property
    // アカウント画像のインスタンス
    @IBOutlet weak var userImage: UIImageView!
    
    // ユーザー名入力Fieldのインスタンス
    @IBOutlet weak var userName: UITextField!
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // CheckPermissionクラスの呼び出し
        let checkPermission = CheckPermission()
            checkPermission.showCheckPermission()
        
        // アカウント画像の角丸
        userImage.layer.masksToBounds = false
        userImage.layer.cornerRadius = userImage.frame.width/2
        userImage.clipsToBounds = true
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
        print("アイコンをタップ")
        
        // アラートの表示
        showImageAlert()
    }
    
    
    // MARK: - TapSaveButton
    // 保存ボタンをタップすると呼ばれる
    @IBAction func tapSaveButton(_ sender: Any) {
        print("保存をタップ")
        
        // ユーザー名がnilでないかの確認
        
        // 登録を行う
        // - ユーザー画像
        // - ユーザー名
    }
}
