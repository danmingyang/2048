//
//  GameboardView.m
//  dmy2048
//
//  Created by dmy on 2017/10/4.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import "GameboardView.h"
#import <QuartzCore/QuartzCore.h>
#import "TileView.h"
#import "TileAppearanceProvider.h"

#define PER_SQUARE_SLIDE_DURATION 0.08

#if DEBUG
#define DmyLOG(...) NSLog(__VA_ARGS__)
#else
#define DmyLOG(...)
#endif

// Animation parameters
#define TILE_POP_START_SCALE    0.1
#define TILE_POP_MAX_SCALE      1.1
#define TILE_POP_DELAY          0.05
#define TILE_EXPAND_TIME        0.18
#define TILE_RETRACT_TIME       0.08

#define TILE_MERGE_START_SCALE  1.0
#define TILE_MERGE_EXPAND_TIME  0.08
#define TILE_MERGE_RETRACT_TIME 0.08


@interface GameboardView()
@property (nonatomic,strong) NSMutableDictionary *boardTiles;
@property (nonatomic) NSUInteger dimension;
@property (nonatomic) CGFloat tileSideLength;
@property (nonatomic) CGFloat padding;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic,strong) TileAppearanceProvider *provider;

@end


@implementation GameboardView

+ (instancetype)gameboardWithDimension:(NSUInteger)dimension
                             cellWidth:(CGFloat)width
                           cellPadding:(CGFloat)padding
                          cornerRadius:(CGFloat)cornerRadius
                       backgroundColor:(UIColor *)backgroundColor
                       foregroundColor:(UIColor *)foregroundColor {
    CGFloat sideLength = padding + dimension *(width + padding);
    GameboardView *view = [[[self class] alloc] initWithFrame:CGRectMake(0, 0, sideLength, sideLength)];
    
    view.dimension = dimension;
    view.padding = padding;
    view.layer.cornerRadius = cornerRadius;
    view.tileSideLength = width;
    view.cornerRadius = cornerRadius;
    [view setupBackgroundWithBackgroundColor:backgroundColor
                             foregroundColor:foregroundColor];
    return view;
}

-(void) reset{
    for(NSString *key in self.boardTiles){
        TileView *view = self.boardTiles[key];
        [view removeFromSuperview];
    }
    [self.boardTiles removeAllObjects];
}

-(void)setupBackgroundWithBackgroundColor:(UIColor *)background
                          foregroundColor:(UIColor *)forground{
    self.backgroundColor = background;
    CGFloat xCursor = self.padding;
    CGFloat yCursor;
    CGFloat cornerRadius = self.cornerRadius - 2;
    if (cornerRadius < 0) {
        cornerRadius = 0;
    }
    for (NSInteger i = 0; i < self.dimension; i ++){
        yCursor = self.padding;
        for (NSInteger j = 0; j < self.dimension; j ++){
            UIView * bgTile = [[UIView alloc] initWithFrame:CGRectMake(xCursor, yCursor, self.tileSideLength, self.tileSideLength)];
            bgTile.layer.cornerRadius = cornerRadius;
            bgTile.backgroundColor = forground;
            [self addSubview:bgTile];
            yCursor += self.padding + self.tileSideLength;
        }
        xCursor += self.padding + self.tileSideLength;
    }
    
}

// Insert a tile, with the popping animation
-(void) insertTileAtIndexPath:(NSIndexPath *)path withValue:(NSUInteger)value{
    DmyLOG(@"Inserting tile at row %ld, column %ld", (long)path.row, (long)path.section);

    if(!path || path.row >= self.dimension ||
       path.section >= self.dimension ||
       self.boardTiles[path]){
        return;
    }
    CGFloat x = self.padding + path.section*(self.tileSideLength + self.padding);
    CGFloat y = self.padding + path.row*(self.tileSideLength + self.padding);
    CGPoint position = CGPointMake(x, y);
    CGFloat cornerRadius = self.cornerRadius - 2;
    if (cornerRadius < 0) {
        cornerRadius = 0;
    }
    TileView *tile = [TileView tileForPosition:position sideLength:self.tileSideLength value:value cornerRadius:cornerRadius];
    tile.delegate = self.provider;
    //对单位矩阵进行缩放
    tile.layer.affineTransform = CGAffineTransformMakeScale(TILE_POP_START_SCALE, TILE_POP_START_SCALE);
    [self addSubview:tile];
    self.boardTiles[path] = tile;
    //add a new
    [UIView animateWithDuration:TILE_EXPAND_TIME
                          delay:TILE_POP_DELAY
                        options:0
                     animations:^{
                         tile.layer.affineTransform = CGAffineTransformMakeScale(TILE_POP_MAX_SCALE,
                                                                                 TILE_POP_MAX_SCALE);
                     } completion:^(BOOL finished){
                         [UIView animateWithDuration:TILE_RETRACT_TIME animations:^{
                             tile.layer.affineTransform = CGAffineTransformIdentity;
                             
                         } completion:^(BOOL finished) {
                             
                         }];
                     }];
    
}

