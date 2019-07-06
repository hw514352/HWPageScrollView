//
//  HWTitleView.m
//  VideoDemo
//
//  Created by lenew on 2019/5/15.
//  Copyright © 2019 hwei. All rights reserved.
//

#import "HWTitleView.h"
#define HWScreenWidth UIScreen.mainScreen.bounds.size.width
#define HWScreenHeight UIScreen.mainScreen.bounds.size.height

//颜色值得色值
typedef struct {
    CGFloat r;
    CGFloat g;
    CGFloat b;
    CGFloat a;
} RBGAValue;
//滑动方法
typedef NS_ENUM(NSUInteger, HWTitleRemoveDirection) {
    HWTitleRemoveNone=0,
    HWTitleRemoveToLeft=1,
    HWTitleRemoveToRight=2,
};
@interface HWTitleView()
{
	CGFloat _width;
	CGFloat _height;
    NSInteger _currentShowIndex;//当前显示的index 只用于滑动过程记录值
}
@property(nonatomic,assign)CGFloat freeSpace;//每个button分配的剩余空间
//Array
@property(nonatomic,strong)NSMutableArray *widthArr;
@property(nonatomic,strong)NSMutableArray *controls;
//Views
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)UIView *indicateLine;
//color RGBA
@property(nonatomic,assign)RBGAValue unselectTextColorRGBA;
@property(nonatomic,assign)RBGAValue selectTextColorRGBA;

@property(nonatomic,assign)CGFloat lastIndex;//记录上一次的滑动比例
@property(nonatomic,assign)HWTitleRemoveDirection titleScrollDirection;
@end
@implementation HWTitleView
- (instancetype)init{
	self = [super init];
	if (self) {
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
        _width = self.frame.size.width;
        _height = self.frame.size.height;
		[self initProperty];
	}
	return self;
}

- (void)initProperty {
	_selectIndex = 0;
    _currentShowIndex = 0;
	_unselectTextColor = [UIColor blackColor];
    _unselectTextColorRGBA = (RBGAValue){0,0,0,1};
	_selectTextColor = [UIColor redColor];
    _selectTextColorRGBA = (RBGAValue){1,0,0,1};
	_textFont = 14.0;
	_selectTextScale = 1.1;
    _haveAnimation = YES;
	
	_separation = 10;
	_haveIndicateLine = YES;
	_indicateLineColor = [UIColor redColor];
	_indicateLineHeight = 2.0;
	_indicateLineType = IndicateLineTypeCenter;
    
    _titleScrollDirection = HWTitleRemoveNone;
}

- (void)setDatas:(NSArray *)datas titleKey:(nullable NSString *)titleKey{
    [self setDatas:datas titleKey:titleKey selectIndex:_selectIndex];
}

