//
//  JYCardView.h
//  0626
//
//  Created by dqh on 2018/6/27.
//  Copyright © 2018年 dqh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, JYCardViewDirection) {
    JYCardViewDirectionLeft,
    JYCardViewDirectionRight
};

@class JYCardView;

@protocol JYCardViewDelegate <NSObject>

@optional
- (BOOL)cardViewShouldPan:(JYCardView *)cardView;
- (void)cardViewWillBeginDragging:(JYCardView *)cardView atIndex:(NSInteger)index;
- (void)cardViewDidEndDragging:(JYCardView *)cardView atIndex:(NSInteger)index;
@end

@protocol JYCardViewDataSource <NSObject>

@required
- (NSInteger)numberOfCardsInCardView:(JYCardView *)cardView;
- (__kindof UIView *)singleCardForCardView:(JYCardView *)cardView;
- (void)cardView:(JYCardView *)cardView updateCard:(__kindof UIView*)card AtIndex:(NSInteger)index;
@end

@interface JYCardView : UIView

///|< 卡片运行一个屏幕的宽度旋转角度的绝对值，默认值为 m_pi_2
@property (nonatomic, assign) CGFloat maxRotationAngle;
///|< 卡片之间的距离，默认值为 7.0f
@property (nonatomic, assign) CGFloat cardMargin;
///|< 当拖动一段距离后，如果大于该属性的值，则继续朝那个方向运动直到飞出。默认值为 40.0f
@property (nonatomic, assign) CGFloat action_margin;
///|< 数据源
@property (nonatomic, weak) id<JYCardViewDataSource> dataSource;
///|< 代理
@property (nonatomic, weak) id<JYCardViewDelegate> delegate;

- (void)cardPopWithDirection:(JYCardViewDirection)direction;

- (void)reloadData;

@end
