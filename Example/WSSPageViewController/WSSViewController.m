//
//  WSSViewController.m
//  WSSPageViewController
//
//  Created by WSmilec on 02/20/2021.
//  Copyright (c) 2021 WSmilec. All rights reserved.
//

#import "WSSViewController.h"
#import "WSSTestViewController.h"
@interface WSSViewController ()

@end

@implementation WSSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *jumpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    jumpButton.frame = CGRectMake(20, 200, [UIScreen mainScreen].bounds.size.width-40, 50);
    jumpButton.backgroundColor = [UIColor cyanColor];
    [jumpButton addTarget:self action:@selector(jumpButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:jumpButton];
    
}

- (void)jumpButtonClick {
    WSSTestViewController *vc = [[WSSTestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
