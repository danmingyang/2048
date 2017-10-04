//
//  ScoreView.m
//  dmy2048
//
//  Created by dmy on 2017/10/3.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import "ScoreView.h"
#define DEFAULT_FRAME CGRectMake(0,0,140,40)

@interface ScoreView()
@property (nonatomic,strong) UILabel *scoreLabel;

@end

@implementation ScoreView

+ (instancetype)scoreViewWithCornerRadius:(CGFloat)radius
                          backgroundColor:(UIColor *)color
                                textColor:(UIColor *)textColor
                                 textFont:(UIFont *)textFont {
    ScoreView *view  = [[[self class] alloc] initWithFrame:DEFAULT_FRAME];
    view.score = 0;
    view.layer.cornerRadius = radius;
    view.backgroundColor = color ?:[UIColor whiteColor];
    view.userInteractionEnabled = YES;
    
    if (textColor){
        view.scoreLabel.textColor = textColor;
    }
    if(textFont){
        view.scoreLabel.font = textFont;
    }
    return view;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame:frame];
    //文本的在文本框的显示位置
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    //文字过长时的现实方式
    scoreLabel.lineBreakMode = NSLineBreakByWordWrapping;
    //文本框是否允许多行（布局相关）
    scoreLabel.numberOfLines = 0;
    //设置是否是高亮
    scoreLabel.highlighted=YES;
    //高亮颜色
    scoreLabel.highlightedTextColor=[UIColor redColor];
    //设置阴影颜色
    scoreLabel.shadowColor=[UIColor blueColor];
    //阴影偏移量
    scoreLabel.shadowOffset=CGSizeMake(0.5, 0.5);
    [self addSubview:scoreLabel];
    self.scoreLabel = scoreLabel;
    return self;
}
-(void) setScore:(NSInteger)score{
    _score = score;
    self.scoreLabel.text = [NSString stringWithFormat:@"SCORE :%ld",(long)score];
}
@end










