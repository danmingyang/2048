//
//  ControlView.h
//  dmy2048
//
//  Created by dmy on 2017/10/4.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ControlViewProtocol

-(void) upButtonTapped;
-(void) downButtonTapped;
-(void) leftButtonTapped;
-(void) rightButtonTapped;
-(void) resetButtonTapped;
-(void) exitButtonTapped;

@end

@interface ControlView : UIView

+ (instancetype)controlViewWithCornerRadius:(CGFloat)radius
                            backgroundColor:(UIColor *)color
                            movementButtons:(BOOL)moveButtonsEnabled
                                 exitButton:(BOOL)exitButtonEnabled
                                   delegate:(id<ControlViewProtocol>)delegate;
@end
