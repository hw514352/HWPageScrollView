//
//  HWTitleView.h
//  VideoDemo
//
//  Created by lenew on 2019/5/15.
//  Copyright © 2019 hwei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HWTitleViewDelegate <NSObject>
/**
 switch page
 @param selectIndex  the selected index
 @param deselectIndex  the deselected index
 @param isClickTitle  Whether to switch to click on the title
 */
- (void)didSelectWithselectIndex:(NSInteger)selectIndex deselectIndex:(NSInteger)deselectIndex isClickTitle:(BOOL)isClickTitle;
@end

//indicateLine type
typedef NS_ENUM(NSUInteger, IndicateLineType) {
	IndicateLineTypeCenter = 0,// center, equal the text's width
	IndicateLineTypeFull = 1,// full, equal the button's width
};

@interface HWTitleView : UIView
@property(nonatomic, strong)NSArray *datas;

@property(nonatomic, assign)NSInteger selectIndex;
@property(nonatomic, strong)UIColor *unselectTextColor;
@property(nonatomic, strong)UIColor *selectTextColor;
@property(nonatomic, assign)CGFloat textFont;
@property(nonatomic, assign)CGFloat selectTextScale;//selected text zoom ratio, default 1.2 (recommended 1~2)
@property(nonatomic, assign)BOOL haveAnimation;//switch the animation

@property(nonatomic, assign)CGFloat separation;//title text separation on both sides

//indicate line configuration
@property(nonatomic, assign)BOOL haveIndicateLine;
@property(nonatomic, strong)UIColor *indicateLineColor;
@property(nonatomic, assign)CGFloat indicateLineHeight;
@property(nonatomic, assign)IndicateLineType indicateLineType;

@property(nonatomic, weak)id<HWTitleViewDelegate> delegate;

- (void)setDatas:(NSArray *)datas titleKey:(nullable NSString *)titleKey;
- (void)setDatas:(NSArray *)datas titleKey:(nullable NSString *)titleKey selectIndex:(NSInteger)selectIndex;

//set titleView select index
- (void)setTitleViewWithSelectIndex:(NSInteger)selectIndex;
//set current titleView show location
- (void)setTitleViewCurrentLocation:(CGFloat)currentIndex;
@end

NS_ASSUME_NONNULL_END
