//
//  QueueCommand.m
//  dmy2048
//
//  Created by dmy on 2017/10/4.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import "QueueCommand.h"

@implementation QueueCommand

+ (instancetype)commandWithDirection:(MoveDirection)direction
                     completionBlock:(void(^)(BOOL))completion {
    QueueCommand *command = [[self class] new];
    command.direction = direction;
    command.completion = completion;
    return command;
}

@end
