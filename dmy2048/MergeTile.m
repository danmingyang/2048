//
//  MergeTile.m
//  dmy2048
//
//  Created by dmy on 2017/10/4.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import "MergeTile.h"

@implementation MergeTile

+(instancetype) mergeTile{
    return [[self class] new];
}

- (NSString *)description {
    NSString *modeStr;
    switch (self.mode) {
        case MergeTileModeEmpty:
            modeStr = @"Empty";
            break;
        case MergeTileModeNoAction:
            modeStr = @"NoAction";
            break;
        case MergeTileModeMove:
            modeStr = @"Move";
            break;
        case MergeTileModeSingleCombine:
            modeStr = @"SingleCombine";
            break;
        case MergeTileModeDoubleCombine:
            modeStr = @"DoubleCombine";
    }
    return [NSString stringWithFormat:@"MergeTile (mode: %@, source1: %ld, source2: %ld, value: %ld)",
            modeStr,
            (long)self.originalIndexA,
            (long)self.originalIndexB,
            (long)self.value];
}

@end
