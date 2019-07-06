//
//  HWPageScrollView.m
//  VideoDemo
//
//  Created by 黄威 on 2019/7/4.
//  Copyright © 2019 hwei. All rights reserved.
//

#import "HWPageScrollView.h"
#define DefaultTitleViewHeight 31

@interface HWPageScrollView ()<HWTitleViewDelegate,HWContentViewDelegate>
{
    CGFloat _width;
    CGFloat _height;
    CGFloat _titleViewHeight;
}
@end
@implementation HWPageScrollView

- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame titleViewHeight:DefaultTitleViewHeight];
}

- (instancetype)initWithFrame:(CGRect)frame titleViewHeight:(CGFloat)titleViewHeight {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _titleViewHeight = titleViewHeight > 0 ? titleViewHeight : DefaultTitleViewHeight;
        _width = self.frame.size.width;
        _height = self.frame.size.height;
        
        [self addSubview: self.titleView];
        [self addSubview: self.contentView];
    }
    return self;
}

- (void)setTitleViewDatas:(NSArray *)titleViewDatas titleKey:(nullable NSString *)titleKey contentViewControllers:(NSArray<UIViewController*> *)contentViewControllers {
    [self setTitleViewDatas:titleViewDatas titleKey:titleKey contentViewControllers:contentViewControllers selectIndex:_selectIndex];
}

- (void)setTitleViewDatas:(NSArray *)titleViewDatas titleKey:(nullable NSString *)titleKey contentViewControllers:(NSArray<UIViewController*> *)contentViewControllers selectIndex:(NSInteger)selectIndex{
    if (!titleViewDatas || ![titleViewDatas isKindOfClass:[NSArray class]] || !contentViewControllers || ![contentViewControllers isKindOfClass:[NSArray class]] || titleViewDatas.count != contentViewControllers.count) {
        return;
    }
    _selectIndex = selectIndex;
    [self.titleView setDatas:titleViewDatas titleKey:titleKey selectIndex:selectIndex];
    [self.contentView setContentViewControllers:contentViewControllers selectIndex:selectIndex];
}

#pragma mark - HWTitleViewDelegate
- (void)didSelectWithselectIndex:(NSInteger)selectIndex deselectIndex:(NSInteger)deselectIndex isClickTitle:(BOOL)isClickTitle {
    _selectIndex = selectIndex;
    if (isClickTitle) {
        [self.contentView clickTitleViewMakeContentViewScrollToIndex:selectIndex];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(pageScrollView:didSelectIndex:deselectIndex:isClickTitle:)]) {
        [_delegate pageScrollView:self didSelectIndex:selectIndex deselectIndex:deselectIndex isClickTitle:isClickTitle];
    }
}

#pragma mark - HWContentViewDelegate
- (void)contentScrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.titleView.haveAnimation) {
        CGFloat index = scrollView.contentOffset.x / _width;
        [self.titleView setTitleViewCurrentLocation:index];
    }
}

- (void)contentScrollViewDidScrollToIndex:(NSInteger)index{
    [self.titleView setTitleViewWithSelectIndex:index];
}

#pragma mark - setter
- (void)setSelectIndex:(NSInteger)selectIndex {
    _selectIndex = selectIndex;
    self.titleView.selectIndex = selectIndex;
    self.contentView.selectIndex = selectIndex;
}


#pragma mark - getter
- (HWTitleView *)titleView {
    if (!_titleView) {
        _titleView = [[HWTitleView alloc] initWithFrame:CGRectMake(0, 0, _width, _titleViewHeight)];
        _titleView.delegate = self;
    }
    return _titleView;
}
- (HWContentView *)contentView {
    if (!_contentView) {
        _contentView = [[HWContentView alloc] initWithFrame:CGRectMake(0, _titleViewHeight, _width, _height-_titleViewHeight)];
        _contentView.delegate = self;
    }
    return _contentView;
}

@end