- (void)moveTileOne:(NSIndexPath *)startA
            tileTwo:(NSIndexPath *)startB
        toIndexPath:(NSIndexPath *)end
          withValue:(NSUInteger)value {
    DmyLOG(@"Moving tiles at row %ld, column %ld and row %ld, column %ld to destination row %ld, column %ld",
           (long)startA.row, (long)startA.section,
           (long)startB.row, (long)startB.section,
           (long)end.row, (long)end.section);
    
    if (!startA || !startB || !self.boardTiles[startA] || !self.boardTiles[startB]
        || end.row >= self.dimension
        || end.section >= self.dimension) {
        NSAssert(NO, @"Invalid two-tile move and merge");
        return;
    }
    
    TileView *tileA = self.boardTiles[startA];
    TileView *tileB = self.boardTiles[startB];
    
    CGFloat x = self.padding + end.section * (self.tileSideLength + self.padding);
    CGFloat y = self.padding + end.row*(self.tileSideLength + self.padding);
    CGRect finalFrame = tileA.frame;
    finalFrame.origin.x = x;
    finalFrame.origin.y = y;
 
    [self.boardTiles removeObjectForKey:startA];
    [self.boardTiles removeObjectForKey:startB];
    
    self.boardTiles[end] = tileA;
    
    [UIView animateWithDuration:(PER_SQUARE_SLIDE_DURATION*1)
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         tileA.frame = finalFrame;
                         tileB.frame = finalFrame;
                     }
                     completion:^(BOOL finished) {
                         tileA.tileValue = value;
                         if(!finished){
                             [tileB removeFromSuperview];
                             return ;
                         }
                         
                         tileA.layer.affineTransform = CGAffineTransformMakeScale(TILE_MERGE_START_SCALE, TILE_MERGE_START_SCALE);
                          [tileB removeFromSuperview];
                         [UIView animateWithDuration:TILE_MERGE_EXPAND_TIME
                                          animations:^{
                                              tileA.layer.affineTransform = CGAffineTransformMakeScale(TILE_POP_MAX_SCALE,
                                                                                                       TILE_POP_MAX_SCALE);
                                          } completion:^(BOOL finished) {
                                              [UIView animateWithDuration:TILE_MERGE_RETRACT_TIME
                                                               animations:^{
                                                                   tileA.layer.affineTransform = CGAffineTransformIdentity;
                                                               } completion:^(BOOL finished) {
                                                                   // nothing yet
                                                               }];
                                          }];
                     }];
    
}

-(void) moveTileAtIndexPath:(NSIndexPath *)start toIndexPath:(NSIndexPath *)end withValue:(NSUInteger)value{
    DmyLOG(@"Moving tile at row %ld, column %ld to destination row %ld, column %ld",
           (long)start.row, (long)start.section, (long)end.row, (long)end.section);
    if (!start || !end || !self.boardTiles[start]
        || end.row >= self.dimension
        || end.section >= self.dimension) {
        NSAssert(NO, @"Invalid one-tile move and merge");
        return;
    }
    
    TileView *tile = self.boardTiles[start];
    TileView *endTile = self.boardTiles[end];
    
    BOOL shouldPop = endTile != nil;
    CGFloat x = self.padding + end.section*(self.tileSideLength + self.padding);
    CGFloat y = self.padding + end.row*(self.tileSideLength + self.padding);
    CGRect finalFrame = tile.frame;
    finalFrame.origin.x = x;
    finalFrame.origin.y = y;
    
    [self.boardTiles removeObjectForKey:start];
    self.boardTiles[end] = tile;
    
    [UIView animateWithDuration:PER_SQUARE_SLIDE_DURATION
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         tile.frame = finalFrame;
                     }
                     completion:^(BOOL finished) {
                         tile.tileValue = value;
                         if(!shouldPop
                            || !finished){
                             return ;
                         }
                         tile.layer.affineTransform = CGAffineTransformMakeScale(TILE_MERGE_START_SCALE,
                                                                                 TILE_MERGE_START_SCALE);
                         [endTile removeFromSuperview];
                         [UIView animateWithDuration:TILE_MERGE_EXPAND_TIME
                                           animations:^{
                                               tile.layer.affineTransform = CGAffineTransformMakeScale(TILE_POP_MAX_SCALE,
                                                                                                       TILE_POP_MAX_SCALE);
                                           } completion:^(BOOL finished) {
                                               [UIView animateWithDuration:TILE_MERGE_RETRACT_TIME
                                                                animations:^{
                                                                    tile.layer.affineTransform = CGAffineTransformIdentity;
                                                                } completion:^(BOOL finished) {
                                                                    // nothing yet
                                                                }];
                      
                          }];
      }];
}

- (TileAppearanceProvider *)provider {
    if (!_provider) {
        _provider = [TileAppearanceProvider new];
    }
    return _provider;
}

- (NSMutableDictionary *)boardTiles {
    if (!_boardTiles) {
        _boardTiles = [NSMutableDictionary dictionary];
    }
    return _boardTiles;
}
@end




























