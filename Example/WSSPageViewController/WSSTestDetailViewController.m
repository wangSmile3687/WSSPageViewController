//
//  WSSTestDetailViewController.m
//  WSSPageViewController_Example
//
//  Created by wangsi1 on 2021/2/20.
//  Copyright © 2021 WSmilec. All rights reserved.
//

#import "WSSTestDetailViewController.h"

@interface WSSTestDetailViewController ()
@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation WSSTestDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.titleLab];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"-viewWillAppear-----SFTestDetailViewController------  %@",self.titleLab.text);
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"-viewWillDisappear-----SFTestDetailViewController------ %@",self.titleLab.text);
}
- (void)dealloc {
    NSLog(@"-dealloc-----SFTestDetailViewController------");
}


- (void)setTitleStr:(NSString *)titleStr {
    _titleStr = titleStr;
    
    self.titleLab.text = titleStr;
}
#pragma mark - getter
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, [UIScreen mainScreen].bounds.size.width-40, 40)];
        _titleLab.textColor = [UIColor redColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.font = [UIFont systemFontOfSize:16];
    }
    return _titleLab;
}

@end
