![READMEヘッダ 001](https://user-images.githubusercontent.com/61372276/104112023-e9bbd680-532c-11eb-82d6-5f48a28df9e9.jpeg)

## アプリの概要
感情分析を使って明るいニュースをお届けしたり、ユーザーどうしで明るい投稿を共有できるアプリ  
[AppleStoreからインストール](https://apps.apple.com/us/app/happynews/id1554808732)

## 開発の経緯
2020年夏、新型コロナウイルスを筆頭にネガティブな情報ばかりを目にする日々が続きました。  
開発者はそんな日常に嫌気がさし、気落ちした日常を過ごしておりました。

また、この状態がこれからも続くことを問題と捉えるようになりました。

そこで、ネガティブな情報ではなく、ポジティブな明るい情報に触れ合う機会を増やすことができれば、  
現状よりも張りのある生活ができるのでは？と考えるようになり、  
プログラミングを通じてこの問題を解決しようと考えたのがHappyNews開発の経緯です。

## 機能一覧
・Sign In With Appleを用いたログイン機能 ＆ ログアウト機能  
・感情分析を用いたニュース表示機能  
・ニュースお気に入り機能  
・感情分析を用いたタイムライン投稿機能  
・コメント投稿機能  
・投稿削除 & ブロック機能  
・アカウント機能  
・通知機能  
・Twitterシェア機能  
・レビュー機能  
・お問い合わせ機能 & 通報機能（メール機能）  
・Twitter紹介機能（開発者）  
・利用規約機能

## 開発で使用した技術
![README技術 001](https://user-images.githubusercontent.com/61372276/104113183-702ae500-533a-11eb-884c-8d3d1a6848ec.jpeg)
### Swift version 5.3.2
・MVCモデル開発  
・XML解析  
・JSON解析  
・WebView  
・AutoLayout（コード & Storyboard）  
・Autoresizing
 
以下、使用したCocoaPodsとライブラリ
```
pod 'IBMWatsonToneAnalyzerV3', '~> 3.6.0'
pod 'IBMWatsonLanguageTranslatorV3', '~> 3.6.0'
pod 'SwiftyJSON'

pod 'Firebase'
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Storage'

pod 'PKHUD', '~> 5.0'
pod 'Kingfisher'
```

```
# ニュース機能で使用
import ToneAnalyzer
import LanguageTranslator
import SwiftyJSON
import Kingfisher

# ニュースお気に入り機能で使用
import Firebase
import FirebaseFirestore
import Kingfisher

# タイムライン & コメント投稿機能で使用
import Firebase
import FirebaseFirestore
import Kingfisher
import PKHUD
import MessageUI

# Sign In With Appleを含むアカウント機能で使用
import Firebase
import FirebaseAuth
import AuthenticationServices
import PKHUD
import CryptoKit

# WebViewで使用
import WebKit

# アカウントページで使用
import StoreKit
import MessageUI

# 通知機能で使用
import UserNotifications

# その他
import UIKit
import Foundation
```

###  IBM Watson API
・言語翻訳機能（LanguageTranslator）  
・感情分析機能（ToneAnalyzer）

### Firebase
・Sign In With Apple  
・Firestore  
・Firestorage

## 工夫したポイント
#### AppleStore審査にてリジェクト、その後の対応
AppleStoreへ公開申請を行いましたが、ガイドライン4.2.2に反するということで一度リジェクトされました。  
このガイドライン4.2.2というのは比較的抽象的な表現であり、レビュワーによって左右される項目であると私は捉えました。

対策を練り改めて申請するも同様にリジェクトされます。  
そこでガイドライン4.2.2を私なりに分解し、定義したところ、
『アプリにはユーザーが能動的に行動する要素がなく、アプリの活性化が期待できない。なので機能を追加して下さい。』
というガイドラインであるという定義に至った。

そこで、ユーザーが能動的かつ、アプリの活性化が期待できる機能として、
①ニュースのお気に入り機能、②感情分析を用いたタイムライン投稿 & コメント投稿機能(投稿削除 & ブロック機能含む)、  
主に以上2点の機能を追加しております。

結果、無事AppleStoreへの公開までやり切ることができ、ガイドライン4.2.2を私なりに噛み砕けたことは工夫の一つです。

## 今後の課題
#### テストコードの記述
XCTestを用いてテストコードの記述を試みましたが、難易度が高く現在保留としております。  
次のアクションは、2つのパターンを検討しております。 

① XCTestの基礎知識を『iOSアプリ開発自動テストの教科書〜』を使って身につける。  
その後、改めてHappyNewsのテストコードの実装に取り掛かるということ。

② **MagicPod**という自動テストをAIでおこなうツールを用いてアプリのテストを実施するということ。  
MagicPodは、note株式会社様や株式会社Gunosy様でも実用した事例が存在するツールなので、只今検討中であります。

## 機能の紹介
### ログインページ利用規約機能の紹介
![利用規約](https://user-images.githubusercontent.com/61372276/109376826-7edd5380-790a-11eb-8efa-8ec4f30d94cf.gif)

### ログインとユーザー情報登録機能の紹介
![ログインユーザー登録](https://user-images.githubusercontent.com/61372276/109377031-f5c71c00-790b-11eb-8f78-8084b7c3940b.gif)

### 感情分析画面の紹介
![ニュース読み込み](https://user-images.githubusercontent.com/61372276/109377079-52c2d200-790c-11eb-8c95-0b71c9a27813.gif)

### ニュースページの紹介
![ニュース表示](https://user-images.githubusercontent.com/61372276/109377168-eb595200-790c-11eb-8ed1-a2ab04cd5535.gif)

### ニュースお気に入り機能の紹介
![お気に入り](https://user-images.githubusercontent.com/61372276/109377239-61f64f80-790d-11eb-9b1f-4d3ff691f6b0.gif)

### タイムライン投稿機能の紹介
![タイムライン投稿](https://user-images.githubusercontent.com/61372276/109377326-f06ad100-790d-11eb-8897-918997a3e360.gif)

### タイムライン削除 & ブロック機能の紹介
![タイムライン削除](https://user-images.githubusercontent.com/61372276/109377374-4e97b400-790e-11eb-8f55-2adf3c2ccdfc.gif)

### コメント投稿 & 削除機能の紹介
![コメント投稿削除](https://user-images.githubusercontent.com/61372276/109377826-21003a00-7911-11eb-90b1-e7a296a038b6.gif)

### コメントブロック機能の紹介
![コメントブロック](https://user-images.githubusercontent.com/61372276/109377879-6d4b7a00-7911-11eb-969c-98b93a7797f8.gif)

### 通報機能の紹介
![通報機能](https://user-images.githubusercontent.com/61372276/109377481-0331d580-790f-11eb-8687-2eaf30977986.gif)

### アカウント情報編集機能の紹介
![アカウント編集](https://user-images.githubusercontent.com/61372276/109377427-ae8e5a80-790e-11eb-875d-486686e93027.gif)

### 通知設定機能の紹介
![通知機能](https://user-images.githubusercontent.com/61372276/109377536-615eb880-790f-11eb-91ee-b46282289780.gif)

### シェア機能の紹介
![シェア機能](https://user-images.githubusercontent.com/61372276/109377585-9703a180-790f-11eb-8d08-3379ba78d64d.gif)

### レビュー機能の紹介
![レビュー機能](https://user-images.githubusercontent.com/61372276/109377627-cf0ae480-790f-11eb-98f9-75b324beec60.gif)

### ご意見・ご要望機能の紹介
![ご意見](https://user-images.githubusercontent.com/61372276/109377670-1d1fe800-7910-11eb-871a-a39c3ca3f16f.gif)

### Twitter紹介機能の紹介
![Twitter紹介](https://user-images.githubusercontent.com/61372276/109377722-6ff99f80-7910-11eb-8d25-457b36a8aa25.gif)

### ログアウト機能の紹介
![ログアウト](https://user-images.githubusercontent.com/61372276/109377761-b8b15880-7910-11eb-9d74-2b6512e59917.gif)

## 開発者の連絡先
HappyNewsに関するご連絡はアカウントをフォローしていただき[Twitter](https://twitter.com/ken_sasaki2)のダイレクトメッセージにて連絡。  
もしくは、アプリ内の**ご意見・ご要望**からご連絡下さい。  
プルリクエストも大歓迎です。

▼その他連絡先  
[Qiita](https://qiita.com/nkekisasa222)  
[Github](https://github.com/ken-sasaki-222)
