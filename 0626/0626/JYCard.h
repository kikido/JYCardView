//
//  JYCard.h
//  0626
//
//  Created by dqh on 2018/6/27.
//  Copyright © 2018年 dqh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PeopleMode;

@interface JYCard : UIView <NSCoding>
@property (nonatomic, strong) PeopleMode *mode;
@end


@interface PeopleMode : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *mark;
@end
