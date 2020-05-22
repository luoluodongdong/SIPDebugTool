//
//  MyTableView.m
//  SIPDebugTool
//
//  Created by WeidongCao on 2020/5/20.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "MyTableView.h"

@implementation MyTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (NSMenu *)menuForEvent:(NSEvent *)event
{
    if (event.type == NSEventTypeRightMouseDown) {
        NSPoint menuPoint = [self convertPoint:[event locationInWindow] fromView:nil];
        NSInteger row = [self rowAtPoint:menuPoint];
        NSIndexSet *indexSet = [self selectedRowIndexes];
        if (row == -1 || [indexSet count] == 0) {
            return nil;
        }
        
        if ([indexSet containsIndex:row]) {
            NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Custom"];
            NSMenuItem *selectItem = [[NSMenuItem alloc] initWithTitle:@"Select" action:@selector(menuAction:) keyEquivalent:@""];
            [menu addItem:selectItem];
            NSMenuItem *sendItem = [[NSMenuItem alloc] initWithTitle:@"Send" action:@selector(menuAction:) keyEquivalent:@""];
            [menu addItem:sendItem];
            NSMenuItem *viewItem = [[NSMenuItem alloc] initWithTitle:@"View" action:@selector(menuAction:) keyEquivalent:@""];
            [menu addItem:viewItem];
            return menu;
        }
        return nil;
    }
    return nil;
}

-(void)menuAction:(id)sender{
    NSMenuItem *item = sender;
    NSLog(@"click menu item:[%@]",item.title);
    NSDictionary *event = @{@"name":item.title,@"data":@"click"};
    if ([self.rightKeyClickDelegate respondsToSelector:@selector(event:fromMyTable:)]) {
        [self.rightKeyClickDelegate event:event fromMyTable:self];
    }
}

@end
