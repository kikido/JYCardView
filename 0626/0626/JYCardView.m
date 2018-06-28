//
//  JYCardView.m
//  0626
//
//  Created by dqh on 2018/6/27.
//  Copyright © 2018年 dqh. All rights reserved.
//

#import "JYCardView.h"

#define JY_Screen_Width ([UIScreen mainScreen].bounds.size.width)
#define JY_Screen_Height ([UIScreen mainScreen].bounds.size.height)


@interface JYCardView()
@property (nonatomic, assign) float xLength;
@property (nonatomic, assign) float yLength;
@property (nonatomic, assign, readonly) CGPoint originCenter;

@property (nonatomic, strong) UIView *firstView;
@property (nonatomic, strong) UIView *secondView;
@property (nonatomic, strong) UIView *thirdView;
///|< 展示在最前面卡片的序号
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation JYCardView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.action_margin = 40.;
        self.currentIndex = 0;
        self.cardMargin = 7.0f;
        self.maxRotationAngle = M_PI_2;
        
        self.xLength = 0.;
        self.yLength = 0.;
        _originCenter = CGPointZero;
        
        self.firstView = nil;
        self.secondView = nil;
        self.thirdView = nil;
    }
    return self;
}

- (void)didMoveToSuperview
{
    NSInteger cardCount = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfCardsInCardView:)]) {
        cardCount = [self.dataSource numberOfCardsInCardView:self];
    }
    
    // 如果子视图的数量为0的话，则不添加子视图；如果数量大于0，则添加三个子视图
    UIView *subView = nil;
    if ([self.dataSource respondsToSelector:@selector(singleCardForCardView:)] && cardCount > 0) {
        subView = [self.dataSource singleCardForCardView:self];
                
        self.firstView = [self copyView:subView];
        self.secondView = [self copyView:subView];
        self.thirdView = [self copyView:subView];
        
        self.firstView.frame = self.bounds;
        self.secondView.frame = self.bounds;
        self.thirdView.frame = self.bounds;
        _originCenter = CGPointMake((self.bounds.origin.x + self.bounds.size.width)/2., (self.bounds.origin.y + self.bounds.size.height)/2.);
        
        [self addSubview:self.thirdView];
        [self addSubview:self.secondView];
        [self addSubview:self.firstView];
        
        if ([self.dataSource respondsToSelector:@selector(cardView:updateCard:AtIndex:)]) {
            [self.dataSource cardView:self updateCard:self.firstView AtIndex:0];
            [self.dataSource cardView:self updateCard:self.secondView AtIndex:cardCount > 1 ? 1 : 0];
            [self.dataSource cardView:self updateCard:self.thirdView AtIndex:cardCount > 2 ? 2 : 0];
            
            self.secondView.transform = CGAffineTransformMakeTranslation(self.cardMargin, -self.cardMargin);
            self.thirdView.transform = CGAffineTransformMakeTranslation(2*self.cardMargin, -2*self.cardMargin);
        }
    }
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(draggedAction:)];
    [self addGestureRecognizer:pan];
}

- (void)draggedAction:(UIPanGestureRecognizer *)sender
{
    BOOL canPan = YES;
    if ([self.delegate respondsToSelector:@selector(cardViewShouldPan:)]) {
        canPan = [self.delegate cardViewShouldPan:self];
    }
    
    if (!canPan) return;
    
    self.xLength = [sender translationInView:self].x;
    self.yLength = [sender translationInView:self].y;
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            if ([self.delegate respondsToSelector:@selector(cardViewWillBeginDragging:atIndex:)]) {
                [self.delegate cardViewWillBeginDragging:self atIndex:self.currentIndex];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat rotationAngle = self.maxRotationAngle * self.xLength / JY_Screen_Width;
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngle);
            
            self.firstView.center = CGPointMake(self.originCenter.x + _xLength, self.originCenter.y + _yLength);
            self.firstView.transform = transform;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self followUpActionWithXLength:_xLength yLength:_yLength velocity:[sender velocityInView:self.superview]];
            if ([self.delegate respondsToSelector:@selector(cardViewDidEndDragging:atIndex:)]) {
                [self.delegate cardViewDidEndDragging:self atIndex:self.currentIndex];
            }
        }
            break;
        default:break;
    }
}

