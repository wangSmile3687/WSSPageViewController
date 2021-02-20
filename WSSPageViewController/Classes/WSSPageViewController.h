//
//  WSSPageViewController.h
//  WSSPageViewController
//
//  Created by wangsi1 on 2021/2/20.
//

#import <UIKit/UIKit.h>

/// 缓存策略
typedef NS_ENUM(NSInteger, WSSPageViewControllerCachePolicy) {
    WSSPageViewControllerCachePolicyDisabled   = -1,
    WSSPageViewControllerCachePolicyNoLimit    = 0,
    WSSPageViewControllerCachePolicyLowMemory  = 1,
    WSSPageViewControllerCachePolicyBalanced   = 3,
    WSSPageViewControllerCachePolicyHigh       = 5
};
/// 预加载策略
typedef NS_ENUM(NSInteger, WSSPageViewControllerPreloadPolicy) {
    WSSPageViewControllerPreloadPolicyNever     = 0,
    WSSPageViewControllerPreloadPolicyNeighbour = 1,
    WSSPageViewControllerPreloadPolicyNear      = 2
};
@class WSSPageViewController;
@protocol WSSPageViewControllerDataSource <NSObject>
@required
/// ChildControllers个数
/// @param pageViewController pageViewController
- (NSInteger)numbersOfChildControllersInPageViewController:(WSSPageViewController *_Nullable)pageViewController;
/// 初始化index对应的ViewController
/// @param pageViewController pageViewController
/// @param index index
- (UIViewController *_Nullable)pageViewController:(WSSPageViewController *_Nullable)pageViewController viewControllerWithIndex:(NSInteger)index;
/// scrollview的frame
/// @param pageViewController pageViewController
/// @param contentView contentView
- (CGRect)pageViewController:(WSSPageViewController *_Nullable)pageViewController preferredFrameForContentView:(UIScrollView *_Nullable)contentView;
@end
@protocol WSSPageViewControllerDelegate <NSObject>
@optional
/// viewController即将进入的回调
/// @param pageViewController pageViewController
/// @param viewController viewController
/// @param selectedIndex selectedIndex
- (void)pageViewController:(WSSPageViewController *_Nullable)pageViewController willEnterViewController:(UIViewController *_Nullable)viewController didSelectedIndex:(NSInteger)selectedIndex;
/// viewController已经进入的回调
/// @param pageViewController pageViewController
/// @param viewController viewController
/// @param selectedIndex selectedIndex
- (void)pageViewController:(WSSPageViewController *_Nullable)pageViewController didEnterViewController:(UIViewController *_Nullable)viewController didSelectedIndex:(NSInteger)selectedIndex;
/// viewController选中的回调
/// @param pageViewController pageViewController
/// @param viewController viewController
/// @param selectedIndex selectedIndex
- (void)pageViewController:(WSSPageViewController *_Nullable)pageViewController didSelectedViewController:(UIViewController *_Nullable)viewController didSelectedIndex:(NSInteger)selectedIndex;
@end
@interface WSSPageViewController : UIViewController
@property (nonatomic, weak) id <WSSPageViewControllerDelegate> _Nullable delegate;
@property (nonatomic, weak) id <WSSPageViewControllerDataSource> _Nullable dataSource;
/// 默认WSSPageViewControllerCachePolicyNoLimit
@property (nonatomic, assign) WSSPageViewControllerCachePolicy cachePolicy;
/// 默认WSSPageViewControllerPreloadPolicyNever
@property (nonatomic, assign) WSSPageViewControllerPreloadPolicy preloadPolicy;
/// 默认yes
@property (nonatomic, assign) BOOL contentViewBounces;
/// 加载 从第0个开始
- (void)reloadData;
/// 加载 从第index个开始
- (void)reloadDataWithIndex:(NSInteger)index;
/// 刷新index的viewcontroller animated-->no
/// @param index index
- (void)refreshWithIndex:(NSInteger)index;
/// 刷新index的viewcontroller
/// @param index index
/// @param animated animated
- (void)refreshWithIndex:(NSInteger)index animated:(BOOL)animated;
@end

