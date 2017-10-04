//
//  TileModel.m
//  dmy2048
//
//  Created by dmy on 2017/10/4.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import "TileModel.h"

@implementation TileModel

+ (instancetype)emptyTile {
    TileModel *tile = [[self class] new];
    tile.empty = YES;
    tile.value = 0;
    return tile;
}

- (NSString *)description {
    if (self.empty) {
        return @"Tile (empty)";
    }
    return [NSString stringWithFormat:@"Tile (value: %lu)", (unsigned long)self.value];
}

@end
