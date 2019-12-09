//
//  PPColorfulSlider.h
//  PPColorfulSlider
//
//  Created by 拍拍 on 2019/12/9.
//  Copyright © 2019 PaiPai Lian. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PPCOLOR(hex) [UIColor colorWithRed:((hex & 0xFF0000)>>16)/255.0  green:((hex & 0xFF00)>>8)/255.0 blue:(hex & 0xFF)/255.0 alpha:1.0]

@protocol PPColorfulSliderDelegate <NSObject>
/**
 @brief 监听值发生变化
 @param value 当前导轨的值，以整 minScoreUnit 处理
 */
- (void)sliderChangedValue:(NSInteger)value;

@end

@interface PPColorfulSlider : UISlider

/**
 @brief 滑块最低能滑到哪（非轨道最低值）。
 */
@property (nonatomic, assign) NSInteger minScrollValue;

/**
 @brief 滑块最高能滑到哪（非轨道最大值）。
 */
@property (nonatomic, assign) NSInteger maxScrollValue;

/**
 @brief 最小数量单位
 */
@property (nonatomic, assign) NSInteger minUnit;


@property (nonatomic, weak) id<PPColorfulSliderDelegate> delegate;

@end