- (void)followUpActionWithXLength:(CGFloat)xLength yLength:(CGFloat)yLength velocity:(CGPoint)velocity
{
    if (sqrt(pow(fabs(xLength), 2) + pow(fabs(yLength), 2)) > self.action_margin) {
        // 继续滑动

        // 运动方向与x轴的角度的绝对值
        CGFloat moveAngle = 0.;
        // firstView在当前window中的相对坐标
        UIWindow *currentWindow = [UIApplication sharedApplication].delegate.window;
        CGRect frameInWindow = [self convertRect:self.firstView.frame toView:currentWindow];
        CGPoint firstViewWindowCenter = CGPointMake((frameInWindow.origin.x + frameInWindow.size.width) / 2.,
                                                    (frameInWindow.origin.y + frameInWindow.size.height) / 2.);
        // firstview对角线长度
        CGFloat diagonalLength = sqrt(pow(self.bounds.size.width, 2) + pow(self.bounds.size.height, 2));
        
        if ((fabs(xLength - 0.) < 0.0000001 || fabs(yLength - 0.) < 0.0000001)) {
            // 如果运动方向为x轴或者y轴方向
            // 回到原位
            [UIView animateWithDuration:.4 animations:^{
                self.firstView.center = self.originCenter;
                self.firstView.transform = CGAffineTransformMakeRotation(0);
            }];
        } else {
            
            moveAngle = atan(fabs(yLength)/fabs(xLength));

            /*
             * 当x轴运动方向向左时，firstview的center到达屏幕边界时x轴还需要运动的距离为自己center的横坐标
             * 当x轴运动方向向右时，firstview的center到达屏幕边界时x轴还需要运动的距离为屏幕宽度减去自己center的横坐标
             */
            CGFloat xLeftLength = xLength > 0 ? JY_Screen_Width - firstViewWindowCenter.x : firstViewWindowCenter.x;
            // 在添加一个firstview对角线的长度，确保firstview能够移除当前屏幕范围
            CGFloat moveLength = xLeftLength / cos(moveAngle) + diagonalLength;
            // 在x轴跟y轴还需要运动的距离
            CGFloat xMoveLength = moveLength * cos(moveAngle);
            CGFloat yMoveLength = moveLength * sin(moveAngle);
            // 还需要转动的角度
            CGFloat rotationAngle =  xLength > 0 ? self.maxRotationAngle * (xLength + xMoveLength) / JY_Screen_Width : -self.maxRotationAngle * (-xLength + xMoveLength) / JY_Screen_Width;
            
            NSTimeInterval xTime = xMoveLength / velocity.x;
            NSTimeInterval yTime = yMoveLength / velocity.y;
            NSTimeInterval duration = MAX(fabs(xTime), fabs(yTime));
            
            if (duration >= 1.5) {
                duration = 1.5;
            } else if (duration >= 1.0) {
                duration = 1.0;
            } else {
                duration = .5;
            }
            
            NSInteger cardCount = [self.dataSource numberOfCardsInCardView:self];
            self.currentIndex++;
            // 第三个卡片代表的序号
            NSInteger temp = self.currentIndex + 2;
            while (temp >= cardCount && cardCount > 0) {
                temp -= cardCount;
                if (self.currentIndex >= cardCount) {
                    self.currentIndex -= cardCount;
                }
            }
            
            UIView *forthView = [self copyView:[self.dataSource singleCardForCardView:self]];
            forthView.frame = self.bounds;
            forthView.transform = CGAffineTransformMakeTranslation(3*self.cardMargin, -3*self.cardMargin);
            [self insertSubview:forthView belowSubview:self.thirdView];

            UIView *firstView = self.firstView;
            
            // 剩余卡片的向前进一格
            [UIView animateWithDuration:.2 animations:^{
                self.secondView.transform = CGAffineTransformMakeTranslation(0, 0);
                self.thirdView.transform = CGAffineTransformMakeTranslation(self.cardMargin, -self.cardMargin);
                forthView.transform = CGAffineTransformMakeTranslation(2*self.cardMargin, -2*self.cardMargin);
            } completion:^(BOOL finished) {
                self.firstView = self.secondView;
                self.secondView = self.thirdView;
                self.thirdView = forthView;
                
                [self.dataSource cardView:self updateCard:self.thirdView AtIndex:temp];
            }];

            // 卡片飞出的动画啊
            [UIView animateWithDuration:duration delay:0. options:UIViewAnimationOptionCurveEaseIn animations:^{
               
                firstView.center = CGPointMake(xLength >0 ? self.originCenter.x + xLength + xMoveLength : self.originCenter.x + xLength - xMoveLength,
                                               yLength > 0 ? self.originCenter.y + yLength + yMoveLength : self.originCenter.y + yLength - yMoveLength);
                firstView.transform = CGAffineTransformMakeRotation(rotationAngle);
                
            } completion:^(BOOL finished) {
                [firstView removeFromSuperview];
            }];
        }
    } else {
        // 回到原位
        [UIView animateWithDuration:.4 animations:^{
            self.firstView.center = self.originCenter;
            self.firstView.transform = CGAffineTransformMakeRotation(0);
        }];
    }
}

