# unity_ads_objc_4_21_0

Unity広告SDK（バージョン4.21.0）をiOS（Objective-C）に実装するためのサンプルプログラムです。
Unity Adsの処理を最新のSDK仕様（ビルダー方式）に適合させ、部品化しやすいように整理しました。

## 📌 主な特徴・機能
* **メモリリーク・クラッシュ対策の自動化**
  ビューの破棄（`viewWillDisappear` や `dealloc`）のタイミングで、SDKの内部参照を安全に手動解放（クリーンアップ）する処理（`cleanupBannerAd`）を実装。呼び出し元の画面が破棄された際の後続通知によるクラッシュを防ぎます。
* **セーフエリア（ジェスチャーバー）と下地ラベルの完全同期**
  ホームボタンのないiPhone（iPhone X以降〜iPhone 16等）に表示される画面下部の**ジェスチャーバー（ホームインジケータ）**に対応。`viewDidLoad` 時のサイズ未確定によるレイアウト崩れを防ぐため、システムが安全領域を確定させる **`viewDidLayoutSubviews`** のタイミングで画面サイズ（`screenSize`）を動的に取得。下地ラベル（`lblAdArea`）とバナー広告を画面最下部の中央へ1文字の狂いもなく正確に配置します。
* **テストモードの自動判定マクロ搭載**
  `#if TARGET_OS_SIMULATOR` マクロを採用。手動でフラグを書き換えなくても、Mac上のシミュレータ起動時は自動的にテストモード（`YES`）、実機での本番ビルド時は自動的に本番モード（`NO`）へ切り替わります。

---

## 🛠 開発環境
* **開発ツール:** Xcode 15〜17 (動作確認: Xcode 17.2)
* **言語:** Objective-C / Swift (※ブリッジ用)
* **対応OS:** iOS 13.0以上 (SDK 4.x仕様)
* **Unity Ads SDK Version:** 4.21.0

## 📂 主要なファイル構成
* `ViewController.h` : Unity Adsを組み込む画面のヘッダファイル。
* `ViewController.m` : 最新のSDKに適合したバナー広告ロード・配置ロジックの実装ファイル。
* `capture/` : テストモードでの実際のシミュレータ実行画面キャプチャ。

---

## 🔍 実装のポイントと事前設定

ご自身のプロジェクトで動かす前に、`ViewController.m` 内の `viewDidLoad` にある以下のIDをご自身の環境に合わせて修正してください。

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    
    int mode = [self testMode];
    
    // ⚠️ ご自身の本番用IDに書き換えてください（テスト時は自動でサンプルIDになります）
    gameId = mode == NO ? @"【あなたの本番用GameID】" : @"4550883";
    interstitialPlacementId = mode == NO ? @"【あなたの本番用全画面ID】" : @"Interstitial_iOS";
    bannerPlacementId = mode == NO ? @"【あなたの本番用バナーID】" : @"Banner_iOS";
    
    // ...
}
```

#### 📊 広告に使用するパラメータ一覧（テスト用リファレンス）

| パラメータの種類 | 本番モード | テストモード (シミュレータ時自動) |
| :--- | :--- | :--- |
| **Game ID** | あなたのiOS用Game ID | `4550883` |
| **Test Mode** | `NO` | `YES` |
| **Placement ID (バナー)** | あなたの本番用Placement ID | `Banner_iOS` |
| **Interstitial Placement ID (全画面)** | あなたの本番用全画面ID | `Interstitial_iOS` |

---

## ⚙️ 自分のプロジェクトへの導入手順

### 1. SDK (.xcframework) のダウンロードとプロジェクトへの追加
1. Unity Ads iOS SDK の公式リポジトリ [Unity-Technologies/unity-ads-ios](https://github.com/Unity-Technologies/unity-ads-ios/releases) からフレームワークをダウンロードします。
2. 解凍した `UnityAds.xcframework` を、Xcodeの左側にある **Project Navigator** （ファイルツリー）内にドラッグ&ドロップします。
3. 追加時のダイアログ（Choose options for adding these files）が表示されたら、以下のように設定して **Finish** を押します。
   * **Action:** `Copy files to destination` にチェックを入れる。
   * **Targets:** アプリのターゲット名にチェックを入れる。

### 2. 埋め込み設定（Embed & Sign）の変更 【最重要】
外部フレームワークを導入する場合、以下の設定を行わないとアプリ起動時にクラッシュします。
1. XcodeのProject Navigatorの一番上にある**青いプロジェクトアイコン**をクリックします。
2. 中央エリアの **General** タブを開きます。
3. 下部にある **Frameworks, Libraries, and Embedded Content** という項目を探します。
4. `UnityAds.xcframework` の右側にある **Embed** の設定項目を `Do Not Embed` から **`Embed & Sign`** に変更してください。

### 3. Swift Compatibility リンクエラーの回避（ブリッジヘッダーの作成）
純粋なObjective-CプロジェクトにSwiftで構築された最新のUnity Ads SDKを導入すると、コンパイル時に以下の `Undefined symbol` エラー（リンクエラー）が発生します。

```text
Undefined symbol: __swift_FORCE_LOAD_\$_swiftCompatibility56
Undefined symbol: __swift_FORCE_LOAD_\$_swiftCompatibilityConcurrency
Linker command failed with exit code 1
```

これを回避するために、プロジェクト内に空のSwiftファイルを1つ作成します。
1. プロジェクトツリーを右クリックし、**「New File...」** を選択します。
2. テンプレート画面で **「Swift File」** を選択してファイルを作成します（ファイル名は `dummy.swift` など任意）。
3. 作成直後に表示される以下のダイアログボックスで、必ず **「Create Bridging Header」** をクリックしてください。
   > *Would you like to configure an Objective-C bridging header?*
4. 空のSwiftファイルとブリッジヘッダーが作成されたら、**`Cmd + Shift + K`** (Clean Build Folder) を実行してから再ビルドしてください。エラーが自動的に解消されます。

### 4. ヘッダーファイルのインポート
Unity Adsを使用するクラス（`ViewController.m`など）の先頭で、以下のようにインポートを行ってください。

```objc
#import <UnityAds/UnityAds.h>
```

---

### 5. Storyboardを使わずにコードのみで起動するための設定 (脱Storyboard)
本サンプルは Storyboard を使用せず、`SceneDelegate.m` からコードのみで初期画面を生成しています。ご自身のプロジェクトへ導入する際は、以下の設定を行ってください。

1. プロジェクトツリーから **`Main.storyboard`** ファイルを削除（ゴミ箱へ移動）します。
2. ターゲット設定の **「Info」** タブ（または `Info.plist`）を開きます。
3. リスト内から **`Main storyboard file base name`** （キー名: `UIMainStoryboardFile`）という行を探し、丸ごと削除します。
4. さらに以下の階層を深く開いていきます：
   `Application Scene Manifest` ＞ `Scene Configuration` ＞ `Application Session Role` ＞ `Item 0 (Default Configuration)`
5. その中にある **`Storyboard Name`** （値が `Main` になっている行）を選択し、「ー（マイナス）」ボタンで削除します。

---

## 🔗 関連リンク
* **開発者サイト:** [nekofes.github.io](https://nekofes.github.io/)