- (void)setDatas:(NSArray *)datas titleKey:(nullable NSString *)titleKey selectIndex:(NSInteger)selectIndex{
	if (!datas || ![datas isKindOfClass:[NSArray class]] || datas.count == 0) return;
    if (selectIndex > datas.count-1) selectIndex = datas.count-1;
    if (selectIndex < 0) selectIndex = 0;
    
	_datas = datas;
    _selectIndex = selectIndex;
	
	[self.scrollView.subviews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[obj removeFromSuperview];
	}];
	[self.controls removeAllObjects];
	[self.widthArr removeAllObjects];
	
	CGFloat x = 0;
	for (int i = 0; i < datas.count; i ++) {
		NSString *title;
		id data = [datas objectAtIndex:i];
		if (!titleKey || titleKey.length == 0) {
			title = data;
		} else {
			title = [data objectForKey:titleKey];
		}
		NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:self.textFont]};
		CGFloat textWidth = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, _height) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size.width;
		CGFloat buttonWidth = textWidth+2*self.separation;
        
		CGRect frame = CGRectMake(x, 0, buttonWidth, _height);
		UIControl *control = [[UIControl alloc] initWithFrame:frame];
		control.tag = 1000 + i;
		[control addTarget:self action:@selector(titlesSelectAction:) forControlEvents:UIControlEventTouchUpInside];
		[self.scrollView addSubview:control];
		
		UILabel *titleLabel = [[UILabel alloc] init];
		titleLabel.tag = 999;
		titleLabel.text = title;
		[titleLabel sizeToFit];
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.font = [UIFont systemFontOfSize:self.textFont];
		titleLabel.textColor = self.unselectTextColor;
		[control addSubview:titleLabel];
		
		titleLabel.center = CGPointMake(frame.size.width/2, frame.size.height/2);
		
		if (selectIndex == i) {
			titleLabel.textColor = self.selectTextColor;
			titleLabel.transform = CGAffineTransformMakeScale(self.selectTextScale, self.selectTextScale);
		}
		[self.controls addObject:control];
		
		NSMutableDictionary *widthDic = [NSMutableDictionary dictionaryWithDictionary:@{@"centerX":@(x+buttonWidth*0.5),@"textWidth":@(textWidth),@"buttonWidth":@(buttonWidth)}];
		[self.widthArr addObject:widthDic];
		
		x += buttonWidth;
	}
	
	//内容小于_width时
	if (x < _width) {
		self.freeSpace = (_width - x)/self.widthArr.count;//平分剩余空间
		x = 0;
		for (int i = 0; i < self.widthArr.count; i ++) {
			NSMutableDictionary *widthDic = [self.widthArr objectAtIndex:i];
			
			CGFloat buttonWidth = [[widthDic objectForKey:@"buttonWidth"] floatValue] + self.freeSpace;
			[widthDic setObject:@(buttonWidth) forKey:@"buttonWidth"];
			[widthDic setObject:@(x+buttonWidth*0.5) forKey:@"centerX"];
			
			UIControl *control = [self.controls objectAtIndex:i];
			control.frame = CGRectMake(x, 0, buttonWidth, _height);
			
			UILabel *titleLabel = [control viewWithTag:999];
			titleLabel.center = CGPointMake(buttonWidth/2, _height/2);
			
			x += buttonWidth;
		}
	}
	self.scrollView.contentSize = CGSizeMake(x, _height-1);
	
    [self setIndicateLinewWithDeselctIndex:selectIndex selectIndex:selectIndex changeScale:1 isClickTitle:NO];
    [self setSelectItemShowCenterWithSelectIndex:selectIndex animation:NO];
}

/** 内部点击切换
 control:被点击的control
 */
- (void)titlesSelectAction:(UIControl *)control {
	NSInteger selectIndex = control.tag - 1000;
    [self didSelectWithIndex:selectIndex isClickTitle:YES];
}

- (void)setTitleViewWithSelectIndex:(NSInteger)selectIndex {
    [self didSelectWithIndex:selectIndex isClickTitle:NO];
}

- (void)setTitleViewCurrentLocation:(CGFloat)currentIndex {
    //beyond the border
    if (currentIndex < 0 || currentIndex > self.controls.count-1) return;
    
    NSInteger leftIndex = (NSInteger)floor(currentIndex);
    NSInteger rightIndex = (NSInteger)ceil(currentIndex);
    CGFloat changeScale = currentIndex - (NSInteger)currentIndex;//变化值
    if (leftIndex != rightIndex) {
        CGFloat changeR = (_unselectTextColorRGBA.r-_selectTextColorRGBA.r)*changeScale;
        CGFloat changeG = (_unselectTextColorRGBA.g-_selectTextColorRGBA.g)*changeScale;
        CGFloat changeB = (_unselectTextColorRGBA.b-_selectTextColorRGBA.b)*changeScale;
        CGFloat changeA = (_unselectTextColorRGBA.a-_selectTextColorRGBA.a)*changeScale;
        
        UIControl *leftControl = [self.controls objectAtIndex:leftIndex];
        UILabel *leftTitleLabel = [leftControl viewWithTag:999];
        leftTitleLabel.textColor = [UIColor colorWithRed:_selectTextColorRGBA.r + changeR green:_selectTextColorRGBA.g + changeG blue:_selectTextColorRGBA.b + changeB alpha:_selectTextColorRGBA.a + changeA];
        leftTitleLabel.transform = CGAffineTransformMakeScale(1+(self.selectTextScale-1)*(1-changeScale), 1+(self.selectTextScale-1)*(1-changeScale));
        
        UIControl *rightControl = [self.controls objectAtIndex:rightIndex];
        UILabel *rightTitleLabel = [rightControl viewWithTag:999];
        rightTitleLabel.textColor = [UIColor colorWithRed:_unselectTextColorRGBA.r - changeR green:_unselectTextColorRGBA.g - changeG blue:_unselectTextColorRGBA.b - changeB alpha:_unselectTextColorRGBA.a - changeA];
        rightTitleLabel.transform = CGAffineTransformMakeScale(1+(self.selectTextScale-1)*changeScale, 1+(self.selectTextScale-1)*changeScale);
        
        //real-time show indicate line location
        [self setIndicateLinewWithDeselctIndex:leftIndex selectIndex:rightIndex changeScale:changeScale isClickTitle:NO];
    }

    // judge Whether or not turn the page in the process of sliding
    if (fabs(currentIndex - _currentShowIndex) >= 1) {
        _currentShowIndex = (NSInteger)currentIndex;
        [self setSelectItemShowCenterWithSelectIndex:_currentShowIndex animation:YES];
    }
}

