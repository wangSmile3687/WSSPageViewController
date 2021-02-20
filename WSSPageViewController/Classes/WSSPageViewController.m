//
//  WSSPageViewController.m
//  WSSPageViewController
//
//  Created by wangsi1 on 2021/2/20.
//

#import "WSSPageViewController.h"

@interface WSSPageViewController ()<UIScrollViewDelegate>
@property (nonatomic, readonly) NSInteger childControllersCount;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger controllerCount;
@property (nonatomic, strong) NSMutableArray *childViewFrames;
@property (nonatomic, strong) NSMutableDictionary *displayVC;
@property (nonatomic, strong) NSCache *memCache;
@property (nonatomic, strong) NSMutableDictionary *backgroundCache;
@property (nonatomic, assign) NSInteger memoryWarningCount;
@property (nonatomic, assign) CGRect contentViewFrame;
@property (nonatomic, assign) BOOL shouldNotScroll;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, assign) NSInteger marketSelectIndex;
@end

@implementation WSSPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initConfig];
    [self.view addSubview:self.scrollView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.memoryWarningCount++;
    self.cachePolicy = WSSPageViewControllerCachePolicyLowMemory;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setCachePolicyAfterMemoryWarning) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setCachePolicyToHigh) object:nil];
    [self.memCache removeAllObjects];
    if (self.memoryWarningCount < 3) {
        [self performSelector:@selector(setCachePolicyAfterMemoryWarning) withObject:nil afterDelay:3.0 inModes:@[NSRunLoopCommonModes]];
    }
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setCachePolicyAfterMemoryWarning) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setCachePolicyToHigh) object:nil];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        if (_shouldNotScroll) return;
        [self layoutChildViewControllers];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.scrollView) {
        _selectIndex = (NSInteger)(self.scrollView.contentOffset.x / _contentViewFrame.size.width);
        if (!decelerate) {
            [self didEnterControllerWithIndex:self.selectIndex];
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        _selectIndex = (NSInteger)(self.scrollView.contentOffset.x / _contentViewFrame.size.width);
        [self didEnterControllerWithIndex:self.selectIndex];
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        _selectIndex = (NSInteger)(self.scrollView.contentOffset.x / _contentViewFrame.size.width);
        [self didEnterControllerWithIndex:self.selectIndex];
    }
}
#pragma mark - notification
- (void)willResignActive:(NSNotification *)notification {
    for (int i = 0; i < self.childControllersCount; i++) {
        id obj = [self.memCache objectForKey:@(i)];
        if (obj) {
            [self.backgroundCache setObject:obj forKey:@(i)];
        }
    }
}
- (void)willEnterForeground:(NSNotification *)notification {
    for (NSNumber *key in self.backgroundCache.allKeys) {
        if (![self.memCache objectForKey:key]) {
            [self.memCache setObject:self.backgroundCache[key] forKey:key];
        }
    }
    [self.backgroundCache removeAllObjects];
}
#pragma mark - public method
- (void)reloadData {
    [self reloadDataWithIndex:0];
}
- (void)reloadDataWithIndex:(NSInteger)index {
    self.selectIndex = index;
    [self clearDatas];
    if (!self.childControllersCount) return;
    [self resetScrollView];
    [self.memCache removeAllObjects];
    [self forceLayoutSubviews];
    [self initializedControllerWithIndex:self.selectIndex];
    [self didEnterControllerWithIndex:self.selectIndex];
}
- (void)forceLayoutSubviews {
    if (!self.childControllersCount) return;
    [self calculateFrame];
    [self adjustScrollViewFrame];
    [self adjustDisplayingViewControllersFrame];
}
- (void)refreshWithIndex:(NSInteger)index {
    [self refreshWithIndex:index animated:NO];
}
- (void)refreshWithIndex:(NSInteger)index animated:(BOOL)animated {
    self.selectIndex = index;
    CGPoint targetP = CGPointMake(_contentViewFrame.size.width * index, 0);
    [self.scrollView setContentOffset:targetP animated:animated];
    [self didEnterControllerWithIndex:self.selectIndex];
}
#pragma mark - private method
- (void)initConfig {
    if (!_memCache) {
        _memCache = [[NSCache alloc] init];
    }
    _marketSelectIndex = -1;
    _controllerCount  = 0;
    _cachePolicy = WSSPageViewControllerCachePolicyNoLimit;
    _preloadPolicy = WSSPageViewControllerPreloadPolicyNever;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}
