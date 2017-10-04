//
//  GameModel.m
//  NumberTileGame
//

#import "GameModel.h"

#import "MoveOrder.h"
#import "TileModel.h"
#import "MergeTile.h"
#import "QueueCommand.h"

// Command queue
#define MAX_COMMANDS      100
#define QUEUE_DELAY       0.3

@interface GameModel ()

@property (nonatomic, weak) id<GameModelProtocol> delegate;

@property (nonatomic, strong) NSMutableArray *gameState;

@property (nonatomic) NSUInteger dimension;
@property (nonatomic) NSUInteger winValue;

@property (nonatomic, strong) NSMutableArray *commandQueue;
@property (nonatomic, strong) NSTimer *queueTimer;

@property (nonatomic, readwrite) NSInteger score;

@end

@implementation GameModel

+ (instancetype)gameModelWithDimension:(NSUInteger)dimension
                              winValue:(NSUInteger)value
                              delegate:(id<GameModelProtocol>)delegate {
    GameModel *model = [GameModel new];
    model.dimension = dimension;
    model.winValue = value;
    model.delegate = delegate;
    [model reset];
    return model;
}

- (void)reset {
    self.score = 0;
    self.gameState = nil;
    [self.commandQueue removeAllObjects];
    [self.queueTimer invalidate];
    self.queueTimer = nil;
}

#pragma mark - Insertion API

- (void)insertAtRandomLocationTileWithValue:(NSUInteger)value {
    // Check if gameboard is full
    BOOL emptySpotFound = NO;
    for (NSInteger i=0; i<[self.gameState count]; i++) {
        if (((TileModel *) self.gameState[i]).empty) {
            emptySpotFound = YES;
            break;
        }
    }
    if (!emptySpotFound) {
        // Board is full, we will never be able to insert a tile
        return;
    }
    // Yes, this could run forever. Given the size of any practical gameboard, I don't think it's likely.
    NSInteger row = 0;
    BOOL shouldExit = NO;
    while (YES) {
        row = arc4random_uniform((uint32_t)self.dimension);
        // Check if row has any empty spots in column
        for (NSInteger i=0; i<self.dimension; i++) {
            if ([self tileForIndexPath:[NSIndexPath indexPathForRow:row inSection:i]].empty) {
                shouldExit = YES;
                break;
            }
        }
        if (shouldExit) {
            break;
        }
    }
    NSInteger column = 0;
    shouldExit = NO;
    while (YES) {
        column = arc4random_uniform((uint32_t)self.dimension);
        if ([self tileForIndexPath:[NSIndexPath indexPathForRow:row inSection:column]].empty) {
            shouldExit = YES;
            break;
        }
        if (shouldExit) {
            break;
        }
    }
    [self insertTileWithValue:value atIndexPath:[NSIndexPath indexPathForRow:row inSection:column]];
}

// Insert a tile (used by the game to add new tiles to the board)
- (void)insertTileWithValue:(NSUInteger)value
                atIndexPath:(NSIndexPath *)path {
    if (![self tileForIndexPath:path].empty) {
        return;
    }
    TileModel *tile = [self tileForIndexPath:path];
    tile.empty = NO;
    tile.value = value;
    [self.delegate insertTileAtIndexPath:path value:value];
}


#pragma mark - Movement API

// Perform a user-initiated move in one of four directions
- (void)performMoveInDirection:(MoveDirection)direction
               completionBlock:(void(^)(BOOL))completion {
    [self queueCommand:[QueueCommand commandWithDirection:direction completionBlock:completion]];
}