- (void)setTitleViewCurrentLocation1:(CGFloat)currentIndex {
    CGFloat changeScale = fabs(currentIndex - _selectIndex);
    //no animation
    if (!self.haveAnimation) {
        if (changeScale >= 1) {
            [self didSelectWithIndex:(NSInteger)roundf(currentIndex) isClickTitle:NO];
        }
        return;
    };
    //超出两端 不处理
    if (currentIndex < 0 || currentIndex > self.controls.count-1) return;
    
    // The direction of record
    if (currentIndex > self.lastIndex) {
        self.titleScrollDirection = HWTitleRemoveToRight;
    } else if (currentIndex < self.lastIndex) {
        self.titleScrollDirection = HWTitleRemoveToLeft;
    } else {
        self.titleScrollDirection = HWTitleRemoveNone;
    }
    self.lastIndex = currentIndex;
    
    //从超出两端回归时 不处理
    if ((currentIndex == 0 && self.titleScrollDirection != HWTitleRemoveToLeft) || (currentIndex == self.controls.count-1 && self.titleScrollDirection != HWTitleRemoveToRight)) {
        [self setSelectItemShowCenterWithSelectIndex:_selectIndex animation:YES];
        return;
    }
    
    //(直接翻页时) 需要判断是否已经翻页 改变_selectedIndex  当currentIndex与_selectedIndex相等时 也一起处理，避免下面处理麻烦
    if (changeScale >= 1) {
        [self didSelectWithIndex:(NSInteger)roundf(currentIndex) isClickTitle:NO];
        return;
    }
    
    CGFloat changeR = (_unselectTextColorRGBA.r-_selectTextColorRGBA.r)*changeScale;
    CGFloat changeG = (_unselectTextColorRGBA.g-_selectTextColorRGBA.g)*changeScale;
    CGFloat changeB = (_unselectTextColorRGBA.b-_selectTextColorRGBA.b)*changeScale;
    CGFloat changeA = (_unselectTextColorRGBA.a-_selectTextColorRGBA.a)*changeScale;
    
    UIControl *selectControl = [self.controls objectAtIndex:_selectIndex];
    UILabel *selectTitleLabel = [selectControl viewWithTag:999];
    NSInteger willSelectIndex;
    if (currentIndex == _selectIndex) {
        //最终index没变化时 需将之前改变的复原
        if (self.titleScrollDirection == HWTitleRemoveToRight) {
            willSelectIndex = _selectIndex-1;
        } else if (self.titleScrollDirection == HWTitleRemoveToLeft) {
            willSelectIndex = _selectIndex+1;
        } else {
            return;
        }
        
        selectTitleLabel.textColor = _selectTextColor;
        selectTitleLabel.transform = CGAffineTransformMakeScale(self.selectTextScale, self.selectTextScale);
        
        UIControl *willSelectedControl = [self.controls objectAtIndex:willSelectIndex];
        UILabel *willSelectedTitleLabel = [willSelectedControl viewWithTag:999];
        willSelectedTitleLabel.textColor = [UIColor colorWithRed:_unselectTextColorRGBA.r - changeR green:_unselectTextColorRGBA.g - changeG blue:_unselectTextColorRGBA.b - changeB alpha:_unselectTextColorRGBA.a - changeA];
        willSelectedTitleLabel.transform = CGAffineTransformIdentity;
        
        return;
    }
    
    willSelectIndex = currentIndex > _selectIndex ?  _selectIndex + 1 : _selectIndex - 1;
    UIControl *willSelectedControl = [self.controls objectAtIndex:willSelectIndex];
    UILabel *willSelectedTitleLabel = [willSelectedControl viewWithTag:999];
    
    selectTitleLabel.textColor = [UIColor colorWithRed:_selectTextColorRGBA.r + changeR green:_selectTextColorRGBA.g + changeG blue:_selectTextColorRGBA.b + changeB alpha:_selectTextColorRGBA.a + changeA];
    selectTitleLabel.transform = CGAffineTransformMakeScale(1+(self.selectTextScale-1)*(1-changeScale), 1+(self.selectTextScale-1)*(1-changeScale));
    
    willSelectedTitleLabel.textColor = [UIColor colorWithRed:_unselectTextColorRGBA.r - changeR green:_unselectTextColorRGBA.g - changeG blue:_unselectTextColorRGBA.b - changeB alpha:_unselectTextColorRGBA.a - changeA];
    willSelectedTitleLabel.transform = CGAffineTransformMakeScale(1+(self.selectTextScale-1)*changeScale, 1+(self.selectTextScale-1)*changeScale);
    
    //实时显示指示线位置
    [self setIndicateLinewWithDeselctIndex:_selectIndex selectIndex:willSelectIndex changeScale:changeScale isClickTitle:NO];
}

