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
//  UIView+BeeQuery.m
//

#import "Bee_Precompile.h"
#import "Bee_UISignal.h"
#import "Bee_UIImageView.h"
#import "Bee_UILabel.h"
#import "UIView+BeeQuery.h"

#include <objc/runtime.h>
#include <execinfo.h>

#pragma mark -

@implementation UIView(BeeQuery)

@dynamic tagString;

static BOOL __ivarAdded = NO;
static Ivar	__ivar = NULL;

+ (void)customizeClass
{
	if ( NO == __ivarAdded )
	{
		Ivar ivar = class_getInstanceVariable( [UIView class], "__tagString" );
		if ( nil == ivar )
		{
			BOOL ret = class_addIvar( [UIView class], "__tagString", sizeof(NSString *), (sizeof(NSString *) / 4 * 4), "@" );
			if ( ret )
			{
				__ivar = class_getInstanceVariable( [UIView class], "__tagString" );
				__ivarAdded = __ivar ? YES : NO;
			}
		}
	}
}

- (NSString *)tagString
{
	[UIView customizeClass];
	
	if ( nil == __ivar )
		return nil;
	
	NSObject * obj = object_getIvar( self, __ivar );
	if ( obj && [obj isKindOfClass:[NSString class]] )
		return (NSString *)obj;
	
	return nil;
}

- (void)setTagString:(NSString *)value
{
	[UIView customizeClass];
	
	if ( __ivar )
	{
		object_setIvar( self, __ivar, [value retain] );
	}
}

- (UIView *)viewWithTagString:(NSString *)value
{
	if ( nil == value )
		return nil;
	
	[UIView customizeClass];
	
	for ( UIView * subview in self.subviews )
	{
		if ( [subview.tagString isEqualToString:value] )
		{
			return subview;
		}
	}
	
	return nil;
}

- (UIView *)viewAtPath:(NSString *)path
{
	if ( nil == path || 0 == path.length )
		return nil;

	NSString *	keyPath = [path stringByReplacingOccurrencesOfString:@"/" withString:@"."];
	NSRange		range = NSMakeRange( 0, 1 );

	if ( [[keyPath substringWithRange:range] isEqualToString:@"."] )
	{
		keyPath = [keyPath substringFromIndex:1];
	}
	
	NSObject * result = [self valueForKeyPath:keyPath];
	if ( result == [NSNull null] || NO == [result isKindOfClass:[UIView class]] )
		return nil;
	
	return (UIView *)result;
}

- (UIView *)subview:(NSString *)name
{
	if ( nil == name || 0 == [name length] )
		return nil;
	
	NSObject * view = [self valueForKey:name];
	
	if ( [view isKindOfClass:[UIView class]] )
	{
		return (UIView *)view;
	}
	else
	{
		return nil;
	}
}

- (UIViewController *)viewController
{
	if ( nil != self.superview )
		return nil;
	
	id nextResponder = [self nextResponder];
	if ( [nextResponder isKindOfClass:[UIViewController class]] )
	{
		return (UIViewController *)nextResponder;
	}
	else
	{
		return nil;
	}
}

@end

#pragma mark -

@implementation UIViewController(BeeQuery)

- (UIView *)viewIfLoaded
{
	if ( NO == self.isViewLoaded )
		return nil;
	
	return self.view;
}

- (UIView *)viewWithTagString:(NSString *)value
{
	if ( NO == self.isViewLoaded )
		return nil;
	
	return [self.view viewWithTagString:value];
}


- (UIView *)viewAtPath:(NSString *)path
{
	if ( NO == self.isViewLoaded )
		return nil;

	return [self.view viewAtPath:path];
}

- (UIView *)subview:(NSString *)name
{
	if ( NO == self.isViewLoaded )
		return nil;
	
	return [self.view subview:name];
}

@end
