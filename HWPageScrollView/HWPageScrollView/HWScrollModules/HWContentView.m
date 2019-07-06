//
//  HWContentView.m
//  VideoDemo
//
//  Created by lenew on 2019/5/16.
//  Copyright © 2019 hwei. All rights reserved.
//

#import "HWContentView.h"
@interface HWContentView()<UIScrollViewDelegate>
{
	CGFloat _width;
	CGFloat _height;
}
@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, assign)BOOL isForcedScroll;
@end
@implementation HWContentView

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
        _width = self.frame.size.width;
		_height = self.frame.size.height;
	}
	return self;
}

- (void)setContentViewControllers:(NSArray<UIViewController *> *)contentViewControllers selectIndex:(NSInteger)selectIndex{
    if (!contentViewControllers || ![contentViewControllers isKindOfClass:[NSArray class]] || contentViewControllers.count == 0) return;
    if (selectIndex > contentViewControllers.count-1) selectIndex = contentViewControllers.count-1;
    if (selectIndex < 0) selectIndex = 0;
    
    _contentViewControllers = contentViewControllers;
    _selectIndex = selectIndex;
    _width = self.frame.size.width;
    _height = self.frame.size.height;
    
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    self.scrollView.contentSize = CGSizeMake(_width*contentViewControllers.count, _height);
    [self showContentView:selectIndex];
}
//
- (void)clickTitleViewMakeContentViewScrollToIndex:(NSInteger)index {
    self.isForcedScroll = YES;
    [self.scrollView setContentOffset:CGPointMake(_width*index, 0)];
}

//懒加载内容
- (void)showContentView:(NSInteger)index {
    UIViewController *selectViewController = [_contentViewControllers objectAtIndex:index];
    if (!selectViewController.view.superview) {
        selectViewController.view.frame = CGRectMake(_width*index, 0, _width, _height);
        [self.scrollView addSubview:selectViewController.view];
        [self.scrollView setContentOffset:CGPointMake(_width*index, 0)];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isForcedScroll) {
        self.isForcedScroll = NO;
        CGFloat contentOffsetY = scrollView.contentOffset.x;
        NSInteger index = contentOffsetY / self.frame.size.width;
        [self showContentView:index];
        return;
    }
	if (self.delegate && [self.delegate respondsToSelector:@selector(contentScrollViewDidScroll:)]) {
		[self.delegate contentScrollViewDidScroll:scrollView];
	}
}
//setContentOffset 导致滚动条用
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    CGFloat contentOffsetY = scrollView.contentOffset.x;
    NSInteger index = contentOffsetY / self.frame.size.width;
    [self showContentView:index];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat contentOffsetY = scrollView.contentOffset.x;
    NSInteger index = contentOffsetY / self.frame.size.width;
    [self showContentView:index];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentScrollViewDidScrollToIndex:)]) {
        [self.delegate contentScrollViewDidScrollToIndex:index];
    }
}

#pragma mark - setter
- (void)setContentViewControllers:(NSArray<UIViewController *> *)contentViewControllers {
    [self setContentViewControllers:contentViewControllers selectIndex:_selectIndex];
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    _selectIndex = selectIndex;
    self.isForcedScroll = YES;
    [self showContentView:selectIndex];
}

#pragma mark - getter
- (UIScrollView *)scrollView {
	if (!_scrollView) {
		_scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
		_scrollView.pagingEnabled = YES;
		_scrollView.delegate = self;
        [self addSubview:_scrollView];
	}
	return _scrollView;
}

@end