- (void)calculateFrame {
    _contentViewFrame = [self.dataSource pageViewController:self preferredFrameForContentView:self.scrollView];
    [self.childViewFrames removeAllObjects];
    for (int i = 0; i < self.childControllersCount; i++) {
        CGRect frame = CGRectMake(i * _contentViewFrame.size.width, 0, _contentViewFrame.size.width, _contentViewFrame.size.height);
        [self.childViewFrames addObject:[NSValue valueWithCGRect:frame]];
    }
}
- (void)adjustScrollViewFrame {
    _shouldNotScroll = YES;
    CGFloat oldContentOffsetX = self.scrollView.contentOffset.x;
    CGFloat contentWidth = self.scrollView.contentSize.width;
    self.scrollView.frame = _contentViewFrame;
    self.scrollView.contentSize = CGSizeMake(self.childControllersCount * _contentViewFrame.size.width, 0);
    CGFloat xContentOffset = contentWidth == 0 ? self.selectIndex * _contentViewFrame.size.width : oldContentOffsetX / contentWidth * self.childControllersCount * _contentViewFrame.size.width;
    [self.scrollView setContentOffset:CGPointMake(xContentOffset, 0)];
    _shouldNotScroll = NO;
}
- (void)adjustDisplayingViewControllersFrame {
    [self.displayVC enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIViewController * _Nonnull vc, BOOL * _Nonnull stop) {
        NSInteger index = key.integerValue;
        CGRect frame = [self.childViewFrames[index] CGRectValue];
        vc.view.frame = frame;
    }];
}
- (void)layoutChildViewControllers {
    NSInteger currentPage = (NSInteger)(self.scrollView.contentOffset.x / _contentViewFrame.size.width);
    NSInteger length = self.preloadPolicy;
    NSInteger left = currentPage - length - 1;
    NSInteger right = currentPage + length + 1;
    for (int i = 0; i < self.childControllersCount; i++) {
        UIViewController *vc = [self.displayVC objectForKey:@(i)];
        CGRect frame = [self.childViewFrames[i] CGRectValue];
        if (!vc) {
            if ([self isInScreen:frame]) {
                [self initializedControllerWithIndex:i];
            }
        } else if (i <= left || i >= right) {
            if (![self isInScreen:frame]) {
                [self removeViewController:vc atIndex:i];
            }
        }
    }
}
- (void)initializedControllerWithIndex:(NSInteger)index {
    if (!self.childControllersCount) return;
    UIViewController *vc = [self.memCache objectForKey:@(index)];
    if (vc) {
        [self addCachedViewController:vc atIndex:index];
    } else {
        [self addViewControllerAtIndex:(int)index];
    }
}
- (void)addCachedViewController:(UIViewController *)viewController atIndex:(NSInteger)index {
    [self addChildViewController:viewController];
    viewController.view.frame = [self.childViewFrames[index] CGRectValue];
    [viewController didMoveToParentViewController:self];
    [self.scrollView addSubview:viewController.view];
    [self willEnterController:viewController atIndex:index];
    [self.displayVC setObject:viewController forKey:@(index)];
}
- (void)addViewControllerAtIndex:(NSInteger)index {
    UIViewController *viewController = [self.dataSource pageViewController:self viewControllerWithIndex:index];;
    [self addChildViewController:viewController];
    CGRect frame = self.childViewFrames.count ? [self.childViewFrames[index] CGRectValue] : self.view.frame;
    viewController.view.frame = frame;
    [viewController didMoveToParentViewController:self];
    [self.scrollView addSubview:viewController.view];
    [self willEnterController:viewController atIndex:index];
    [self.displayVC setObject:viewController forKey:@(index)];
}
- (void)removeViewController:(UIViewController *)viewController atIndex:(NSInteger)index {
    [viewController.view removeFromSuperview];
    [viewController willMoveToParentViewController:nil];
    [viewController removeFromParentViewController];
    [self.displayVC removeObjectForKey:@(index)];
    if (self.cachePolicy == WSSPageViewControllerCachePolicyDisabled) {
        return;
    }
    if (![self.memCache objectForKey:@(index)]) {
        [self.memCache setObject:viewController forKey:@(index)];
    }
}
- (void)willEnterController:(UIViewController *)vc atIndex:(NSInteger)index {
    _selectIndex = index;
    if (self.childControllersCount && [self.delegate respondsToSelector:@selector(pageViewController:willEnterViewController:didSelectedIndex:)]) {
        [self.delegate pageViewController:self willEnterViewController:vc didSelectedIndex:index];
    }
}
- (void)didEnterControllerWithIndex:(NSInteger)index {
    if (!self.childControllersCount) return;
    UIViewController *currentViewController = self.displayVC[@(index)];
    if (_marketSelectIndex != index) {
        if ([self.delegate respondsToSelector:@selector(pageViewController:didSelectedViewController:didSelectedIndex:)]) {
            [self.delegate pageViewController:self didSelectedViewController:currentViewController didSelectedIndex:index];
        }
        _marketSelectIndex = index;
    }
    if ([self.delegate respondsToSelector:@selector(pageViewController:didEnterViewController:didSelectedIndex:)]) {
        [self.delegate pageViewController:self didEnterViewController:currentViewController didSelectedIndex:index];
    }
    if (self.preloadPolicy == WSSPageViewControllerPreloadPolicyNever) return;
    NSInteger length = (int)self.preloadPolicy;
    NSInteger start = 0;
    NSInteger end = self.childControllersCount - 1;
    if (index > length) {
        start = index - length;
    }
    if (self.childControllersCount - 1 > length + index) {
        end = index + length;
    }
    for (NSInteger i = start; i <= end; i++) {
        if (![self.memCache objectForKey:@(i)] && !self.displayVC[@(i)]) {
            [self addViewControllerAtIndex:i];
        }
    }
    _selectIndex = index;
}
- (void)clearDatas {
    _controllerCount = 0;
    NSUInteger maxIndex = (self.childControllersCount - 1 > 0) ? (self.childControllersCount - 1) : 0;
    _selectIndex = self.selectIndex < self.childControllersCount ? self.selectIndex : (int)maxIndex;
    NSArray *displayingViewControllers = self.displayVC.allValues;
    for (UIViewController *vc in displayingViewControllers) {
        [vc.view removeFromSuperview];
        [vc willMoveToParentViewController:nil];
        [vc removeFromParentViewController];
    }
    self.memoryWarningCount = 0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setCachePolicyAfterMemoryWarning) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setCachePolicyToHigh) object:nil];
    [self.displayVC removeAllObjects];
}
- (void)resetScrollView {
    if (self.scrollView) {
        [self.scrollView removeFromSuperview];
        self.scrollView = nil;
    }
    [self.view addSubview:self.scrollView];
}
- (BOOL)isInScreen:(CGRect)frame {
    NSInteger x = frame.origin.x;
    NSInteger ScreenWidth = self.scrollView.frame.size.width;
    NSInteger contentOffsetX = self.scrollView.contentOffset.x;
    if (CGRectGetMaxX(frame) > contentOffsetX && x - contentOffsetX < ScreenWidth) {
        return YES;
    } else {
        return NO;
    }
}
- (void)setCachePolicyAfterMemoryWarning {
    self.cachePolicy = WSSPageViewControllerCachePolicyBalanced;
    [self performSelector:@selector(setCachePolicyToHigh) withObject:nil afterDelay:2.0 inModes:@[NSRunLoopCommonModes]];
}
- (void)setCachePolicyToHigh {
    self.cachePolicy = WSSPageViewControllerCachePolicyHigh;
}
#pragma mark - setter
- (void)setCachePolicy:(WSSPageViewControllerCachePolicy)cachePolicy {
    _cachePolicy = cachePolicy;
    if (cachePolicy != WSSPageViewControllerCachePolicyDisabled) {
        self.memCache.countLimit = _cachePolicy;
    }
}
- (void)setContentViewBounces:(BOOL)contentViewBounces {
    _contentViewBounces = contentViewBounces;
    
    self.scrollView.bounces = contentViewBounces;
}
#pragma mark - getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.scrollsToTop = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = YES;
    }
    return _scrollView;
}
- (NSMutableArray *)childViewFrames {
    if (!_childViewFrames) {
        _childViewFrames = [NSMutableArray new];
    }
    return _childViewFrames;
}
- (NSMutableDictionary *)displayVC {
    if (!_displayVC) {
        _displayVC = [NSMutableDictionary new];
    }
    return _displayVC;
}
- (NSMutableDictionary *)backgroundCache {
    if (!_backgroundCache) {
        _backgroundCache = [NSMutableDictionary new];
    }
    return _backgroundCache;
}
- (NSInteger)childControllersCount {
    if (_controllerCount == 0) {
        _controllerCount = [self.dataSource numbersOfChildControllersInPageViewController:self];
    }
    return _controllerCount;
}
@end