- (void)cardPopWithDirection:(JYCardViewDirection)direction
{
    // fitstView在当前window坐标系中的坐标
    UIWindow *currentWindow = [UIApplication sharedApplication].delegate.window;
    CGRect frameInWindow = [self convertRect:self.firstView.frame toView:currentWindow];
    CGPoint firstViewWindowCenter = CGPointMake((frameInWindow.origin.x + frameInWindow.size.width) / 2.,
                                                (frameInWindow.origin.y + frameInWindow.size.height) / 2.);
    // firstview对角线长度
    CGFloat diagonalLength = sqrt(pow(self.bounds.size.width, 2) + pow(self.bounds.size.height, 2));
    
    /*
     * 当x轴运动方向向左时，firstview的center到达屏幕边界时x轴还需要运动的距离为自己center的横坐标
     * 当x轴运动方向向右时，firstview的center到达屏幕边界时x轴还需要运动的距离为屏幕宽度减去自己center的横坐标
     */
    CGFloat xLeftLength = direction==JYCardViewDirectionLeft ? JY_Screen_Width - firstViewWindowCenter.x : firstViewWindowCenter.x;
    // 在添加一个firstview对角线的长度，确保firstview能够移除当前屏幕范围
    CGFloat moveLength = xLeftLength + diagonalLength;
    // 在x轴还需要运动的距离
    CGFloat xMoveLength = moveLength;
    // 还需要转动的角度
    CGFloat rotationAngle =  direction==JYCardViewDirectionLeft ? self.maxRotationAngle * xMoveLength / JY_Screen_Width : -self.maxRotationAngle * xMoveLength / JY_Screen_Width;
    
    NSTimeInterval duration = 0.8;
    
    NSInteger cardCount = [self.dataSource numberOfCardsInCardView:self];
    self.currentIndex++;
    // 第三个卡片代表的序号
    NSInteger temp = self.currentIndex + 2;
    while (temp >= cardCount && cardCount > 0) {
        temp -= cardCount;
        if (self.currentIndex >= cardCount) {
            self.currentIndex -= cardCount;
        }
    }
    
    UIView *forthView = [self copyView:[self.dataSource singleCardForCardView:self]];
    forthView.frame = self.bounds;
    forthView.transform = CGAffineTransformMakeTranslation(3*self.cardMargin, -3*self.cardMargin);
    [self insertSubview:forthView belowSubview:self.thirdView];
    
    UIView *firstView = self.firstView;
    
    // 剩余卡片的向前进一格
    [UIView animateWithDuration:.2 animations:^{
        self.secondView.transform = CGAffineTransformMakeTranslation(0, 0);
        self.thirdView.transform = CGAffineTransformMakeTranslation(self.cardMargin, -self.cardMargin);
        forthView.transform = CGAffineTransformMakeTranslation(2*self.cardMargin, -2*self.cardMargin);
    } completion:^(BOOL finished) {
        self.firstView = self.secondView;
        self.secondView = self.thirdView;
        self.thirdView = forthView;
        
        [self.dataSource cardView:self updateCard:self.thirdView AtIndex:temp];
    }];
    
    // 卡片飞出的动画啊
    [UIView animateWithDuration:duration delay:0. options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        firstView.center = CGPointMake(direction==JYCardViewDirectionLeft ? self.originCenter.x - xMoveLength : self.originCenter.x + xMoveLength,
                                       self.originCenter.y);
        firstView.transform = CGAffineTransformMakeRotation(rotationAngle);
        
    } completion:^(BOOL finished) {
        [firstView removeFromSuperview];
    }];
}

- (void)reloadData
{
    NSInteger cardCount = [self.dataSource numberOfCardsInCardView:self];
    if (cardCount <= 0) {
        return;
    }
    
    self.currentIndex = 0;
    [self.firstView removeFromSuperview];
    [self.secondView removeFromSuperview];
    [self.thirdView removeFromSuperview];
    
    if ([self.dataSource respondsToSelector:@selector(singleCardForCardView:)]) {
        UIView *subView = [self.dataSource singleCardForCardView:self];
        self.firstView = [self copyView:subView];
        self.secondView = [self copyView:subView];
        self.thirdView = [self copyView:subView];
        
        self.firstView.frame = self.bounds;
        self.secondView.frame = self.bounds;
        self.thirdView.frame = self.bounds;
        
        [self addSubview:self.thirdView];
        [self addSubview:self.secondView];
        [self addSubview:self.firstView];
        
        if ([self.dataSource respondsToSelector:@selector(cardView:updateCard:AtIndex:)]) {
            [self.dataSource cardView:self updateCard:self.firstView AtIndex:0];
            [self.dataSource cardView:self updateCard:self.secondView AtIndex:cardCount > 1 ? 1 : 0];
            [self.dataSource cardView:self updateCard:self.thirdView AtIndex:cardCount > 2 ? 2 : 0];
            
            self.secondView.transform = CGAffineTransformMakeTranslation(self.cardMargin, -self.cardMargin);
            self.thirdView.transform = CGAffineTransformMakeTranslation(2*self.cardMargin, -2*self.cardMargin);
        }
    }
}

- (UIView *)copyView:(UIView *)originView
{
    NSData *temp = [NSKeyedArchiver archivedDataWithRootObject:originView];
    return [NSKeyedUnarchiver unarchiveObjectWithData:temp];
}


@end
