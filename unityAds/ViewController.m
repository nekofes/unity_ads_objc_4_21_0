#import "ViewController.h"

@interface ViewController ()

// 最新の広告オブジェクトを保持するプロパティ
@property (nonatomic, strong) UADSBannerAd *bannerAd;
@property (nonatomic, strong) UADSInterstitialAd *interstitialAd;//読み込んだ全画面広告オブジェクトを保持する

@end

@implementation ViewController

@synthesize gameId;
@synthesize interstitialPlacementId;
@synthesize bannerPlacementId;
@synthesize lblAdArea;
@synthesize screenWidth;
@synthesize screenHeight;
@synthesize safeAreaBottom;
@synthesize adWidth;
@synthesize adHeight;

/*
 テストモードの自動判定
 [戻り値]
 NO : 本番モード
 YES: テストモード
*/
-(BOOL)testMode
{
    BOOL isTestMode = NO; // デフォルトは本番モード
    
    //シミュレータか実機かを自動判定してテストモードを切り替える
    #if TARGET_OS_SIMULATOR
        isTestMode = YES;
        NSLog(@"[Unity Ads] シミュレータ起動のため、テストモード(YES)で初期化します。");
    #else
        NSLog(@"[Unity Ads] 実機起動のため、本番モード(NO)で初期化します。");
    #endif
    
    return isTestMode;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 画面の背景色を明示的に「白」にする
    self.view.backgroundColor = [UIColor whiteColor];
    
    int mode=[self testMode];//テストモードの自動判定
    // 各種IDの設定
    //Unity Dashboard（管理画面）でどのように作成・設定したかによって決まります
    gameId = mode==NO ? @"【あなたの本番用GameID】" : @"4550883";
    interstitialPlacementId = mode==NO ? @"【あなたの本番用全画面ID】" : @"Interstitial_iOS";
    bannerPlacementId = mode==NO ? @"【あなたの本番用バナーID】" : @"Banner_iOS";

    //画面準備
    //ここではまだ枠サイズが未確定のため、初期配置でaddSubviewだけ行います
    [self screen];
    
    //最新のBuilderを使用した初期化方式に変更
    UADSInitializationConfigurationBuilder *initConfigBuilder = [[UADSInitializationConfigurationBuilder alloc] initWithGameId:gameId];
    //withTestModeを実行した結果を、もう一度自分自身に上書き代入して戻り値を受け取ります
    initConfigBuilder = [initConfigBuilder withTestMode:mode];
    __weak typeof(self) weakSelf = self;
    [UnityAds initialize:[initConfigBuilder build] completion:^(id<UnityAdsError> _Nullable error) {
        if (!error) {
            NSLog(@"Unity Ads: 初期化に成功しました。各広告のロードを開始します。");
            [weakSelf loadAllAds];
        } else {
            NSLog(@"Unity Ads: 初期化に失敗しました: %@", error);
        }
    }];
}
//画面準備
-(void)screen
{
    lblAdArea = [[UILabel alloc] init];
    lblAdArea.text=@"ここの上にunity adsの広告が表示されます。\n広告表示後は、このラベルは非表示に切り替わります。";
    lblAdArea.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:153.0/255.0 blue:255.0/255.0 alpha:240.0/255.0];

    lblAdArea.textAlignment = NSTextAlignmentCenter;

    [self.view addSubview:lblAdArea];

}
// 広告のロード処理をまとめる
- (void)loadAllAds
{
    [self loadInterstitialAd];
    [self loadBannerAd];
}

#pragma mark - 広告のロード処理（最新方式）

// インタースティシャル広告のロード
- (void)loadInterstitialAd
{
    UADSLoadConfigurationBuilder *interstitialBuilder = [[UADSLoadConfigurationBuilder alloc] initWithPlacementId:interstitialPlacementId];
    
    __weak typeof(self) weakSelf = self;
    //UADSInterstitialAdクラス自身でロードします
    [UADSInterstitialAd load:[interstitialBuilder build] completion:^(UADSInterstitialAd * _Nullable interstitialAd, id<UnityAdsError> _Nullable error) {
        if (interstitialAd) {
            NSLog(@"Unity Ads: インタースティシャル広告のロード完了: %@", weakSelf.interstitialPlacementId);
            weakSelf.interstitialAd = interstitialAd; // オブジェクトを保持
        } else {
            NSLog(@"Unity Ads: インタースティシャル ロード失敗");
        }
    }];
}

// バナー広告のロード
- (void)loadBannerAd
{
    UADSBannerLoadConfigurationBuilder *bannerBuilder = [[UADSBannerLoadConfigurationBuilder alloc] initWithPlacementId:bannerPlacementId bannerSize:CGSizeMake(320, 50) delegate:(id)self];
    
    __weak typeof(self) weakSelf = self;
    [UADSBannerAd load:[bannerBuilder build] completion:^(UADSBannerAd * _Nullable bannerAd, id<UnityAdsError> _Nullable error) {
        if (bannerAd) {
            NSLog(@"Unity Ads: バナーのオブジェクト生成成功。");
            weakSelf.bannerAd = bannerAd;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (bannerAd.view) {
                    bannerAd.view.alpha = 0.0; // 一旦透明にして追加
                    [weakSelf.view addSubview:bannerAd.view];
                    [weakSelf.view setNeedsLayout]; // レイアウト確定を要求
                }
            });
        }
    }];
}

