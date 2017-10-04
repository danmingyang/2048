//
//  GameViewController.h
//  dmy2048
//
//  Created by dmy on 2017/10/2.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GameViewControllerProtocol <NSObject>
/*!
 Inform the delegate that the user completed a game.
 
 \param didWin   YES if the player won, NO otherwise
 \param score    the final score the player achieved
 */
- (void)gameFinishedWithVictory:(BOOL)didWin score:(NSInteger)score;
@end

@interface GameViewController : UIViewController

@property (nonatomic, weak) id<GameViewControllerProtocol>delegate;

/*!
 Return an instance of the number tile game view controller.
 
 \param dimension                how many tiles wide and high the gameboard should be
 \param threshold                the tile value the player must achieve to win the game (e.g. 2048)
 \param backgroundColor          the background color of the gameboard
 \param scoreModuleEnabled       if YES, the score module will be visible
 \param buttonControlsEnabled    if YES, the directional touch controls will be visible
 \param swipeControlsEnabled     if YES, performing swipe gestures will advance the game (not implemented yet)
 */
+ (instancetype)numberTileGameWithDimension:(NSUInteger)dimension
                               winThreshold:(NSUInteger)threshold
                            backgroundColor:(UIColor *)backgroundColor
                                scoreModule:(BOOL)scoreModuleEnabled
                             buttonControls:(BOOL)buttonControlsEnabled
                              swipeControls:(BOOL)swipeControlsEnabled;


@end
