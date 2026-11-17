//
//  SceneDelegate.m
//  unityAds
//

#import "SceneDelegate.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate



//iOS 13以降の端末
- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

    
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    //システムから渡された scene オブジェクトが、本当に正常な UIWindowScene 型であるか」をチェックする安全装置（バリデーション）
    if (!windowScene) {
        return; // もし空っぽなら、ここで処理を諦めて抜ける（これ以降は実行されない）
        /*
         • バックグラウンドでの事前処理（プッシュ通知など）
         アプリの画面は出さずに、裏側でデータだけを更新・同期するためにシステムがアプリを一時起動した時です。
         この時は画面がいらないため scene は空っぽになり、return で終了するのが「正しい挙動」になります。
         • メモリ解放などによる一時中断
         iPadなどで画面分割を解除した瞬間など、システムが一度そのシーンの処理を破棄する時です。

        */
    }
    
    //画面を作る準備
    ViewController *top = [[ViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:top];
    navi.navigationBarHidden = YES;
    
    // 【ステップ 3】ウィンドウを作成して画面をセット
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.rootViewController = navi;
    
    //常にライトモードに固定する設定(ダークモードでは不要)
    //ここで判定メソッドを呼び出す（windowSceneを引数に渡す）
    //int mode = [self judgeDarkMode:windowScene];

    /*
     現在のiOS（iOS 13以降）の仕様では「システムの画面モード（ダークモード）に連動する」のがデフォルト
     端末（iPhoneやシミュレータ）自体がダークモード（黒ベース）に設定されていても、
     このアプリのこのウィンドウ内だけは、強制的にライトモード（白ベース）の見た目で動かしてください
     というシステムへの命令（上書き指示）です
    */
    if (@available(iOS 13.0, *))
    {
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    //最後に画面を実際に表示
    [self.window makeKeyAndVisible];
}
//ダークモード判定処理
//result:戻り値
//0:ノーマル
//1:ダークモード
-(int)judgeDarkMode:(UIWindowScene *)windowScene
{
    int result = 0;//ノーマル
    if (@available(iOS 13.0, *))
    {
        // 現在のスタイルを取得
        //UIUserInterfaceStyle style = self.traitCollection.userInterfaceStyle;//画面のケース
        UIUserInterfaceStyle style = windowScene.traitCollection.userInterfaceStyle;
        
        if (style == UIUserInterfaceStyleDark) {
            //ダークモード（黒背景）のときの処理
            NSLog(@"現在はダークモードです");
            result = 1;
        } else {
            //ライトモード（白背景 / ノーマル）のときの処理
            NSLog(@"現在はライトモードです");
        }
    } else {
        // iOS 12以前はダークモード自体がないため、常にノーマル扱い
        NSLog(@"iOS 12以前（ノーマル）です");
    }
    return result;
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


@end