#pragma mark - レイアウト確定（バナー最下部中央配置）
-(void)screenSize
{
    CGSize screenSize = self.view.bounds.size;
    UIEdgeInsets safeArea = UIEdgeInsetsZero;
    
    if (@available(iOS 11.0, *))
    {
        safeArea = self.view.safeAreaInsets;
    }
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
    safeAreaBottom = [self getBottomGestureBarHeight];
    //Unity Adsのバナー広告のサイズ
    adWidth = 320.0;
    adHeight = 50.0;
}
// 画面下部のジェスチャーバーの領域（高さ）を取得するメソッド
-(CGFloat)getBottomGestureBarHeight
{
    CGFloat bottomInset = 0.0;
    
    if (@available(iOS 11.0, *))
    {
        // iOS 13以降のSceneベースに対応したウィンドウ取得
        UIWindow *window = nil;
        if (@available(iOS 13.0, *))
        {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes)
            {
                if (scene.activationState == UISceneActivationStateForegroundActive)
                {
                    for (UIWindow *w in scene.windows)
                    {
                        if (w.isKeyWindow)
                        {
                            window = w;
                            break;
                        }
                    }
                }
                if (window) break;
            }
        }
        
        // iOS 12以前の古い取得方法（Sceneが取れなかった場合のフォールバック）
        if (!window)
        {
            window = [UIApplication sharedApplication].keyWindow;
        }
        
        if (window)
        {
            bottomInset = window.safeAreaInsets.bottom;
        }
    }
    
    return bottomInset;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //画面サイズが確定したこの瞬間に、サイズを取得して下地ラベルを正しい位置へ移動させる
    [self screenSize];
    
    CGFloat yLabel = screenHeight - (adHeight + safeAreaBottom);
    lblAdArea.frame = CGRectMake(0, yLabel, screenWidth, adHeight);
    

    if (self.bannerAd && self.bannerAd.view && self.bannerAd.view.superview)
    {
        CGFloat xPos = (screenWidth - adWidth) / 2.0;
        CGFloat yPos = screenHeight - adHeight - safeAreaBottom;

        self.bannerAd.view.frame = CGRectMake(xPos, yPos, adWidth, adHeight);
        self.bannerAd.view.alpha = 1.0; // 正しい位置へ移動させてから表示
    }
}
/*
 広告エリアの表示切り替え
 hidden:
 0:非表示
 1:表示
*/
-(void)displayAdAreaLabel:(BOOL)hidden
{
    lblAdArea.hidden = hidden;
}

#pragma mark - 各種デリゲートイベント（ログ通知用）

//バナー広告用
- (void)bannerImpression:(UADSBannerAd *)bannerAd
{
    [self displayAdAreaLabel:YES];
    NSLog(@"[イベント] バナー広告のインプレッション発生");
}
- (void)bannerAdDidShow:(UADSBannerAd *)bannerAd
{
    [self displayAdAreaLabel:YES];
    NSLog(@"[イベント] バナー広告が表示されました。");
}
- (void)bannerAdDidFailToLoad:(UADSBannerAd *)bannerAd error:(UADSBannerError *)error
{
    [self displayAdAreaLabel:NO];
    NSLog(@"Unity Ads: バナーロード失敗");
}
//メソッド名を「bannerDidClick:」へ修正します（Ad を削る）
- (void)bannerDidClick:(UADSBannerAd *)bannerAd {
    NSLog(@"[AdManager] バナー広告がユーザーにクリックされました。");
}

- (void)bannerAdDidLeaveApplication:(UADSBannerAd *)bannerAd
{
    NSLog(@"[イベント] アプリを離れました");
}
- (void)bannerDidFailShow:(UADSBannerAd *)banner error:(id<UnityAdsError>)error
{
    //バナーの表示に失敗した（結果として非表示になった）時の処理
}
//全画面広告（インタースティシャル）用
- (void)showDidClick:(UADSInterstitialAd *)unityAd
{
    NSLog(@"[イベント] 全画面広告クリック");
}
- (void)showDidFail:(UADSInterstitialAd *)unityAd error:(id<UnityAdsError>)error
{
    NSLog(@"Unity Ads: 全画面広告表示失敗");
}
- (void)showDidStart:(UADSInterstitialAd *)unityAd
{
    NSLog(@"[イベント] 全画面広告表示開始");
}
- (void)showDidComplete:(UADSInterstitialAd *)unityAd with:(enum UADSShowFinishState)finishState
{
    NSLog(@"[イベント] 全画面広告が閉じられました。");
    //閉じられたので次の広告を再ロード
    [self loadInterstitialAd];
}
- (void)hideBannerAd
{
    if (self.bannerAd && self.bannerAd.view)
    {
        [self displayAdAreaLabel:YES];
        [self.bannerAd.view removeFromSuperview];
    }
}

#pragma mark - クリーンアップ
- (void)cleanupBannerAd
{
    if (self.bannerAd)
    {
        if (self.bannerAd.view)
        {
            [self.bannerAd.view removeFromSuperview];
        }
        self.bannerAd = nil;
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self isMovingFromParentViewController] || [self isBeingDismissed])
    {
        [self cleanupBannerAd];
    }
    [self hideBannerAd];
}
- (void)dealloc
{
    [self cleanupBannerAd];
}

@end
