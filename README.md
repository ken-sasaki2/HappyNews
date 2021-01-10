![READMEヘッダ 001](https://user-images.githubusercontent.com/61372276/104112023-e9bbd680-532c-11eb-82d6-5f48a28df9e9.jpeg)

## アプリの概要
機械学習を用いて明るい情報だけを提供するニュースアプリ

## 開発の経緯
2020年夏、新型コロナウイルスを筆頭にネガティブな情報ばかりを目にする日々が続きました。
開発者はそんな日常に嫌気がさし、気持ちを落として生活をしておりました。

また、この状態がこれからも続くことを問題と捉えるようになりました。

そこで、ネガティブな情報ではなく、ポジティブな（明るい）情報に触れ合う機会を増やすことができれば、
現状よりも張りのある生活ができるのでは？と考えるようになり、
プログラミングを通じてこの問題を解決しようと考えたのがHappyNews開発の経緯です。

## 機能一覧
・ニュース表示機能
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
・ローカルプッシュ通知
・WebViewの表示

以下、使用したCocoaPods
```
pod 'SegementSlide'
pod 'IBMWatsonToneAnalyzerV3', '~> 3.6.0'
pod 'IBMWatsonLanguageTranslatorV3', '~> 3.6.0'
pod 'SwiftyJSON'
pod 'Firebase'
pod 'Firebase/Auth'
pod 'PKHUD', '~> 5.0'
pod 'FirebaseMessaging'
pod 'Kingfisher'
```
###  IBM Watson API （機械学習）
・言語翻訳機能（LanguageTranslator）
・感情分析機能（ToneAnalyzer）

### Firebase
・Sign In With Apple

## 使い方
＃随時更新

## インストール方法
＃随時更新

## 開発者の連絡先
HappyNewsに関するご連絡は[Twitter](https://twitter.com/ken_sasaki2)もしくは、アプリ内の**ご意見・ご要望**からご連絡下さい。
プルリクエストも大歓迎です。

▼その他連絡先
[Qiita](https://qiita.com/nkekisasa222)
[Github](https://github.com/ken-sasaki-222)

