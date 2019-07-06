//
//  ViewController.m
//  HWPageScrollView
//
//  Created by 黄威 on 2019/7/7.
//  Copyright © 2019 Hwei. All rights reserved.
//

#import "ViewController.h"
#import "HWPageScrollView.h"
@interface ViewController ()<HWPageScrollViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    HWPageScrollView *pageScrollView = [[HWPageScrollView alloc] initWithFrame:CGRectMake(0, 20,UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height-20) titleViewHeight:31];
    pageScrollView.delegate = self;
    pageScrollView.titleView.unselectTextColor = [UIColor blackColor];
    pageScrollView.titleView.selectTextColor = [UIColor redColor];
    pageScrollView.titleView.textFont = 15;
    pageScrollView.titleView.selectTextScale = 1.2;
    pageScrollView.titleView.separation = 20;
    pageScrollView.titleView.haveIndicateLine = YES;
    pageScrollView.titleView.indicateLineColor = [UIColor redColor];
    pageScrollView.titleView.indicateLineHeight = 2;
    pageScrollView.titleView.indicateLineType = IndicateLineTypeCenter;
    pageScrollView.titleView.haveAnimation = YES;
    [self.view addSubview:pageScrollView];
    
    NSMutableArray *vcArr = [NSMutableArray array];
    for (int i = 0; i < 11; i ++) {
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor colorWithRed:(arc4random()%256)/255.0 green:(arc4random()%256)/255.0 blue:(arc4random()%256)/255.0 alpha:1];
        [vcArr addObject:vc];
    }
    
    int x = 1;
    switch (x) {
        case 0:{
            NSArray *titleDatas = @[@"basketball",@"basketball",@"football",@"tennis",@"table tennis",@"volleyball",@"handball",@"water polo",@"bowling",@"polo",@"gate ball"];
            [pageScrollView setTitleViewDatas:titleDatas titleKey:nil contentViewControllers:vcArr selectIndex:1];
            break;
        }
        default:{
            NSArray *titleDatas = @[@{@"titleKey":@"basketball"},@{@"titleKey":@"basketball"},@{@"titleKey":@"football"},@{@"titleKey":@"tennis"},@{@"titleKey":@"table tennis"},@{@"titleKey":@"volleyball"},@{@"titleKey":@"handball"},@{@"titleKey":@"water polo"},@{@"titleKey":@"bowling"},@{@"titleKey":@"polo"},@{@"titleKey":@"gate ball"}];
            [pageScrollView setTitleViewDatas:titleDatas titleKey:@"titleKey" contentViewControllers:vcArr selectIndex:1];
            break;
        }
    }
}

#pragma mark - HWPageScrollViewDelegate
- (void)pageScrollView:(HWPageScrollView *)pageScrollView didSelectIndex:(NSInteger)selectIndex deselectIndex:(NSInteger)deselectIndex isClickTitle:(BOOL)isClickTitle{
    NSLog(@"is click title：%@，did select index: %ld; did deselect index: %ld",isClickTitle?@"YES":@"NO",selectIndex,deselectIndex);
}

@end
