//
//  GameModel.h
//  dmy2048
//
//  Created by dmy on 2017/10/4.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum {
    MoveDirectionUp = 0,
    MoveDirectionDown,
    MoveDirectionLeft,
    MoveDirectionRight
} MoveDirection;

@protocol GameModelProtocol
-(void) scoreChanged:(NSInteger) newScore;
-(void) moveTileFromIndexPath:(NSIndexPath *)fromPath
                  toIndexPath:(NSIndexPath *)toPath
                     newValue:(NSUInteger)value;
-(void) moveTileOne:(NSIndexPath *)startA
            tileTwo:(NSIndexPath *)startB
        toIndexPath:(NSIndexPath *)end
           newValue:(NSUInteger) value;
-(void) insertTileAtIndexPath:(NSIndexPath *)path
                       value:(NSUInteger) value;

@end

@interface GameModel : NSObject

@property (nonatomic,readonly) NSInteger score;
+(instancetype) gameModelWithDimension:(NSUInteger) dimension
                              winValue:(NSUInteger) value
                              delegate:(id<GameModelProtocol>) delegate;
- (void)reset;

- (void)insertAtRandomLocationTileWithValue:(NSUInteger)value;

- (void)insertTileWithValue:(NSUInteger)value
                atIndexPath:(NSIndexPath *)path;

- (void)performMoveInDirection:(MoveDirection)direction
               completionBlock:(void(^)(BOOL))completion;

- (BOOL)userHasLost;
- (NSIndexPath *)userHasWon;

@end





















