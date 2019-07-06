//
//  HWPageScrollView.h
//  VideoDemo
//
//  Created by 黄威 on 2019/7/4.
//  Copyright © 2019 hwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWTitleView.h"
#import "HWContentView.h"
@class HWPageScrollView;

NS_ASSUME_NONNULL_BEGIN
@protocol HWPageScrollViewDelegate <NSObject>
/**
 @param selectIndex  the selected index
 @param deselectIndex  the deselected index
 @param isClickTitle  Whether to switch to click on the title
 */
- (void)pageScrollView:(HWPageScrollView *)pageScrollView didSelectIndex:(NSInteger)selectIndex deselectIndex:(NSInteger)deselectIndex isClickTitle:(BOOL)isClickTitle;
@end

@interface HWPageScrollView : UIView

@property(nonatomic, strong)HWTitleView *titleView;
@property(nonatomic, strong)HWContentView *contentView;

@property(nonatomic, assign)NSInteger selectIndex;
@property(nonatomic, weak)id<HWPageScrollViewDelegate> delegate;


- (instancetype)initWithFrame:(CGRect)frame titleViewHeight:(CGFloat)titleViewHeight;

/**
 @param titleViewDatas  head title datas, the elements can string or NSDictionary. if string, titleKey is nil; if NSDictionary, titleKey must a string.
 @param titleKey  if titleViewDatas elements is NSDictionary, titleKey must a string.
 @param contentViewControllers   must be the UIViewController elements
 */
- (void)setTitleViewDatas:(NSArray *)titleViewDatas titleKey:(nullable NSString *)titleKey contentViewControllers:(NSArray<UIViewController*> *)contentViewControllers;
- (void)setTitleViewDatas:(NSArray *)titleViewDatas titleKey:(nullable NSString *)titleKey contentViewControllers:(NSArray<UIViewController*> *)contentViewControllers selectIndex:(NSInteger)selectIndex;
@end

NS_ASSUME_NONNULL_END
