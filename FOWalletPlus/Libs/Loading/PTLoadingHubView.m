//
//  PTLoadingHubView.m
//  网络加载动画
//
//  Created by 天蓝 on 2017/2/21.
//  Copyright © 2017年 PT. All rights reserved.
//

#import "PTLoadingHubView.h"

// 圆的直径
#define BALL_RADIUS 20
// 圆的颜色
#define BALL_COLOR [UIColor whiteColor]

// hubView的宽度
#define WIDTH  self.frame.size.width
// hubView的高度
#define HEIGHT self.frame.size.height

// 屏幕宽度
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏幕高度
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


@interface PTLoadingHubView ()<CAAnimationDelegate>
@property (nonatomic, strong) UIView *ball_1;
@property (nonatomic, strong) UIView *ball_2;
@property (nonatomic, strong) UIView *ball_3;
@property (nonatomic, assign) CGPoint centerPoint;
@end

@implementation PTLoadingHubView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIVisualEffectView *bgView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        bgView.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue: 0.08 alpha: 0.8f];
        bgView.frame = CGRectMake(kScreenWidth / 2 - 60, kScreenHeight / 2 - 60, 120, 120);
        bgView.layer.cornerRadius = BALL_RADIUS / 2;
        bgView.clipsToBounds = YES;
        [self addSubview:bgView];
        
        [self creatBall];
        [self createBezierPath_1];
        [self createBezierPath_3];
    }
    return self;
}

- (void)creatBall
{
    CGFloat centerPointX = WIDTH / 2;
    CGFloat centerPointY = HEIGHT / 2;
    self.centerPoint = CGPointMake(centerPointX, centerPointY);
    
    UIView *ball_1 = [[UIView alloc] initWithFrame:CGRectMake(centerPointX - BALL_RADIUS * 1.5, centerPointY - BALL_RADIUS * 0.5, BALL_RADIUS, BALL_RADIUS)];
    ball_1.layer.cornerRadius = BALL_RADIUS / 2;
    ball_1.layer.backgroundColor = BALL_COLOR.CGColor;
    [self addSubview:ball_1];
    self.ball_1 = ball_1;
    
    UIView *ball_2 = [[UIView alloc] initWithFrame:CGRectMake(centerPointX - BALL_RADIUS * 0.5, centerPointY - BALL_RADIUS * 0.5, BALL_RADIUS, BALL_RADIUS)];
    ball_2.layer.cornerRadius = BALL_RADIUS / 2;
    ball_2.layer.backgroundColor = BALL_COLOR.CGColor;
    [self addSubview:ball_2];
    self.ball_2 = ball_2;
    
    UIView *ball_3 = [[UIView alloc] initWithFrame:CGRectMake(centerPointX + BALL_RADIUS * 0.5, centerPointY - BALL_RADIUS * 0.5, BALL_RADIUS, BALL_RADIUS)];
    ball_3.layer.cornerRadius = BALL_RADIUS / 2;
    ball_3.layer.backgroundColor = BALL_COLOR.CGColor;
    [self addSubview:ball_3];
    self.ball_3 = ball_3;
}

- (void)createBezierPath_1
{
    UIBezierPath *path_1 = [UIBezierPath bezierPath];
    [path_1 moveToPoint:self.ball_1.center];
    [path_1 addArcWithCenter:self.centerPoint radius:BALL_RADIUS startAngle:M_PI endAngle:M_PI * 2 clockwise:NO];
    UIBezierPath *path_1_1 = [UIBezierPath bezierPath];
    [path_1_1 addArcWithCenter:self.centerPoint radius:BALL_RADIUS startAngle:0 endAngle:M_PI clockwise:NO];
    [path_1 appendPath:path_1_1];
    
    
    CAKeyframeAnimation *animation_ball_1 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation_ball_1.path = path_1.CGPath;
    animation_ball_1.removedOnCompletion = NO;
    animation_ball_1.fillMode = kCAFillModeForwards;
    animation_ball_1.calculationMode = kCAAnimationCubic;
    animation_ball_1.repeatCount = 1;
    animation_ball_1.duration = 1.4;
    animation_ball_1.delegate = self;
    animation_ball_1.autoreverses = NO;
    animation_ball_1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.ball_1.layer addAnimation:animation_ball_1 forKey:@"animation"];
}


- (void)createBezierPath_3
{
    UIBezierPath *path_3 = [UIBezierPath bezierPath];
    [path_3 moveToPoint:self.ball_3.center];
    [path_3 addArcWithCenter:self.centerPoint radius:BALL_RADIUS startAngle:0 endAngle:M_PI clockwise:NO];
    UIBezierPath *path_3_1 = [UIBezierPath bezierPath];
    [path_3_1 addArcWithCenter:self.centerPoint radius:BALL_RADIUS startAngle:M_PI endAngle:M_PI * 2 clockwise:NO];
    [path_3 appendPath:path_3_1];
    
    
    CAKeyframeAnimation *animation_ball_3 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation_ball_3.path = path_3.CGPath;
    animation_ball_3.removedOnCompletion = NO;
    animation_ball_3.fillMode = kCAFillModeForwards;
    animation_ball_3.calculationMode = kCAAnimationCubic;
    animation_ball_3.repeatCount = 1;
    animation_ball_3.duration = 1.4;
    animation_ball_3.autoreverses = NO;
    animation_ball_3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.ball_3.layer addAnimation:animation_ball_3 forKey:@"animation"];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim
{
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState  animations:^{
        CGFloat scale = 0.7;
        
        // 球1和球3 位移
        self.ball_1.transform = CGAffineTransformMakeTranslation(-BALL_RADIUS, 0);
        self.ball_1.transform = CGAffineTransformScale(self.ball_1.transform, scale, scale);
        
        self.ball_3.transform = CGAffineTransformMakeTranslation(BALL_RADIUS, 0);
        self.ball_3.transform = CGAffineTransformScale(self.ball_3.transform, scale, scale);
        
        // 三个球的大小
        self.ball_2.transform = CGAffineTransformScale(self.ball_2.transform, scale, scale);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            self.ball_1.transform = CGAffineTransformIdentity;
            self.ball_2.transform = CGAffineTransformIdentity;
            self.ball_3.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self createBezierPath_1];
    [self createBezierPath_3];
}

+ (void)show
{
    PTLoadingHubView *hubView = [[PTLoadingHubView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow addSubview:hubView];
    });
}

+ (void)dismiss
{
    for (UIView *subview in [UIApplication sharedApplication].keyWindow.subviews)
    {
        if ([subview isKindOfClass:self]) {
            [subview removeFromSuperview];
        }
    }
}

@end