- (BOOL)performUpMove {
    BOOL atLeastOneMove = NO;
    
    // Examine each column, left to right ([]-->[]-->[])
    for (NSInteger column = 0; column<self.dimension; column++) {
        NSMutableArray *thisColumnTiles = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger row = 0; row<self.dimension; row++) {
            [thisColumnTiles addObject:[self tileForIndexPath:[NSIndexPath indexPathForRow:row inSection:column]]];
        }
        NSArray *ordersArray = [self mergeGroup:thisColumnTiles];
        if ([ordersArray count] > 0) {
            atLeastOneMove = YES;
            for (NSInteger i=0; i<[ordersArray count]; i++) {
                MoveOrder *order = ordersArray[i];
                if (order.doubleMove) {
                    // Update internal model
                    NSIndexPath *source1Path = [NSIndexPath indexPathForRow:order.source1 inSection:column];
                    NSIndexPath *source2Path = [NSIndexPath indexPathForRow:order.source2 inSection:column];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:order.destination inSection:column];
                    
                    TileModel *source1Tile = [self tileForIndexPath:source1Path];
                    source1Tile.empty = YES;
                    TileModel *source2Tile = [self tileForIndexPath:source2Path];
                    source2Tile.empty = YES;
                    TileModel *destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;
                    
                    // Update delegate
                    [self.delegate moveTileOne:source1Path
                                       tileTwo:source2Path
                                   toIndexPath:destinationPath
                                      newValue:order.value];
                }
                else {
                    // Update internal model
                    NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:order.source1 inSection:column];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:order.destination inSection:column];
                    
                    TileModel *sourceTile = [self tileForIndexPath:sourcePath];
                    sourceTile.empty = YES;
                    TileModel *destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;
                    
                    // Update delegate
                    [self.delegate moveTileFromIndexPath:sourcePath
                                             toIndexPath:destinationPath
                                                newValue:order.value];
                }
            }
        }
    }
    return atLeastOneMove;
}

- (BOOL)performDownMove {
    BOOL atLeastOneMove = NO;
    
    // Examine each column, left to right ([]-->[]-->[])
    for (NSInteger column = 0; column<self.dimension; column++) {
        NSMutableArray *thisColumnTiles = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger row = (self.dimension - 1); row >= 0; row--) {
            [thisColumnTiles addObject:[self tileForIndexPath:[NSIndexPath indexPathForRow:row inSection:column]]];
        }
        NSArray *ordersArray = [self mergeGroup:thisColumnTiles];
        if ([ordersArray count] > 0) {
            atLeastOneMove = YES;
            for (NSInteger i=0; i<[ordersArray count]; i++) {
                MoveOrder *order = ordersArray[i];
                NSInteger dim = self.dimension - 1;
                if (order.doubleMove) {
                    // Update internal model
                    NSIndexPath *source1Path = [NSIndexPath indexPathForRow:(dim - order.source1) inSection:column];
                    NSIndexPath *source2Path = [NSIndexPath indexPathForRow:(dim - order.source2) inSection:column];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:(dim - order.destination) inSection:column];
                    
                    TileModel *source1Tile = [self tileForIndexPath:source1Path];
                    source1Tile.empty = YES;
                    TileModel *source2Tile = [self tileForIndexPath:source2Path];
                    source2Tile.empty = YES;
                    TileModel *destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;
                    
                    // Update delegate
                    [self.delegate moveTileOne:source1Path
                                       tileTwo:source2Path
                                   toIndexPath:destinationPath
                                      newValue:order.value];
                }
                else {
                    // Update internal model
                    NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:(dim - order.source1) inSection:column];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:(dim - order.destination) inSection:column];
                    
                    TileModel *sourceTile = [self tileForIndexPath:sourcePath];
                    sourceTile.empty = YES;
                    TileModel *destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;
                    
                    // Update delegate
                    [self.delegate moveTileFromIndexPath:sourcePath
                                             toIndexPath:destinationPath
                                                newValue:order.value];
                }
            }
        }
    }
    return atLeastOneMove;
}

