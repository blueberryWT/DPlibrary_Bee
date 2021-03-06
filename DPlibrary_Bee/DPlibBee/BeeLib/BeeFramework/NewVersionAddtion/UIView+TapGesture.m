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
//  Bee_UISignal.m
//

#import "Bee_Precompile.h"
#import "Bee_UISignal.h"
#import "Bee_Singleton.h"
#import "Bee_Log.h"
#import "Bee_Performance.h"
//#import "UIView+BeeExtension.h"
#import "UIView+TapGesture.h"

#import <objc/runtime.h>

#pragma mark -

@interface __SingleTapGestureRecognizer : UITapGestureRecognizer
{
	NSString *	_signalName;
	NSObject *	_signalObject;
}

@property (nonatomic, retain) NSString *	signalName;
@property (nonatomic, assign) NSObject *	signalObject;

@end

#pragma mark -

@implementation __SingleTapGestureRecognizer

@synthesize signalName = _signalName;
@synthesize signalObject = _signalObject;

- (id)initWithTarget:(id)target action:(SEL)action
{
	self = [super initWithTarget:target action:action];
	if ( self )
	{
		self.numberOfTapsRequired = 1;
		self.numberOfTouchesRequired = 1;
		self.cancelsTouchesInView = YES;
		self.delaysTouchesBegan = YES;
		self.delaysTouchesEnded = YES;		
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

@end

#pragma mark -

@interface UIView(TapGesturePrivate)
- (__SingleTapGestureRecognizer *)getTapGesture;
@end

#pragma mark -

@implementation UIView(TapGesture)

DEF_SIGNAL( TAPPED );

@dynamic tappable;
@dynamic tapEnabled;
@dynamic tapGesture;
@dynamic tapSignal;
@dynamic tapObject;

- (__SingleTapGestureRecognizer *)getTapGesture
{
	__SingleTapGestureRecognizer * tapGesture = nil;

	for ( UIGestureRecognizer * gesture in self.gestureRecognizers )
	{
		if ( [gesture isKindOfClass:[__SingleTapGestureRecognizer class]] )
		{
			tapGesture = (__SingleTapGestureRecognizer *)gesture;
		}
	}
	
	if ( nil == tapGesture )
	{
		tapGesture = [[[__SingleTapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTapped:)] autorelease];
		[self addGestureRecognizer:tapGesture];
	}

	return tapGesture;
}

- (void)didSingleTapped:(UITapGestureRecognizer *)tapGesture
{
	if ( [tapGesture isKindOfClass:[__SingleTapGestureRecognizer class]] )
	{
		__SingleTapGestureRecognizer * singleTapGesture = (__SingleTapGestureRecognizer *)tapGesture;

		if ( UIGestureRecognizerStateEnded == singleTapGesture.state )
		{
			if ( singleTapGesture.signalName )
			{
				[self sendUISignal:singleTapGesture.signalName withObject:singleTapGesture.signalObject];
			}
			else
			{
				[self sendUISignal:UIView.TAPPED];
			}
		}
	}		
}

- (void)makeTappable
{
	[self makeTappable:nil];
}

- (void)makeTappable:(NSString *)signal
{
	[self makeTappable:signal withObject:nil];
}

- (void)makeTappable:(NSString *)signal withObject:(NSObject *)obj
{
	self.userInteractionEnabled = YES;
	
	__SingleTapGestureRecognizer * singleTapGesture = [self getTapGesture];
	if ( singleTapGesture )
	{
		singleTapGesture.signalName = signal;
		singleTapGesture.signalObject = obj;
	}
}

- (void)makeUntappable
{
	for ( UIGestureRecognizer * gesture in self.gestureRecognizers )
	{
		if ( [gesture isKindOfClass:[__SingleTapGestureRecognizer class]] )
		{
			[self removeGestureRecognizer:gesture];
		}
	}
}

- (BOOL)tappable
{
	return self.tapEnabled;
}

- (void)setTappable:(BOOL)flag
{
	self.tapEnabled = flag;
}

- (BOOL)tapEnabled
{
	for ( UIGestureRecognizer * gesture in self.gestureRecognizers )
	{
		if ( [gesture isKindOfClass:[__SingleTapGestureRecognizer class]] )
		{
			return gesture.enabled;
		}
	}
	
	return NO;
}

- (void)setTapEnabled:(BOOL)flag
{
	__SingleTapGestureRecognizer * singleTapGesture = [self getTapGesture];
	if ( singleTapGesture )
	{
		singleTapGesture.enabled = flag;
	}
}

- (UITapGestureRecognizer *)tapGesture
{
	for ( UIGestureRecognizer * gesture in self.gestureRecognizers )
	{
		if ( [gesture isKindOfClass:[__SingleTapGestureRecognizer class]] )
		{
			return (UITapGestureRecognizer *)gesture;
		}
	}

	return nil;
}

- (NSString *)tapSignal
{
	__SingleTapGestureRecognizer * singleTapGesture = [self getTapGesture];
	if ( singleTapGesture )
	{
		return singleTapGesture.signalName;
	}
	
	return nil;
}

- (void)setTapSignal:(NSString *)signal
{
	__SingleTapGestureRecognizer * singleTapGesture = [self getTapGesture];
	if ( singleTapGesture )
	{
		singleTapGesture.signalName = signal;
	}
}

- (NSObject *)tapObject
{
	__SingleTapGestureRecognizer * singleTapGesture = [self getTapGesture];
	if ( singleTapGesture )
	{
		return singleTapGesture.signalObject;
	}
	
	return nil;
}

- (void)setTapObject:(NSObject *)object
{
	__SingleTapGestureRecognizer * singleTapGesture = [self getTapGesture];
	if ( singleTapGesture )
	{
		singleTapGesture.signalObject = object;
	}
}

@end
