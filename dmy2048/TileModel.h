//
//  TileModel.h
//  dmy2048
//
//  Created by dmy on 2017/10/4.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TileModel : NSObject

@property (nonatomic) BOOL empty;
@property (nonatomic) NSUInteger value;
+ (instancetype)emptyTile;

@end