- (BOOL)performLeftMove {
    BOOL atLeastOneMove = NO;
    
    // Examine each row, up to down ([TTT] --> [---] --> [____])
    for (NSInteger row = 0; row<self.dimension; row++) {
        NSMutableArray *thisRowTiles = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger column = 0; column<self.dimension; column++) {
            [thisRowTiles addObject:[self tileForIndexPath:[NSIndexPath indexPathForRow:row inSection:column]]];
        }
        NSArray *ordersArray = [self mergeGroup:thisRowTiles];
        if ([ordersArray count] > 0) {
            atLeastOneMove = YES;
            for (NSInteger i=0; i<[ordersArray count]; i++) {
                MoveOrder *order = ordersArray[i];
                if (order.doubleMove) {
                    // Two tiles move and merge at the end of their moves.
                    // Update internal model
                    NSIndexPath *source1Path = [NSIndexPath indexPathForRow:row inSection:order.source1];
                    NSIndexPath *source2Path = [NSIndexPath indexPathForRow:row inSection:order.source2];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:row inSection:order.destination];
                    
                    TileModel *source1Tile = [self tileForIndexPath:source1Path];
                    source1Tile.empty = YES;
                    TileModel *source2Tile = [self tileForIndexPath:source2Path];
                    source2Tile.empty = YES;
                    TileModel *destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;
                    
                    // Update delegate
                    [self.delegate moveTileOne:source1Path
                                       tileTwo:source2Path
                                   toIndexPath:destinationPath
                                      newValue:order.value];
                }
                else {
                    // One tile moves, either to an empty spot or to merge with another tile.
                    // Update internal model
                    NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:row inSection:order.source1];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:row inSection:order.destination];
                    
                    TileModel *sourceTile = [self tileForIndexPath:sourcePath];
                    sourceTile.empty = YES;
                    TileModel *destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;
                    
                    // Update delegate
                    [self.delegate moveTileFromIndexPath:sourcePath
                                             toIndexPath:destinationPath
                                                newValue:order.value];
                }
            }
        }
    }
    return atLeastOneMove;
}

- (BOOL)performRightMove {
    BOOL atLeastOneMove = NO;
    
    // Examine each row, up to down ([TTT] --> [---] --> [____])
    for (NSInteger row = 0; row<self.dimension; row++) {
        NSMutableArray *thisRowTiles = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger column = (self.dimension - 1); column >= 0; column--) {
            [thisRowTiles addObject:[self tileForIndexPath:[NSIndexPath indexPathForRow:row inSection:column]]];
        }
        NSArray *ordersArray = [self mergeGroup:thisRowTiles];
        if ([ordersArray count] > 0) {
            NSInteger dim = self.dimension - 1;
            atLeastOneMove = YES;
            for (NSInteger i=0; i<[ordersArray count]; i++) {
                MoveOrder *order = ordersArray[i];
                if (order.doubleMove) {
                    // Update internal model
                    NSIndexPath *source1Path = [NSIndexPath indexPathForRow:row inSection:(dim - order.source1)];
                    NSIndexPath *source2Path = [NSIndexPath indexPathForRow:row inSection:(dim - order.source2)];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:row inSection:(dim - order.destination)];
                    
                    TileModel *source1Tile = [self tileForIndexPath:source1Path];
                    source1Tile.empty = YES;
                    TileModel *source2Tile = [self tileForIndexPath:source2Path];
                    source2Tile.empty = YES;
                    TileModel *destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;
                    
                    // Update delegate
                    [self.delegate moveTileOne:source1Path
                                       tileTwo:source2Path
                                   toIndexPath:destinationPath
                                      newValue:order.value];
                }
                else {
                    // Update internal model
                    NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:row inSection:(dim - order.source1)];
                    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:row inSection:(dim - order.destination)];
                    
                    TileModel *sourceTile = [self tileForIndexPath:sourcePath];
                    sourceTile.empty = YES;
                    TileModel *destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;
                    
                    // Update delegate
                    [self.delegate moveTileFromIndexPath:sourcePath
                                             toIndexPath:destinationPath
                                                newValue:order.value];
                }
            }
        }
    }
    return atLeastOneMove;
}


#pragma mark - Game State API

- (BOOL)userHasLost {
    for (NSInteger i=0; i<[self.gameState count]; i++) {
        if (((TileModel *) self.gameState[i]).empty) {
            // Gameboard must be full for the user to lose
            return NO;
        }
    }
    // This is a stupid algorithm, but given how small the game board is it should work just fine
    // Every tile compares its value to that of the tiles to the right and below (if possible)
    for (NSInteger i=0; i<self.dimension; i++) {
        for (NSInteger j=0; j<self.dimension; j++) {
            TileModel *tile = [self tileForIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            if (j != (self.dimension - 1)
                && tile.value == [self tileForIndexPath:[NSIndexPath indexPathForRow:i inSection:j+1]].value) {
                return NO;
            }
            if (i != (self.dimension - 1)
                && tile.value == [self tileForIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:j]].value) {
                return NO;
            }
        }
    }
    return YES;
}