/** 切换显示title
 selectIndex:选择的index
 isClickTitle:是否点击标题切换
*/
- (void)didSelectWithIndex:(NSInteger)selectIndex isClickTitle:(BOOL)isClickTitle{
	//相同 或 越界
	if (_selectIndex == selectIndex || selectIndex < 0 || selectIndex+1 > self.controls.count) return;
	
	UIControl *deselectControl = [self.controls objectAtIndex:_selectIndex];
	UIControl *selectControl = [self.controls objectAtIndex:selectIndex];
	
	UILabel *deselectTitleLabel = [deselectControl viewWithTag:999];
	UILabel *selectTitleLabel = [selectControl viewWithTag:999];
	deselectTitleLabel.textColor = self.unselectTextColor;
    selectTitleLabel.textColor = self.selectTextColor;
	
	if (isClickTitle && self.haveAnimation) {
		[UIView animateWithDuration:0.25 animations:^{
			deselectTitleLabel.transform = CGAffineTransformIdentity;
			selectTitleLabel.transform = CGAffineTransformMakeScale(self.selectTextScale, self.selectTextScale);
		}];
	} else {
		deselectTitleLabel.transform = CGAffineTransformIdentity;
		selectTitleLabel.transform = CGAffineTransformMakeScale(self.selectTextScale, self.selectTextScale);
	}

    [self setIndicateLinewWithDeselctIndex:_selectIndex selectIndex:selectIndex changeScale:1 isClickTitle:isClickTitle];
    [self setSelectItemShowCenterWithSelectIndex:selectIndex animation:YES];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectWithselectIndex:deselectIndex:isClickTitle:)]) {
        [_delegate didSelectWithselectIndex:selectIndex deselectIndex:_selectIndex isClickTitle:isClickTitle];
    }
    
    _selectIndex = selectIndex;
}

/**
 set indicate line location
 deselctIndex:
 selectIndex:
 changeScale: 0-1
 isClickTitle: Whether to click on the title
 */
- (void)setIndicateLinewWithDeselctIndex:(NSInteger)deselctIndex selectIndex:(NSInteger)selectIndex changeScale:(CGFloat)changeScale isClickTitle:(BOOL)isClickTitle{
    if (!self.haveIndicateLine) return;
    
    NSDictionary *deselectedWidthDic = [self.widthArr objectAtIndex:deselctIndex];
    CGFloat deselectedIndicateLineCenterX = [[deselectedWidthDic objectForKey:@"centerX"] floatValue];
    CGFloat deselectedIndicateLineTextWidth = [[deselectedWidthDic objectForKey:@"textWidth"] floatValue];
    CGFloat deselectedIndicateLineButtonWidth = [[deselectedWidthDic objectForKey:@"buttonWidth"] floatValue];
    CGFloat deselectedIndicateLineWidth = self.indicateLineType == IndicateLineTypeCenter ? deselectedIndicateLineTextWidth * self.selectTextScale : deselectedIndicateLineButtonWidth;
    
    CGFloat currentIndicateWidth = deselectedIndicateLineWidth;
    CGFloat currentIndicateLineCenterX = deselectedIndicateLineCenterX;
    if (selectIndex != deselctIndex) {
        NSDictionary *selectedWidthDic = [self.widthArr objectAtIndex:selectIndex];
        CGFloat selectedIndicateLineCenterX = [[selectedWidthDic objectForKey:@"centerX"] floatValue];
        CGFloat selectedIndicateLineTextWidth = [[selectedWidthDic objectForKey:@"textWidth"] floatValue];
        CGFloat selectedIndicateLineButtonWidth = [[selectedWidthDic objectForKey:@"buttonWidth"] floatValue];
        CGFloat selectedIndicateLineWidth = self.indicateLineType == IndicateLineTypeCenter ? selectedIndicateLineTextWidth * self.selectTextScale : selectedIndicateLineButtonWidth;
        
        currentIndicateWidth = deselectedIndicateLineWidth + (selectedIndicateLineWidth - deselectedIndicateLineWidth) * changeScale;
        currentIndicateLineCenterX = deselectedIndicateLineCenterX +  (selectedIndicateLineCenterX - deselectedIndicateLineCenterX) * changeScale;
    }
    
    CGRect frame = self.indicateLine.frame;
    frame.size.width = currentIndicateWidth;
    CGPoint center = self.indicateLine.center;
    center.x =  currentIndicateLineCenterX;
    if (isClickTitle && self.haveAnimation) {
        [UIView animateWithDuration:0.25 animations:^{
            self.indicateLine.frame = frame;
            self.indicateLine.center = center;
        }];
    } else {
        self.indicateLine.frame = frame;
        self.indicateLine.center = center;
    }
}

