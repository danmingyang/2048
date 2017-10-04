//
//  NumberTileGame.h
//  dmy2048
//
//  Created by dmy on 2017/10/4.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TileAppearanceProviderProtocol;

@interface TileView: UIView

@property (nonatomic) NSInteger tileValue;

@property (nonatomic,weak) id<TileAppearanceProviderProtocol> delegate;

+(instancetype)tileForPosition:(CGPoint) position
                    sideLength:(CGFloat) side
                         value:(NSUInteger) value
                  cornerRadius:(CGFloat) cornerRadius;
@end
