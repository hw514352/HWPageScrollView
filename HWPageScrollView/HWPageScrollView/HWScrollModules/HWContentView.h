//
//  HWContentView.h
//  VideoDemo
//
//  Created by lenew on 2019/5/16.
//  Copyright © 2019 hwei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HWContentViewDelegate <NSObject>

- (void)contentScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)contentScrollViewDidScrollToIndex:(NSInteger)index;
@end

@interface HWContentView : UIView
@property(nonatomic, strong)NSArray<UIViewController *> *contentViewControllers;
@property(nonatomic, assign)NSInteger selectIndex;
@property(nonatomic, weak)id<HWContentViewDelegate> delegate;

- (void)setContentViewControllers:(NSArray<UIViewController *> *)contentViewControllers selectIndex:(NSInteger)selectIndex;
- (void)clickTitleViewMakeContentViewScrollToIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
