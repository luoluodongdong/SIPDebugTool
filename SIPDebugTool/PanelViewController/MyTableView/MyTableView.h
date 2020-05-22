//
//  MyTableView.h
//  SIPDebugTool
//
//  Created by WeidongCao on 2020/5/20.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MyTableViewDelegate <NSObject>

-(void)event:(NSDictionary *)event fromMyTable:(id)tableview;

@end

@interface MyTableView : NSTableView<NSTableViewDataSource,NSTableViewDelegate>


@property (retain) NSTableView *tableView;
@property (weak) id<MyTableViewDelegate> rightKeyClickDelegate;

@end

NS_ASSUME_NONNULL_END