// set select title show the center of the titleView
- (void)setSelectItemShowCenterWithSelectIndex:(NSInteger)selectIndex animation:(BOOL)animation{
    NSDictionary *selectedWidthDic = [self.widthArr objectAtIndex:selectIndex];
    
    CGFloat selectedCenterX = [[selectedWidthDic objectForKey:@"centerX"] floatValue];
    CGFloat contentOffsetX;
    if (selectedCenterX <= _width/2) {
        contentOffsetX = 0;
    } else if (self.scrollView.contentSize.width - selectedCenterX <= _width/2) {
        contentOffsetX = self.scrollView.contentSize.width - _width;
    } else {
        contentOffsetX = selectedCenterX - _width/2;
    }
    [self.scrollView setContentOffset:CGPointMake(contentOffsetX, 0) animated:animation && self.haveAnimation];
}

#pragma mark - setter
- (void)setDatas:(NSArray *)datas {
    [self setDatas:datas titleKey:nil selectIndex:_selectIndex];
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    _currentShowIndex = selectIndex;
	[self didSelectWithIndex:selectIndex isClickTitle:NO];
}

- (void)setUnselectTextColor:(UIColor *)unselectTextColor {
    _unselectTextColor = unselectTextColor;
    _unselectTextColorRGBA = [self rgbaFromColor:unselectTextColor];
}
- (void)setSelectTextColor:(UIColor *)selectTextColor {
    _selectTextColor = selectTextColor;
    _selectTextColorRGBA = [self rgbaFromColor:selectTextColor];
}
- (void)setSelectTextScale:(CGFloat)selectTextScale {
    selectTextScale = selectTextScale < 1 ? 1 : (selectTextScale > 2 ? 2 : selectTextScale);
    _selectTextScale = selectTextScale;
}

#pragma mark - getter
- (NSMutableArray *)widthArr {
	if (!_widthArr) {
		_widthArr = [NSMutableArray array];
	}
	return _widthArr;
}
- (NSMutableArray *)controls {
	if (!_controls) {
		_controls = [NSMutableArray array];
	}
	return _controls;
}
- (UIView *)indicateLine {
	if (!_indicateLine) {
		_indicateLine = [[UIView alloc] initWithFrame:CGRectMake(0, _height-self.indicateLineHeight, 0, self.indicateLineHeight)];
		_indicateLine.backgroundColor = self.indicateLineColor;
		[self.scrollView addSubview:_indicateLine];
	}
	return _indicateLine;
}
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _width, _height-1)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, _height-1, _width, 1)];
        bottomLine.backgroundColor = [UIColor grayColor];
        [self addSubview:bottomLine];
    }
    return _scrollView;
}

#pragma mark - customMethod
//color -> rgba
- (RBGAValue)rgbaFromColor:(UIColor *)color {
    CGFloat r = 0, g = 0, b = 0, a = 0;
    [color getRed:&r green:&g blue:&b alpha:&a];
//    int8_t red = r * 255;
//    uint8_t green = g * 255;
//    uint8_t blue = b * 255;
//    uint8_t alpha = a * 255;
//    return (red << 24) + (green << 16) + (blue << 8) + alpha;
    RBGAValue rgba;
    rgba.a = a;
    rgba.b = b;
    rgba.g = g;
    rgba.r = r;
    return rgba;
}
@end
