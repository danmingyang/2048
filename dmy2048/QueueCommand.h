//
//  QueueCommand.h
//  dmy2048
//
//  Created by dmy on 2017/10/4.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameModel.h"

@interface QueueCommand : NSObject
@property (nonatomic) MoveDirection direction;
@property (nonatomic, copy) void(^completion)(BOOL atLeastOneMove);

+ (instancetype)commandWithDirection:(MoveDirection)direction completionBlock:(void(^)(BOOL))completion;

@end
