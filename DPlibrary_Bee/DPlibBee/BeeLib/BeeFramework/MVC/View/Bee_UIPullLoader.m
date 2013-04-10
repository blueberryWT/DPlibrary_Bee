//
//	 ______    ______    ______    
//	/\  __ \  /\  ___\  /\  ___\   
//	\ \  __<  \ \  __\_ \ \  __\_ 
//	 \ \_____\ \ \_____\ \ \_____\ 
//	  \/_____/  \/_____/  \/_____/ 
//
//	Copyright (c) 2012 BEE creators
//	http://www.whatsbug.com
//
//	Permission is hereby granted, free of charge, to any person obtaining a
//	copy of this software and associated documentation files (the "Software"),
//	to deal in the Software without restriction, including without limitation
//	the rights to use, copy, modify, merge, publish, distribute, sublicense,
//	and/or sell copies of the Software, and to permit persons to whom the
//	Software is furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//	IN THE SOFTWARE.
//
//
//  Bee_UIPullLoader.m
//

#import "MBSpinningCircle.h"
#import "UIView+UU.h"
#pragma mark -

@interface BeeUIPullLoader(Private)
- (void)initSelf;
-(void) layoutLastUpdataDateLabelWithTitle:(NSString*) title;
@end

@implementation BeeUIPullLoader

DEF_SIGNAL( STATE_CHANGED )

DEF_INT( STATE_NORMAL,	0 )
DEF_INT( STATE_PULLING,	1 )
DEF_INT( STATE_LOADING,	2 )

@synthesize state = _state;
@synthesize normal = _normal;
@synthesize pulling = _pulling;
@synthesize loading = _loading;

+ (BeeUIPullLoader *)spawn
{
	return [[[BeeUIPullLoader alloc] init] autorelease];
}

- (id)init
{
	self = [super init];
	if ( self )
	{
		[self initSelf];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if ( self )
	{
		[self initSelf];
    }
	
    return self;
}

- (void)initSelf
{
	self.backgroundColor = [UIColor clearColor];
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth;


    // 创建下拉刷新的箭头
    _arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _arrowView.contentMode = UIViewContentModeCenter;
    _arrowView.backgroundColor = [UIColor clearColor];
    [_arrowView setImage:[UIImage imageNamed:@"pull_arrow_48.png"]];
    _arrowView.hidden = NO;
    [_arrowView setTransform:CGAffineTransformMakeRotation((CGFloat) (M_PI * 1))];
    [self addSubview:_arrowView];


    if (!_lastUpdateDate) {
        _lastUpdateDate = [[BeeUILabel alloc] init];
        // 这里是为了让第一次请求的时候不显示--:--:--的样式，给一个当前时间
        // 其实这么做是不合理的，应该有一个表来记录每个请求的最后请求时间，但是感觉又太浪费了
        // 所以采用这个折中的办法
        // 这个问题由 "罗尼玛" 发现，并建议修改
//        NSString *nowDate = [DPTools transDateToFormatString:[NSDate date] wtihFormat:@"HH:mm:ss"];
        NSString *nowDate = @"--:--:--";
        [_lastUpdateDate setText:[NSString stringWithFormat:@"最后更新于%@", nowDate]];
        [_lastUpdateDate setFont:[UIFont systemFontOfSize:13.0f]];
        [_lastUpdateDate setTextColor:[UIColor grayColor]];
        [_lastUpdateDate sizeToFit];
        [self addSubview:_lastUpdateDate];
    }

    if (!_pullDownTip) {
        _pullDownTip = [[BeeUILabel alloc] init];
        [_pullDownTip setText:@"下拉刷新"];
        [_pullDownTip setFont:[UIFont systemFontOfSize:13.0f]];
        [_pullDownTip setTextColor:[UIColor blackColor]];
        [_pullDownTip sizeToFit];
        [self addSubview:_pullDownTip];
    }

    // 蓝色转圈的标志
    _activityIndicator = [[MBSpinningCircle circleWithSize:NSSpinningCircleSizeLarge color:[UIColor colorWithRed:50.0 / 255.0 green:155.0 / 255.0 blue:255.0 / 255.0 alpha:1.0]] retain];
    CGRect circleRect = _activityIndicator.frame;
    circleRect.origin = CGPointMake(50,(self.height - 20) / 2.0f);
    circleRect.size = CGSizeMake(40, 40);
    _activityIndicator.frame = circleRect;
    _activityIndicator.circleSize = NSSpinningCircleSizeLarge;
    _activityIndicator.hasGlow = YES;
    _activityIndicator.isAnimating = YES;
    _activityIndicator.speed = 0.55;
    [_activityIndicator setHidden:YES];
    [self addSubview:_activityIndicator];


	
	_state = BeeUIPullLoader.STATE_NORMAL;
}

-(void) layoutLastUpdataDateLabelWithTitle:(NSString*) title {
    if (nil == title || [title empty]) {
        return;
    }
    [_lastUpdateDate setText:title];
    [_lastUpdateDate sizeToFit];
    [_lastUpdateDate setCenterX:self.width / 2];
}


- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];

    // 下拉刷新箭头的位置
    [_arrowView setLeft:50];
    [_arrowView setCenterY:self.height / 2];



    // 下拉提示文字的位置
    [_pullDownTip setFrame:CGRectMake(
            (frame.size.width - _pullDownTip.frame.size.width) / 2.0f,
            (frame.size.height - _pullDownTip.frame.size.height) / 2.0f - 8,
            _pullDownTip.frame.size.width,
            _pullDownTip.frame.size.height)];


    // 最后更新时间的位置
    [_lastUpdateDate sizeToFit];
    [_lastUpdateDate setTop:_pullDownTip.bottom + 2];
    [_lastUpdateDate setCenterX:self.width / 2];

    // 蓝色动画的位置
    [_activityIndicator setCenterX:_arrowView.centerX];
    [_activityIndicator setCenterY:_arrowView.centerY];
}

