//
//  PPSliderDemoView.m
//  PPColorfulSlider
//
//  Created by 拍拍 on 2019/12/9.
//  Copyright © 2019 PaiPai Lian. All rights reserved.
//

#import "PPSliderDemoView.h"

#import "Masonry.h"
#import "PPColorfulSlider.h"

@interface PPSliderDemoView()<PPColorfulSliderDelegate>
//slider相关
@property (nonatomic, strong) PPColorfulSlider *slider;                     //滑块
@property (nonatomic, strong) UIColor *startColor;                          //滑块渐变色，起始
@property (nonatomic, strong) UIColor *endColor;                            //滑块渐变色，结束
@property (nonatomic, strong) UIButton *sliderLeftBtn;                      //滑块左按钮
@property (nonatomic, strong) UIButton *sliderRightBtn;                     //滑块右按钮
@property (nonatomic, strong) NSTimer *leftBtnTimer;
@property (nonatomic, strong) NSTimer *rightBtnTimer;

@property (nonatomic, assign) NSInteger minNumber;                          //导轨最低值
@property (nonatomic, assign) NSInteger maxNumber;                          //导轨最大值
@property (nonatomic, assign) NSInteger minCouldSliderNumber;               //滑块可滑最低值
@property (nonatomic, assign) NSInteger maxCouldSliderNumber;               //滑块可滑最大值
@property (nonatomic, assign) NSInteger minSliderUnit;                      //最小单位
@end



@implementation PPSliderDemoView

- (instancetype)init{
    if (self = [super init]) {
        _minNumber = 0;
        _maxNumber = 1000;
        
        _minCouldSliderNumber = 200;
        _maxCouldSliderNumber = 800;
        _minSliderUnit = 10;
        
        
        _startColor = PPCOLOR(0xFFDA9B);
        _endColor = PPCOLOR(0xFFAB3D);
        
        [self initSubView];
    }
    return self;
}

- (void)initSubView{
    UIView *backView = [[UIView alloc]init];
    backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).mas_equalTo(10);
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(100);
    }];

    _slider = [[PPColorfulSlider alloc]init];
    _slider.delegate = self;
    _slider.minimumValue = _minNumber;                                   //滑轨最低值
    _slider.maximumValue = _maxNumber;                                   //滑轨最高值
    _slider.minUnit = _minSliderUnit;
    [self addSubview:_slider];
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(backView);
        make.size.mas_equalTo(CGSizeMake(245, 5));
    }];
    NSArray *colors = @[_startColor,_endColor];
    //获得渐变色image
    UIImage *img = [self getGradientImageWithColors:colors imgSize:CGSizeMake(245, 6)];
    //获得添加圆角后的image
    UIImage *sliderTrackImg = [self imageWithCornerRadius:3 image:img];
    //resizableImageWithCapInsets 这个方法是必须的
    [_slider setMinimumTrackImage:[sliderTrackImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 0)] forState:UIControlStateNormal];
    [_slider setThumbImage:[UIImage imageNamed:@"slider_handle"] forState:UIControlStateNormal];
    _slider.minScrollValue = _minCouldSliderNumber;                      //滑块可滑动的最小值
    _slider.maxScrollValue = _maxCouldSliderNumber;                      //滑块可滑动的最小值
    [_slider setValue:_minCouldSliderNumber animated:YES];               //设置初始购买值，务必用带animated的方法

    _sliderLeftBtn = [[UIButton alloc]init];
    [_sliderLeftBtn setImage:[UIImage imageNamed:@"slider_min_Unablebtn"] forState:UIControlStateNormal];
    [_sliderLeftBtn setImage:[UIImage imageNamed:@"slider_min_Unablebtn"] forState:UIControlStateHighlighted];

    [_sliderLeftBtn addTarget:self action:@selector(startLetfBtnTimer) forControlEvents:UIControlEventTouchDown];
    [_sliderLeftBtn addTarget:self action:@selector(stopLeftTimer) forControlEvents:UIControlEventTouchCancel];
    [_sliderLeftBtn addTarget:self action:@selector(stopLeftTimer) forControlEvents:UIControlEventTouchUpOutside];
    [_sliderLeftBtn addTarget:self action:@selector(stopLeftTimer) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:_sliderLeftBtn];
    [_sliderLeftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_slider.mas_left).mas_offset(-5);
        make.centerY.mas_equalTo(_slider);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    _sliderRightBtn = [[UIButton alloc]init];
    [_sliderRightBtn setImage:[UIImage imageNamed:@"slider_plus_btn"] forState:UIControlStateNormal];
    [_sliderRightBtn setImage:[UIImage imageNamed:@"slider_plus_btn_hl"] forState:UIControlStateHighlighted];
    if (_maxNumber == _minCouldSliderNumber) {
        [_sliderRightBtn setImage:[UIImage imageNamed:@"slider_plus_Unablebtn"] forState:UIControlStateNormal];
        [_sliderRightBtn setImage:[UIImage imageNamed:@"slider_plus_Unablebtn"] forState:UIControlStateHighlighted];
    }
    [_sliderRightBtn addTarget:self action:@selector(startRightBtnTimer) forControlEvents:UIControlEventTouchDown];
    [_sliderRightBtn addTarget:self action:@selector(stopRightTimer) forControlEvents:UIControlEventTouchCancel];
    [_sliderRightBtn addTarget:self action:@selector(stopRightTimer) forControlEvents:UIControlEventTouchUpOutside];
    [_sliderRightBtn addTarget:self action:@selector(stopRightTimer) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sliderRightBtn];
    [_sliderRightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_slider.mas_right).mas_offset(5);
        make.centerY.mas_equalTo(_slider);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
}

