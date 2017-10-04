//
//  ScoreView.h
//  dmy2048
//
//  Created by dmy on 2017/10/3.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreView : UIView

@property (nonatomic) NSInteger score;


+ (instancetype)scoreViewWithCornerRadius:(CGFloat)radius
                          backgroundColor:(UIColor *)color
                                textColor:(UIColor *)textColor
                                 textFont:(UIFont *)textFont;

@end
