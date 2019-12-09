//
//  ViewController.m
//  PPColorfulSlider
//
//  Created by 拍拍 on 2019/12/9.
//  Copyright © 2019 PaiPai Lian. All rights reserved.
//

#import "ViewController.h"

#import "Masonry.h"
#import "PPSliderDemoView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    PPSliderDemoView *view = [[PPSliderDemoView alloc]init];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).mas_offset(250);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(100);
    }];
}


@end
