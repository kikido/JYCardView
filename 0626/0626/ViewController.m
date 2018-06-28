//
//  ViewController.m
//  0626
//
//  Created by dqh on 2018/6/26.
//  Copyright © 2018年 dqh. All rights reserved.
//

#import "ViewController.h"
#import "JYCardView.h"
#import "JYCard.h"

#define JY_Card_Count 10

@interface ViewController () <JYCardViewDelegate,JYCardViewDataSource>
@property (nonatomic, strong) NSArray *cardModes;
@property (nonatomic, strong) JYCardView *cardView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *ttf = @[].mutableCopy;
    for (NSInteger i = 0; i < JY_Card_Count; i++) {
        PeopleMode *mode = [PeopleMode new];
        mode.name = [NSString stringWithFormat:@"%ld",i];
        mode.phone = [NSString stringWithFormat:@"%ld%ld%ld%ld%ld%ld%ld%ld%ld",i,i,i,i,i,i,i,i,i];
        mode.mark = @"adajndnakdnajknkajnfkanfkankanfanfanfnafajf";
        [ttf addObject:mode];
    }
    self.cardModes = ttf.copy;

    JYCardView *cardView = [[JYCardView alloc] initWithFrame:CGRectMake(100, 100, 220, 400)];
    cardView.maxRotationAngle = M_PI_4 / 2.;
    cardView.delegate = self;
    cardView.dataSource = self;
    [self.view addSubview:cardView];
    self.cardView = cardView;
    

    for (NSInteger i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(30 + 130*i, 510, 100, 40);
        [button setTitle:@[@"向左飞", @"向右飞"][i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [self.view addSubview:button];
    }
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)buttonAction:(UIButton *)sender
{
    if (sender.tag == 1) {
        [self.cardView cardPopWithDirection:JYCardViewDirectionRight];
    } else {
//        [self.cardView cardPopWithDirection:JYCardViewDirectionLeft];
        [self.cardView reloadData];
    }
}


#pragma mark - JYCardViewDataSource

- (NSInteger)numberOfCardsInCardView:(JYCardView *)cardView
{
    return self.cardModes.count;
}

- (__kindof UIView *)singleCardForCardView:(JYCardView *)cardView
{
    JYCard *card = [[JYCard alloc] init];
    return card;
}
- (void)cardView:(JYCardView *)cardView updateCard:(__kindof UIView*)card AtIndex:(NSInteger)index
{
    PeopleMode *mode = self.cardModes[index];
    [(JYCard *)card setMode:mode];
    
    card.layer.cornerRadius = 4;
    card.layer.shadowRadius = 3;
    card.layer.shadowOpacity = 0.2;
    card.layer.shadowOffset = CGSizeMake(1, 1);
    card.layer.shadowPath = [UIBezierPath bezierPathWithRect:card.bounds].CGPath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
