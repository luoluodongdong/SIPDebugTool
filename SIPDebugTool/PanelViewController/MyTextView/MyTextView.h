//
//  MyTextView.h
//  SIPDebugTool
//
//  Created by weidongcao on 2020/7/16.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyTextView : NSTextView
- (BOOL)performKeyEquivalent:(NSEvent *)event;
@end

NS_ASSUME_NONNULL_END
