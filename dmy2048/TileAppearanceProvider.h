//
//  TileAppearanceProviderProtocol.h
//  dmy2048
//
//  Created by dmy on 2017/10/4.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TileAppearanceProviderProtocol <NSObject>

- (UIColor *)tileColorForValue:(NSUInteger) value;
-(UIColor *) numberColorForValue:(NSUInteger) value;
-(UIFont *) fontForNumbers;

@end

@interface TileAppearanceProvider: NSObject <TileAppearanceProviderProtocol>

@end
