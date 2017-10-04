//
//  NumberTileGame.m
//  dmy2048
//
//  Created by dmy on 2017/10/4.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import "TileView.h"
#import "TileAppearanceProvider.h"

//类扩展  可以添加方法和属性
@interface TileView()
@property (nonatomic,readonly) UIColor *defaultBackgroufColor;
@property (nonatomic,readonly) UIColor *defaultNumberColor;

@property (nonatomic,strong) UILabel *numberLabel;
@property (nonatomic) NSUInteger value;

@end

@implementation TileView
+(instancetype) tileForPosition:(CGPoint)position sideLength:(CGFloat)side value:(NSUInteger)value cornerRadius:(CGFloat)cornerRadius{
    TileView *tile = [[[self class] alloc] initWithFrame:CGRectMake(position.x
                                                                    , position.y
                                                                    , side
                                                                    , side)];
    tile.tileValue = value;
    tile.backgroundColor = tile.defaultBackgroufColor;
    tile.numberLabel.textColor = tile.defaultNumberColor;
    tile.value = value;
    //圆角
    tile.layer.cornerRadius = cornerRadius;
    return tile;
}


-(id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (!self){
        return nil;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0
                                                               , 0
                                                               , frame.size.width
                                                               , frame.size.height)];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.minimumScaleFactor = 0.5;
    [self addSubview:label];
    self.numberLabel = label;
    return self;
}

-(void) setDelegate:(id<TileAppearanceProviderProtocol>)delegate{
    _delegate = delegate;
    if(delegate){
        self.backgroundColor = [delegate tileColorForValue:self.tileValue];
        self.numberLabel.textColor = [delegate numberColorForValue:self.tileValue];
        self.numberLabel.font = [delegate fontForNumbers];
    }
}

-(void) setTileValue:(NSInteger)tileValue{
    _tileValue = tileValue;
    //转成字符串
    self.numberLabel.text = [@(tileValue) stringValue];
    if(self.delegate){
        self.backgroundColor = [self.delegate tileColorForValue:tileValue];
        self.numberLabel.textColor = [self.delegate numberColorForValue:tileValue];
    }
    self.value = tileValue;
}

-(UIColor *)defaultNumberColor{
    return  [UIColor blackColor];
}
-(UIColor *)defaultBackgroufColor{
    return [UIColor lightGrayColor];
}

@end





















