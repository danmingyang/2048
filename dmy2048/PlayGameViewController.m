//
//  PlayGameViewController.m
//  dmy2048
//
//  Created by dmy on 2017/10/2.
//  Copyright © 2017年 dmy. All rights reserved.
//

#import "PlayGameViewController.h"
#import "Masonry.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

static GameViewController *gameView;

@interface PlayGameViewController ()
@end
@implementation PlayGameViewController

- (void)viewWillAppear:(BOOL) animated{
    [super viewWillAppear:animated];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.startBtn];
    [self.view addSubview:self.againBtn];
    
    
    self.startBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.againBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    __weak __typeof(self) weakSelf = self;
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_top).with.offset(170); //view_1的上，距离self.view是30px
        make.left.equalTo(weakSelf.view.mas_left).with.offset(10); //view_1的左，距离self.view是30px
    }];
    
    [self.againBtn  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.startBtn.mas_centerY).with.offset(0); //view2 Y方向上的中心线和view_1相等
        make.left.equalTo(self.startBtn.mas_right).with.offset(30); //view2 的左距离view_1的右距离为30px
        make.right.equalTo(weakSelf.view.mas_right).with.offset(-10); //view_2的右距离self.view30px
        make.width.equalTo(self.startBtn); //view_2的宽度和view_1相等
        make.height.equalTo(self.startBtn); //view_2的高度和view_1相等
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPlayView:) name:@"show_play_view" object:nil];
}

-(void)showPlayView:(id)sender{
    NSLog(@"重新开始");
    [gameView.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(UIButton *)startBtn{
    if(!_startBtn){
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _startBtn.backgroundColor = [UIColor greenColor];
        [_startBtn setTitle:@"开始" forState:UIControlStateNormal];
        [_startBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_startBtn addTarget:self action:@selector(startBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}
-(void) startBtnClick{
    NSLog(@"start    ");
    
    gameView = [GameViewController numberTileGameWithDimension:4
                                                                     winThreshold:2048
                                                                  backgroundColor:[UIColor whiteColor]
                                                                      scoreModule:YES
                                                                   buttonControls:NO
                                                                    swipeControls:YES];
    
    [self presentViewController:gameView animated:YES completion:nil];
    
}


-(UIButton *)againBtn{
    if(!_againBtn){
        _againBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _againBtn.backgroundColor = [UIColor greenColor];
        [_againBtn setTitle:@"重新开始" forState:UIControlStateNormal];
        [_againBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_againBtn addTarget:self action:@selector(startBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _againBtn;
}
-(void) againBtnClick{
    NSLog(@"again    ");
}

@end
