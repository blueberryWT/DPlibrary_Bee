//
// Created by apple on 13-1-7.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UIView+LongPressGestureRecognizer.h"

@interface __SingleLongPressGestureRecognizer : UILongPressGestureRecognizer
{
    NSString *	_signalName;
    NSObject *	_signalObject;
}

@property (nonatomic, retain) NSString *	signalName;
@property (nonatomic, assign) NSObject *	signalObject;

@end


@implementation __SingleLongPressGestureRecognizer

@synthesize signalName = _signalName;
@synthesize signalObject = _signalObject;

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if ( self )
    {
        self.minimumPressDuration = 0.3;// [yu] 1秒之后就触发长按操作
        self.allowableMovement = 15.0f;// [yu] 在15S内可以进行移动
        self.numberOfTouchesRequired = 1;// [yu] 所需要触摸1次生效
    }
    return self;
}

- (void)dealloc
{
    [_signalName release];
    [super dealloc];
}

@end


@implementation UIView (LongPressGestureRecognizer)

DEF_SIGNAL(LONGPRESS_START)
DEF_SIGNAL(LONGPRESS_END)

@dynamic longPressable;
@dynamic longPressEnabled;
@dynamic longPressGesture;
@dynamic longPressSignal;
@dynamic longPressObject;

- (__SingleLongPressGestureRecognizer *)getLongPressGesture
{
    __SingleLongPressGestureRecognizer *longPressGesture = nil;

    for ( UIGestureRecognizer * gesture in self.gestureRecognizers )
    {
        if ( [gesture isKindOfClass:[__SingleLongPressGestureRecognizer class]] )
        {
            longPressGesture = (__SingleLongPressGestureRecognizer *)gesture;
        }
    }

    if ( nil == longPressGesture)
    {
        longPressGesture = [[[__SingleLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleLongPress:)] autorelease];
        [self addGestureRecognizer:longPressGesture];
    }

    return longPressGesture;
}

- (void)didSingleLongPress:(UILongPressGestureRecognizer *)tapGesture
{
    if ( [tapGesture isKindOfClass:[__SingleLongPressGestureRecognizer class]] )
    {
        __SingleLongPressGestureRecognizer * singleTapGesture = (__SingleLongPressGestureRecognizer *)tapGesture;

        if ( UIGestureRecognizerStateEnded == singleTapGesture.state )
        {
//            if ( singleTapGesture.signalName )
//            {
//                [self sendUISignal:singleTapGesture.signalName withObject:singleTapGesture.signalObject];
//            }
//            else
//            {
//                [self sendUISignal:UIView.LONGPRESS_START];
//            }
        }else if (UIGestureRecognizerStateBegan == singleTapGesture.state) {
            if ( singleTapGesture.signalName )
            {
                [self sendUISignal:singleTapGesture.signalName withObject:singleTapGesture.signalObject];
            }
            else
            {
                [self sendUISignal:UIView.LONGPRESS_START];
            }
        }
    }
}

- (void)makeLongPress
{
    [self makeLongPressWithSignal:nil];
}

- (void)makeLongPressWithSignal:(NSString *)signal
{
    [self makeLongPressSignal:signal withObject:nil];
}

- (void)makeLongPressSignal:(NSString *)signal withObject:(NSObject *)obj
{
    self.userInteractionEnabled = YES;

    __SingleLongPressGestureRecognizer * singleTapGesture = [self getLongPressGesture];
    if ( singleTapGesture )
    {
        singleTapGesture.signalName = signal;
        singleTapGesture.signalObject = obj;
    }
}

- (void)makeUnLongPress
{
    for ( UIGestureRecognizer * gesture in self.gestureRecognizers )
    {
        if ( [gesture isKindOfClass:[__SingleLongPressGestureRecognizer class]] )
        {
            [self removeGestureRecognizer:gesture];
        }
    }
}

- (BOOL)longPressable
{
    return self.longPressEnabled;
}

- (void)setLongPressable:(BOOL)flag
{
    self.longPressEnabled = flag;
}

- (BOOL)longPressEnabled
{
    for ( UIGestureRecognizer * gesture in self.gestureRecognizers )
    {
        if ( [gesture isKindOfClass:[__SingleLongPressGestureRecognizer class]] )
        {
            return gesture.enabled;
        }
    }

    return NO;
}

- (void)setLongPressEnabled:(BOOL)flag
{
    __SingleLongPressGestureRecognizer * singleTapGesture = [self getLongPressGesture];
    if ( singleTapGesture )
    {
        singleTapGesture.enabled = flag;
    }
}

- (UITapGestureRecognizer *)longPressGesture
{
    for ( UIGestureRecognizer * gesture in self.gestureRecognizers )
    {
        if ( [gesture isKindOfClass:[__SingleLongPressGestureRecognizer class]] )
        {
            return (UITapGestureRecognizer *)gesture;
        }
    }

    return nil;
}

- (NSString *)longPressSignal
{
    __SingleLongPressGestureRecognizer * singleTapGesture = [self getLongPressGesture];
    if ( singleTapGesture )
    {
        return singleTapGesture.signalName;
    }

    return nil;
}

- (void)setLongPressSignal:(NSString *)signal
{
    __SingleLongPressGestureRecognizer * singleTapGesture = [self getLongPressGesture];
    if ( singleTapGesture )
    {
        singleTapGesture.signalName = signal;
    }
}

- (NSObject *)longPressObject
{
    __SingleLongPressGestureRecognizer * singleTapGesture = [self getLongPressGesture];
    if ( singleTapGesture )
    {
        return singleTapGesture.signalObject;
    }

    return nil;
}

- (void)setLongPressObject:(NSObject *)object
{
    __SingleLongPressGestureRecognizer * singleTapGesture = [self getLongPressGesture];
    if ( singleTapGesture )
    {
        singleTapGesture.signalObject = object;
    }
}
@end