- (NSIndexPath *)userHasWon {
    for (NSInteger i=0; i<[self.gameState count]; i++) {
        if (((TileModel *) self.gameState[i]).value == self.winValue) {
            return [NSIndexPath indexPathForRow:(i / self.dimension)
                                      inSection:(i % self.dimension)];
        }
    }
    return nil;
}


#pragma mark - Private Methods

- (void)queueCommand:(QueueCommand *)command {
    if (!command || [self.commandQueue count] > MAX_COMMANDS) return;
    
    [self.commandQueue addObject:command];
    if (!self.queueTimer || ![self.queueTimer isValid]) {
        // Timer isn't running, so fire the event immediately.
        [self timerFired:nil];
    }
}

- (void)timerFired:(NSTimer *)timer {
    if ([self.commandQueue count] == 0) return;
    
    BOOL changed = NO;
    while ([self.commandQueue count] > 0) {
        QueueCommand *command = [self.commandQueue firstObject];
        [self.commandQueue removeObjectAtIndex:0];
        switch (command.direction) {
            case MoveDirectionUp:
                changed = [self performUpMove];
                break;
            case MoveDirectionDown:
                changed = [self performDownMove];
                break;
            case MoveDirectionLeft:
                changed = [self performLeftMove];
                break;
            case MoveDirectionRight:
                changed = [self performRightMove];
                break;
        }
        if (command.completion) {
            command.completion(changed);
        }
        if (changed) {
            // This allows us to immediately remove 'useless' commands without gumming up the queue
            break;
        }
    }
    
    // Schedule the timer, so new moves aren't run immediately
    self.queueTimer = [NSTimer scheduledTimerWithTimeInterval:QUEUE_DELAY
                                                       target:self
                                                     selector:@selector(timerFired:)
                                                     userInfo:nil
                                                      repeats:NO];
}

- (TileModel *)tileForIndexPath:(NSIndexPath *)indexPath {
    NSInteger idx = (indexPath.row*self.dimension + indexPath.section);
    if (idx >= [self.gameState count]) {
        return nil;
    }
    return self.gameState[idx];
}

- (void)setTile:(TileModel *)tile forIndexPath:(NSIndexPath *)indexPath {
    NSInteger idx = (indexPath.row*self.dimension + indexPath.section);
    if (!tile || idx >= [self.gameState count]) {
        return;
    }
    self.gameState[idx] = tile;
}

- (NSMutableArray *)commandQueue {
    if (!_commandQueue) {
        _commandQueue = [NSMutableArray array];
    }
    return _commandQueue;
}

- (NSMutableArray *)gameState {
    if (!_gameState) {
        _gameState = [NSMutableArray array];
        for (NSInteger i=0; i<(self.dimension * self.dimension); i++) {
            [_gameState addObject:[TileModel emptyTile]];
        }
    }
    return _gameState;
}

- (void)setScore:(NSInteger)score {
    _score = score;
    [self.delegate scoreChanged:score];
}

