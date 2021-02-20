//
//  WSSTestViewController.m
//  WSSPageViewController_Example
//
//  Created by wangsi1 on 2021/2/20.
//  Copyright © 2021 WSmilec. All rights reserved.
//

#import "WSSTestViewController.h"
#import "WSSTestDetailViewController.h"

@interface WSSTestViewController ()<WSSPageViewControllerDelegate,WSSPageViewControllerDataSource>
@property (nonatomic, strong) NSMutableArray *colorArray;

@end

@implementation WSSTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"跳转指定index" style:UIBarButtonItemStyleDone target:self action:@selector(indexButtonClick)];
    self.delegate = self;
    self.dataSource = self;
    [self reloadData];
//    [self reloadDataWithIndex:2];
}
- (void)dealloc {
    NSLog(@"-dealloc-----WSSTestViewController------");
}
#pragma mark - SFPageViewControllerDelegate and SFPageViewControllerDataSource
- (CGRect)pageViewController:(WSSPageViewController *)pageViewController preferredFrameForContentView:(UIScrollView *)contentView {
    return CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64);
}
- (NSInteger)numbersOfChildControllersInPageViewController:(WSSPageViewController *)pageViewController {
    return self.colorArray.count;
}
- (UIViewController *)pageViewController:(WSSPageViewController *)pageViewController viewControllerWithIndex:(NSInteger)index {
    WSSTestDetailViewController *vc = [[WSSTestDetailViewController alloc] init];
    vc.titleStr = [NSString stringWithFormat:@"我是内嵌的第%ld个VC",(long)index];
    vc.view.backgroundColor = self.colorArray[index];
    return vc;
}
- (void)pageViewController:(WSSPageViewController *)pageViewController willEnterViewController:(UIViewController *)viewController didSelectedIndex:(NSInteger)selectedIndex {
    NSLog(@"--------willEnterViewController------   %ld",(long)selectedIndex);
}
- (void)pageViewController:(WSSPageViewController *)pageViewController didEnterViewController:(UIViewController *)viewController didSelectedIndex:(NSInteger)selectedIndex {
    NSLog(@"--------didEnterViewController------   %ld",(long)selectedIndex);
}
- (void)pageViewController:(WSSPageViewController *)pageViewController didSelectedViewController:(UIViewController * _Nullable)viewController didSelectedIndex:(NSInteger)selectedIndex{
    NSLog(@"--------didSelectedViewController------   %ld",(long)selectedIndex);
}
#pragma mark - event reponse
- (void)indexButtonClick {
    [self refreshWithIndex:4];
}
#pragma mark - getter
- (NSMutableArray *)colorArray {
    if (!_colorArray) {
        _colorArray = [NSMutableArray new];
        [_colorArray addObject:[UIColor blueColor]];
        [_colorArray addObject:[UIColor orangeColor]];
        [_colorArray addObject:[UIColor yellowColor]];
        [_colorArray addObject:[UIColor whiteColor]];
        [_colorArray addObject:[UIColor cyanColor]];
        [_colorArray addObject:[UIColor purpleColor]];
        [_colorArray addObject:[UIColor grayColor]];
        [_colorArray addObject:[UIColor greenColor]];
    }
    return _colorArray;
}
@end
