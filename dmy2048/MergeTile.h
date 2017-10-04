//
//  MergeTile.h
//  dmy2048
//
//  Created by dmy on 2017/10/4.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MergeTileModeEmpty = 0,
    MergeTileModeNoAction,
    MergeTileModeMove,
    MergeTileModeSingleCombine,
    MergeTileModeDoubleCombine
} MergeTileMode;

@interface MergeTile : NSObject


@property (nonatomic) MergeTileMode mode;
@property (nonatomic) NSInteger originalIndexA;
@property (nonatomic) NSInteger originalIndexB;
@property (nonatomic) NSInteger value;

+ (instancetype)mergeTile;

@end