// Merge some items to the left
// "Group" is an array of tile objects
- (NSArray *)mergeGroup:(NSArray *)group {
    NSInteger ctr = 0;
    // STEP 1: collapse all tiles (remove any interstital space)
    // e.g. |[2] [ ] [ ] [4]| becomes [[2] [4]|
    // At this point, tiles either move or don't move, and their value remains the same
    NSMutableArray *stack1 = [NSMutableArray array];
    for (NSInteger i=0; i<self.dimension; i++) {
        TileModel *tile = group[i];
        if (tile.empty) {
            // Don't do anything with empty tiles
            continue;
        }
        MergeTile *mergeTile = [MergeTile mergeTile];
        mergeTile.originalIndexA = i;
        mergeTile.value = tile.value;
        if (i == ctr) {
            mergeTile.mode = MergeTileModeNoAction;
        }
        else {
            mergeTile.mode = MergeTileModeMove;
        }
        [stack1 addObject:mergeTile];
        ctr++;
    }
    if ([stack1 count] == 0) {
        // Nothing to do, no tiles in this group
        return nil;
    }
    else if ([stack1 count] == 1) {
        // Only one tile in this group. Either it moved, or it didn't.
        if (((MergeTile *)stack1[0]).mode == MergeTileModeMove) {
            // Tile moved. Add one move order.
            MergeTile *mTile = (MergeTile *)stack1[0];
            return @[[MoveOrder singleMoveOrderWithSource:mTile.originalIndexA
                                                 destination:0
                                                    newValue:mTile.value]];
        }
        else {
            return nil;
        }
    }
    
    // STEP 2: starting from the left, and moving to the right, collapse tiles
    // e.g. |[8][8][4][2][2]| should become |[16][4][4]|
    // e.g. |[2][2][2]| should become |[4][2]|
    // At this point, tiles may become the subject of a single or double merge
    ctr = 0;
    BOOL priorMergeHasHappened = NO;
    NSMutableArray *stack2 = [NSMutableArray array];
    while (ctr < ([stack1 count] - 1)) {
        MergeTile *t1 = (MergeTile *)stack1[ctr];
        MergeTile *t2 = (MergeTile *)stack1[ctr+1];
        if (t1.value == t2.value) {
            // First: update t1 and t2's modes
            NSAssert(t1.mode != MergeTileModeSingleCombine && t2.mode != MergeTileModeSingleCombine
                     && t1.mode != MergeTileModeDoubleCombine && t2.mode != MergeTileModeDoubleCombine,
                     @"Should not be able to get in a state where already-combined tiles are recombined");
            
            // Merge the two
            if (t1.mode == MergeTileModeNoAction && !priorMergeHasHappened) {
                priorMergeHasHappened = YES;
                // t1 didn't move, but t2 merged onto t1.
                MergeTile *newT = [MergeTile mergeTile];
                newT.mode = MergeTileModeSingleCombine;
                newT.originalIndexA = t2.originalIndexA;
                newT.value = t1.value * 2;
                self.score += newT.value;
                [stack2 addObject:newT];
            }
            else {
                // t1 moved earlier.
                MergeTile *newT = [MergeTile mergeTile];
                newT.mode = MergeTileModeDoubleCombine;
                newT.originalIndexA = t1.originalIndexA;
                newT.originalIndexB = t2.originalIndexA;
                newT.value = t1.value * 2;
                self.score += newT.value;
                [stack2 addObject:newT];
            }
            ctr += 2;
        }
        else {
            // t1 is pushed onto stack2, as either a move or a no-op. The pointer is incremented
            [stack2 addObject:t1];
            if ([stack2 count] - 1 != ctr) {
                t1.mode = MergeTileModeMove;
            }
            ctr++;
        }
        // Addendum:
        if (ctr == [stack1 count] - 1) {
            // We're at the end of stack1, and need to add t2 as well as t1.
            MergeTile *item = stack1[ctr];
            [stack2 addObject:item];
            if ([stack2 count] - 1 != ctr) {
                item.mode = MergeTileModeMove;
            }
        }
    }
    
    // STEP 3: create move orders for each mergeTile that did change this round
    NSMutableArray *stack3 = [NSMutableArray new];
    for (NSInteger i=0; i<[stack2 count]; i++) {
        MergeTile *mTile = stack2[i];
        switch (mTile.mode) {
            case MergeTileModeEmpty:
            case MergeTileModeNoAction:
                continue;
            case MergeTileModeMove:
            case MergeTileModeSingleCombine:
                // Single combine
                [stack3 addObject:[MoveOrder singleMoveOrderWithSource:mTile.originalIndexA
                                                              destination:i
                                                                 newValue:mTile.value]];
                break;
            case MergeTileModeDoubleCombine:
                // Double combine
                [stack3 addObject:[MoveOrder doubleMoveOrderWithFirstSource:mTile.originalIndexA
                                                                  secondSource:mTile.originalIndexB
                                                                   destination:i
                                                                      newValue:mTile.value]];
                break;
        }
    }
    // Return the finalized array
    return [NSArray arrayWithArray:stack3];
}

@end