- (void)dealloc
{	
//	SAFE_RELEASE_SUBVIEW( _arrowView );
//	SAFE_RELEASE_SUBVIEW( _indicator );
    SAFE_RELEASE_SUBVIEW(_lastUpdateDate);
    SAFE_RELEASE_SUBVIEW(_pullDownTip);
    [_activityIndicator release], _activityIndicator = nil;
    [_arrowView release], _arrowView = nil;
    [super dealloc];
}

- (BOOL)normal
{
	return (BeeUIPullLoader.STATE_NORMAL == _state) ? YES : NO;
}

- (void)setNormal:(BOOL)flag
{
	if ( flag )
	{
		[self changeState:BeeUIPullLoader.STATE_NORMAL];		
	}
}

- (BOOL)pulling
{
	return (BeeUIPullLoader.STATE_PULLING == _state) ? YES : NO;
}

- (void)setPulling:(BOOL)flag
{
	if ( flag )
	{
		[self changeState:BeeUIPullLoader.STATE_PULLING];		
	}
}

- (BOOL)loading
{
	return (BeeUIPullLoader.STATE_LOADING == _state) ? YES : NO;
}

- (void)setLoading:(BOOL)flag
{
	if ( flag )
	{
		[self changeState:BeeUIPullLoader.STATE_LOADING];
	}
}

- (void)changeState:(NSInteger)state
{
	[self changeState:state animated:NO];
}

- (void)changeState:(NSInteger)state animated:(BOOL)animated
{
	if ( _state == state )
		return;

	_state = state;
	
	if ( BeeUIPullLoader.STATE_NORMAL == state )
	{
        // 更新旋转的图标
        [_activityIndicator setHidden:YES];

        [_pullDownTip setText:@"下拉刷新"];
        [_pullDownTip setHidden:YES];

        [_arrowView setHidden:NO];
        // 指定箭头的方向
        [UIView animateWithDuration:0.3 animations:^(){
            [_arrowView setTransform:CGAffineTransformMakeRotation((CGFloat) (M_PI / 360.0f) * 359)];
        } completion:^(BOOL b){
        }];

        // 更新最后时间
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm:ss"];
        NSString *lastUpdated = [NSString stringWithFormat:@"最后更新于 %@", [formatter stringFromDate:[NSDate date]]];
        [formatter release];
        [self layoutLastUpdataDateLabelWithTitle:lastUpdated];

        CC(@"===>BeeUIPullLoader.STATE_NORMAL");
	}
	else if ( BeeUIPullLoader.STATE_PULLING == state ) //
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3f];

        // 更新提示剪头
        _arrowView.hidden = NO;
        [_arrowView setTransform:CGAffineTransformMakeRotation((CGFloat) (M_PI * 2))];
        [UIView commitAnimations];

        // 更新提示文字
        [_pullDownTip setText:@"松开刷新"];
        [_pullDownTip setHidden:NO];

        // 更新旋转箭头
        [_activityIndicator setHidden:YES];
        BeeCC(@"===>BeeUIPullLoader.STATE_PULLING");
	}
	else if ( BeeUIPullLoader.STATE_LOADING == state ) {
        [_activityIndicator setIsAnimating:YES];
        [_pullDownTip setText:@"正在刷新"];

        // 更新旋转箭头
        [_activityIndicator setHidden:NO];
        [_arrowView setHidden:YES];
        BeeCC(@"===>BeeUIPullLoader.STATE_LOADING");
    }
	[self sendUISignal:BeeUIPullLoader.STATE_CHANGED];
}

@end
