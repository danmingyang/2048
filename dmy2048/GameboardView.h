//
//  GameboardView.h
//  dmy2048
//
//  Created by dmy on 2017/10/4.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameboardView : UIView

+ (instancetype)gameboardWithDimension:(NSUInteger)dimension
                             cellWidth:(CGFloat)width
                           cellPadding:(CGFloat)padding
                          cornerRadius:(CGFloat)cornerRadius
                       backgroundColor:(UIColor *)backgroundColor
                       foregroundColor:(UIColor *)foregroundColor;

- (void)reset;

- (void)insertTileAtIndexPath:(NSIndexPath *)path
                    withValue:(NSUInteger)value;

- (void)moveTileOne:(NSIndexPath *)startA
            tileTwo:(NSIndexPath *)startB
        toIndexPath:(NSIndexPath *)end
          withValue:(NSUInteger)value;

- (void)moveTileAtIndexPath:(NSIndexPath *)start
                toIndexPath:(NSIndexPath *)end
                  withValue:(NSUInteger)value;

@end
