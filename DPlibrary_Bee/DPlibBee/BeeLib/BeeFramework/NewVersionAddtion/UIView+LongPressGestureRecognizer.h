//
// Created by apple on 13-1-7.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@interface UIView (LongPressGestureRecognizer)


@property (nonatomic, assign) BOOL longPressable;	// backward compatible
@property (nonatomic, assign) BOOL longPressEnabled;
@property (nonatomic, retain) NSString *longPressSignal;
@property (nonatomic, retain) NSObject *longPressObject;
@property (nonatomic, readonly) UILongPressGestureRecognizer *longPressGesture;

AS_SIGNAL(LONGPRESS_START) // [yu] 长按 开始
AS_SIGNAL(LONGPRESS_END) // [yu] 长按 结束

- (void)makeLongPress;
- (void)makeLongPressWithSignal:(NSString *)signal;
- (void)makeLongPressSignal:(NSString *)signal withObject:(NSObject *)obj;
- (void)makeUnLongPress;
@end