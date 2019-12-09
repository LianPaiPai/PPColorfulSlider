//
//  PPColorfulSlider.m
//  PPColorfulSlider
//
//  Created by 拍拍 on 2019/12/9.
//  Copyright © 2019 PaiPai Lian. All rights reserved.
//

#import "PPColorfulSlider.h"

#define thumbBound_x 10
#define thumbBound_y 20

@interface PPColorfulSlider ()
@property (nonatomic, strong) UIView *thumbView;                    //slider的thumbView
@property (nonatomic, strong) UILabel *valueLabel;                  //显示value的label
@end
@implementation PPColorfulSlider

CGRect lastBounds;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (UIView *)thumbView {
    if (!_thumbView && self.subviews.count > 2) {
        _thumbView = self.subviews[2];
    }
    return _thumbView;
}

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.textColor = PPCOLOR(0xDDB155);
        _valueLabel.font = [UIFont boldSystemFontOfSize:18];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _valueLabel;
}

- (void)setMinScrollValue:(NSInteger)minScrollValue{
    _minScrollValue = minScrollValue;
}

- (void)setMaxScrollValue:(NSInteger)maxScrollValue{
    _maxScrollValue = maxScrollValue;
}

- (void)setValueText:(NSString *)valueText {
    self.valueLabel.text = valueText;
    [self.valueLabel sizeToFit];
    self.valueLabel.center = CGPointMake(self.thumbView.bounds.size.width / 2, - self.valueLabel.bounds.size.height / 2);
    
    if (!self.valueLabel.superview) {
        [self.thumbView addSubview:self.valueLabel];
    }
}

- (void)setValue:(float)value animated:(BOOL)animated {
    [super setValue:value animated:animated];
    [self sliderValueChanged:self];
}

- (void)setValue:(float)value {
    [super setValue:value];
    [self sliderValueChanged:self];
}

#pragma mark - Action functions

- (void)sliderValueChanged:(PPColorfulSlider *)sender {
    NSInteger nowValue = (int)sender.value / _minUnit * _minUnit;
    if (nowValue < _minScrollValue ) {
        sender.value = _minScrollValue;
        sender.valueText = [NSString stringWithFormat:@"%@", @(_minScrollValue)];
    }else if (nowValue > _maxScrollValue ) {
        sender.value = _maxScrollValue;
        sender.valueText = [NSString stringWithFormat:@"%@", @(_maxScrollValue)];
    }else{
        sender.valueText = [NSString stringWithFormat:@"%@", @(nowValue)];
    }
    
    if([_delegate respondsToSelector:@selector(sliderChangedValue:)]){
        [_delegate sliderChangedValue:nowValue];
    }
}

//重写滑轨高度
- (CGRect)trackRectForBounds:(CGRect)bounds{
    return CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

//解决滑钮在滑轨最左右两边的时候不重合问题
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value{
    rect.origin.x = rect.origin.x - 10;
    rect.size.width = rect.size.width + 20 ;
    CGRect result = [super thumbRectForBounds:bounds trackRect:rect value:value];
    lastBounds = result;
    return result;
}

//以下俩方法，扩大触摸区域
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *result = [super hitTest:point withEvent:event];
    if (point.x < 0 || point.x > self.bounds.size.width){
        return result;
    }
    if ((point.y >= -thumbBound_y) && (point.y < lastBounds.size.height + thumbBound_y)) {
        float value = 0.0;
        value = point.x - self.bounds.origin.x;
        value = value/self.bounds.size.width;
        value = value < 0? 0 : value;
        value = value > 1? 1: value;
        value = value * (self.maximumValue - self.minimumValue) + self.minimumValue;
        [self setValue:value animated:YES];
    }
    return result;
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    BOOL result = [super pointInside:point withEvent:event];
    if (!result && point.y > -10) {
        if ((point.x >= lastBounds.origin.x - thumbBound_x) && (point.x <= (lastBounds.origin.x + lastBounds.size.width + thumbBound_x)) && (point.y < (lastBounds.size.height + thumbBound_y))) {
            result = YES;
        }
    }
    return result;
}

@end
