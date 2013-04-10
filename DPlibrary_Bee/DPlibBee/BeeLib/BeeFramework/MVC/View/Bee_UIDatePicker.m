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
//  Bee_UIDatePicker.m
//

#import "Bee_Precompile.h"
#import "Bee_UIDatePicker.h"
#import "Bee_UISignal.h"
#import "UIView+BeeQuery.h"

@interface BeeUIDatePicker(Private)
- (void)didDateChanged;
- (void) selectedEvent:(id) sender;
-(void) cancelEvent:(id) sender;
@end

@implementation BeeUIDatePicker

DEF_SIGNAL( WILL_PRESENT )
DEF_SIGNAL( DID_PRESENT )
DEF_SIGNAL( WILL_DISMISS )
DEF_SIGNAL( DID_DISMISS )
DEF_SIGNAL( CHANGED )
DEF_SIGNAL( CONFIRMED )

@synthesize date = _date;
@synthesize userData = _userData;
@synthesize parentView = _parentView;
@synthesize toolBar = _toolBar;
@synthesize datePicker = _datePicker;


+ (BeeUIDatePicker *)spawn
{
	return [[[BeeUIDatePicker alloc] init] autorelease];
}

- (id)init
{
	self = [super init];
	if ( self )
	{
		self.delegate = self;
		self.date = [NSDate date];
		self.title = @"\n\n\n\\n\n\n\\n\n\n\n\n\n\n\n";
		self.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		self.actionSheetStyle = UIActionSheetStyleDefault;
//		self.cancelButtonIndex = [self addButtonWithTitle:@"确定"];
	}
	return self;
}

- (void)dealloc
{
	SAFE_RELEASE_SUBVIEW( _datePicker );

	[_date release];
	[_userData release];

    [_toolBar release];
    [_dpMinDate release], _dpMinDate = nil;
    [_dpMaxDate release], _dpMaxDate = nil;
    [super dealloc];
}

- (void)presentForController:(UIViewController *)controller
{
	_parentView = controller.view;
	
	[self showInView:controller.view];
}

-(id) initWithDatePickerModel:(UIDatePickerMode) model withMaxDate:(NSDate*) maxDateValue withMinDate:(NSDate *) minDate {
    self = [self init];
    if (self) {
        self.datePickerModel = model;
        self.dpMaxDate = maxDateValue;
        self.dpMinDate = minDate;
    }
    return self;
}


#pragma mark -
#pragma mark UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ( buttonIndex == self.cancelButtonIndex )
	{
		NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:_datePicker.date, @"date", nil];
		if ( _parentView )
		{
			[_parentView sendUISignal:BeeUIDatePicker.CONFIRMED withObject:dict from:self];
		}
		else
		{
			[self sendUISignal:BeeUIDatePicker.CONFIRMED withObject:dict from:self];
		}
	}
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
}

// before animation and showing view
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {

    if (nil == _toolBar) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 35)];
        [_toolBar setBarStyle:UIBarStyleBlackTranslucent];
        [self addSubview:_toolBar];

        UIBarButtonItem *leftRoteItem = [[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelEvent:)] autorelease];

        UIBarButtonItem *rightRoteItem = [[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(selectedEvent:)] autorelease];

        UIBarButtonItem *spaceItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:@selector(selectedEvent:)] autorelease];
        [spaceItem setWidth:202];
        [spaceItem setEnabled:NO];

        UIBarButtonItem *spaceItemLeft = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:@selector(selectedEvent:)] autorelease];
        [spaceItemLeft setWidth:5];
        [spaceItemLeft setEnabled:NO];

        [_toolBar setItems:@[spaceItemLeft,leftRoteItem,spaceItem,rightRoteItem]];
    }

    if (nil == _datePicker) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 207, 320, 207)];
        _datePicker.date = _date ? _date : [NSDate dateWithTimeIntervalSince1970:0];
        _datePicker.datePickerMode = self.datePickerModel;
        _datePicker.calendar = [NSCalendar currentCalendar];
//        _datePicker.maximumDate = [NSDate date];

        if (self.dpMaxDate) {
            [_datePicker setMaximumDate:self.dpMaxDate];
        }

        if (self.dpMinDate) {
            [_datePicker setMinimumDate:self.dpMinDate];
        }

        [_datePicker addTarget:self action:@selector(didDateChanged) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_datePicker];
    }

    if (_parentView) {
        [_parentView sendUISignal:BeeUIDatePicker.WILL_PRESENT withObject:nil from:self];
    }
    else {
        [self sendUISignal:BeeUIDatePicker.WILL_PRESENT withObject:nil from:self];
    }
}

- (void)didDateChanged
{
	NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:_datePicker.date, @"date", nil];
	if ( _parentView )
	{
		[_parentView sendUISignal:BeeUIDatePicker.CHANGED withObject:dict from:self];
	}
	else
	{
		[self sendUISignal:BeeUIDatePicker.CHANGED withObject:dict from:self];
	}
}

- (void)selectedEvent:(id)sender {
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:_datePicker.date, @"date", nil];
    [_parentView sendUISignal:BeeUIDatePicker.CONFIRMED withObject:dict from:self];
    [self dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)cancelEvent:(id)sender {
    [self dismissWithClickedButtonIndex:0 animated:YES];
}


// after animation
- (void)didPresentActionSheet:(UIActionSheet *)actionSheet
{
	if ( _parentView )
	{
		[_parentView sendUISignal:BeeUIDatePicker.DID_PRESENT withObject:nil from:self];
	}
	else
	{
		[self sendUISignal:BeeUIDatePicker.DID_PRESENT withObject:nil from:self];
	}
}

// before animation and hiding view
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if ( _parentView )
	{
		[_parentView sendUISignal:BeeUIDatePicker.WILL_DISMISS withObject:nil from:self];
	}
	else
	{
		[self sendUISignal:BeeUIDatePicker.WILL_DISMISS withObject:nil from:self];
	}
}

// after animation
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if ( _parentView )
	{
		[_parentView sendUISignal:BeeUIDatePicker.DID_DISMISS withObject:nil from:self];		
	}
	else
	{
		[self sendUISignal:BeeUIDatePicker.DID_DISMISS withObject:nil from:self];		
	}
}

@end