#pragma mark - 点击积分增加按钮
- (void)startRightBtnTimer{
    if (!_rightBtnTimer) {
        _rightBtnTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(clickPlusBtn) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_rightBtnTimer forMode:NSRunLoopCommonModes];
    }
}
- (void)stopRightTimer{
    if (_rightBtnTimer) {
        [_rightBtnTimer invalidate];
        _rightBtnTimer = nil;
    }
}
- (void)clickPlusBtn{
    if (_slider.value >= _maxCouldSliderNumber) {
        return;
    }else if(_slider.value + _minSliderUnit >= _maxCouldSliderNumber){
        _slider.value = _maxCouldSliderNumber;
    }else{
        _slider.value = _slider.value + _minSliderUnit;
    }
}

#pragma mark - 点击积分减少按钮
- (void)startLetfBtnTimer{
    if (!_leftBtnTimer) {
        _leftBtnTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(clickMinBtn) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_leftBtnTimer forMode:NSRunLoopCommonModes];
    }
}
- (void)stopLeftTimer{
    if (_leftBtnTimer) {
        [_leftBtnTimer invalidate];
        _leftBtnTimer = nil;
    }
}
- (void)clickMinBtn{
    if (_slider.value <= 0 ) {
        return;
    }else if(_slider.value - _minSliderUnit <= 0){
        _slider.value = 0;
    }else{
        _slider.value = _slider.value - _minSliderUnit;
    }
}

#pragma mark - MFScorePurchaseSliderDelegate，监听导轨值改变
- (void)sliderChangedValue:(NSInteger)value{
    if (value <= _minCouldSliderNumber) {
        [_sliderLeftBtn setImage:[UIImage imageNamed:@"slider_min_Unablebtn"] forState:UIControlStateNormal];
        [_sliderLeftBtn setImage:[UIImage imageNamed:@"slider_min_Unablebtn"] forState:UIControlStateHighlighted];
    }else{
        [_sliderLeftBtn setImage:[UIImage imageNamed:@"slider_min_btn"] forState:UIControlStateNormal];
        [_sliderLeftBtn setImage:[UIImage imageNamed:@"slider_min_btn_hl"] forState:UIControlStateHighlighted];
    }
    if (value >= _maxCouldSliderNumber) {
        [_sliderRightBtn setImage:[UIImage imageNamed:@"slider_plus_Unablebtn"] forState:UIControlStateNormal];
        [_sliderRightBtn setImage:[UIImage imageNamed:@"slider_plus_Unablebtn"] forState:UIControlStateHighlighted];
    }else{
        [_sliderRightBtn setImage:[UIImage imageNamed:@"slider_plus_btn"] forState:UIControlStateNormal];
        [_sliderRightBtn setImage:[UIImage imageNamed:@"slider_plus_btn_hl"] forState:UIControlStateHighlighted];
    }
}

#pragma mark - 处理渐变色圆角滑轨
- (UIImage *)getGradientImageWithColors:(NSArray*)colors imgSize:(CGSize)imgSize{
    NSMutableArray *arRef = [NSMutableArray array];
    for(UIColor *ref in colors) {
        [arRef addObject:(id)ref.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(imgSize, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)arRef, NULL);
    CGPoint start = CGPointMake(0.0, 0.0);
    CGPoint end = CGPointMake(imgSize.width, imgSize.height);
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage*)imageWithCornerRadius:(CGFloat)radius image:(UIImage *)image{
    // 开始图形上下文
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    // 获得图形上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 设置一个范围
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    // 根据radius的值画出路线
    CGContextAddPath(ctx, [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(radius, radius)].CGPath);
    // 裁剪
    CGContextClip(ctx);
    // 将原照片画到图形上下文
    [image drawInRect:rect];
    // 从上下文上获取剪裁后的照片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭上下文
    UIGraphicsEndImageContext();
    return newImage;
}

@end
