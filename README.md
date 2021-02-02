![READMEヘッダ 001](https://user-images.githubusercontent.com/61372276/104112023-e9bbd680-532c-11eb-82d6-5f48a28df9e9.jpeg)

## アプリの概要
感情分析を使って明るいニュースだけをお届けするニュースアプリ

## 開発の経緯
2020年夏、新型コロナウイルスを筆頭にネガティブな情報ばかりを目にする日々が続きました。  
開発者はそんな日常に嫌気がさし、気落ちした日常を過ごしておりました。

また、この状態がこれからも続くことを問題と捉えるようになりました。

そこで、ネガティブな情報ではなく、ポジティブな明るい情報に触れ合う機会を増やすことができれば、  
現状よりも張りのある生活ができるのでは？と考えるようになり、  
プログラミングを通じてこの問題を解決しようと考えたのがHappyNews開発の経緯です。

## 機能一覧
・ニュース表示機能（感情分析機能）  
・Sign In With Appleを用いたログイン機能＆ログアウト機能  
・通知機能  
・Twitterシェア機能  
・レビュー機能  
・お問い合わせ機能（メール機能）  
・Twitter紹介機能（開発者）

## 開発で使用した技術
![README技術 001](https://user-images.githubusercontent.com/61372276/104113183-702ae500-533a-11eb-884c-8d3d1a6848ec.jpeg)
### Swift version 5.3.2
・MVCモデル開発  
・XML解析  
・JSON解析  
・WebView

以下、使用したCocoaPodsとライブラリ
```
pod 'IBMWatsonToneAnalyzerV3', '~> 3.6.0'
pod 'IBMWatsonLanguageTranslatorV3', '~> 3.6.0'
pod 'SwiftyJSON'
pod 'Firebase'
pod 'Firebase/Auth'
pod 'PKHUD', '~> 5.0'
pod 'Kingfisher'
```

```
# API通信で使用
import ToneAnalyzer
import LanguageTranslator
import SwiftyJSON

# Sign In With Appleで使用
import Firebase
import FirebaseAuth
import PKHUD
import AuthenticationServices
import CryptoKit

# ニュースページサムネイルで使用
import Kingfisher

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

## 工夫したポイント
#### ニュースの順番の整合性を合わせる
XML解析をおこなった後に取得したニュースの順番と、API通信で返ってきたレスポンスの順番にずれが生じ、

その状態でニュースを表示すると感情分析結果とは違ったニュースを表示してしまう問題が発生しました。

その為、ニュースの順番を合わせるのに必要なアルゴリズムを開発者側で構築したのは工夫したポイントです。


## 今後の課題
#### テストコードの記述
XCTestを用いてテストコードの記述を試みましたが、難易度が高く現在保留としております。

次のアクションは、2つのパターンを検討しております。 

① XCTestの基礎知識を『iOSアプリ開発自動テストの教科書〜』を使って身につける。

その後、改めてHappyNewsのテストコードの実装に取り掛かるということ。

② **MagicPod**という自動テストをAIでおこなうツールを用いてアプリのテストを実施するということ。

MagicPodは、note株式会社様や株式会社Gunosy様でも実用した事例が存在するツールなので、只今検討中であります。

## 使い方
### 感情分析中画面
![Simulator Screen Shot - iPhone 11 - 2021-01-31 at 20 19 04](https://user-images.githubusercontent.com/61372276/106412658-96502a80-648b-11eb-8dea-2ba30d10f97b.png)

### ニュースページの紹介
![ニュースページ](https://user-images.githubusercontent.com/61372276/106384833-4b450180-6410-11eb-9298-157d1ab216b5.gif)

### ログインページの紹介
![ログインページ紹介_1](https://user-images.githubusercontent.com/61372276/106385453-c0660600-6413-11eb-8fe7-bf796be93c70.gif)

### 通知設定機能の紹介
![通知機能紹介_1](https://user-images.githubusercontent.com/61372276/106385352-3e75dd00-6413-11eb-8fe3-42ae6eb64eb8.gif)

### シェア機能の紹介
![シェア紹介](https://user-images.githubusercontent.com/61372276/106385370-53527080-6413-11eb-9043-efea0e5d2de9.gif)

### レビュー機能の紹介
![AnyConv com__画面収録 2021-02-01 12 14 16](https://user-images.githubusercontent.com/61372276/106412040-09f13800-648a-11eb-961c-ab737c55cd87.gif)

### Twitter紹介機能の紹介
![Twitter紹介](https://user-images.githubusercontent.com/61372276/106384923-d4f4cf00-6410-11eb-8758-b0e927c57dbf.gif)

### ログアウト機能の紹介
![ログアウト_1](https://user-images.githubusercontent.com/61372276/106385382-682f0400-6413-11eb-909b-3471c53e53df.gif)

## インストール方法
[AppleStoreへ移動](#)

## 開発者の連絡先
HappyNewsに関するご連絡はアカウントをフォローしていただき[Twitter](https://twitter.com/ken_sasaki2)のダイレクトメッセージにて連絡。  
もしくは、アプリ内の**ご意見・ご要望**からご連絡下さい。  
プルリクエストも大歓迎です。

▼その他連絡先  
[Qiita](https://qiita.com/nkekisasa222)  
[Github](https://github.com/ken-sasaki-222)
