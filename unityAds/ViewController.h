//
//  ViewController.h
//  unityAds
//

#import <UIKit/UIKit.h>
//Unity Ads SDKをインポート
#import <UnityAds/UnityAds.h>

@interface ViewController : UIViewController


@property (nonatomic, strong) NSString *gameId;
@property (nonatomic, strong) NSString *interstitialPlacementId;
@property (nonatomic, strong) NSString *bannerPlacementId;
@property (nonatomic) UILabel *lblAdArea;
@property (nonatomic) CGFloat screenWidth;
@property (nonatomic) CGFloat screenHeight;
@property (nonatomic) CGFloat safeAreaBottom;
@property (nonatomic) CGFloat adWidth;
@property (nonatomic) CGFloat adHeight;

@end

