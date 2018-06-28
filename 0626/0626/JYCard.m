//
//  JYCard.m
//  0626
//
//  Created by dqh on 2018/6/27.
//  Copyright © 2018年 dqh. All rights reserved.
//

#import "JYCard.h"

@interface JYCard ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UILabel *markLabel;
@end

@implementation JYCard

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        [self initializeView];
    }
    return self;
}

- (void)initializeView
{
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 220, 40)];
    nameLabel.textColor = [UIColor blackColor];
    [self addSubview:nameLabel];
    self.nameLabel = nameLabel;

    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 55, 220, 40)];
    phoneLabel.textColor = [UIColor blackColor];
    [self addSubview:phoneLabel];
    self.phoneLabel = phoneLabel;
    
    UILabel *markLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 200, 100)];
    markLabel.numberOfLines = 0;
    markLabel.textColor = [UIColor blackColor];
    [self addSubview:markLabel];
    self.markLabel = markLabel;
}

- (void)setMode:(PeopleMode *)mode
{
    if (_mode != mode) {
        _mode = mode;
        
        self.nameLabel.text = mode.name;
        
        self.phoneLabel.text = mode.phone;
        
        self.markLabel.text = mode.mark;
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.nameLabel forKey:@"nameLabel"];
    [aCoder encodeObject:self.phoneLabel forKey:@"phoneLabel"];
    [aCoder encodeObject:self.markLabel forKey:@"markLabel"];
    [aCoder encodeObject:self.mode forKey:@"mode"];

}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.nameLabel = [aDecoder decodeObjectForKey:@"nameLabel"];
        self.phoneLabel = [aDecoder decodeObjectForKey:@"phoneLabel"];
        self.markLabel = [aDecoder decodeObjectForKey:@"markLabel"];
        self.mode = [aDecoder decodeObjectForKey:@"mode"];

    }
    return self;
}
@end


@implementation PeopleMode
@end
