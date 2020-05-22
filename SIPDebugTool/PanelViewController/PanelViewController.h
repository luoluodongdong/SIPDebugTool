//
//  PanelViewController.h
//  SIPDebugTool
//
//  Created by WeidongCao on 2020/5/20.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyTableView.h"
#import "ORSSerialPort.h"
#import "ORSSerialPortManager.h"
#import "ORSSerialRequest.h"
#import "ORSSerialBuffer.h"

NS_ASSUME_NONNULL_BEGIN

@class ORSSerialPortManager;

@interface PanelViewController : NSViewController<MyTableViewDelegate,ORSSerialPortDelegate>
{
    IBOutlet NSPopUpButton *portPopUpBtn;
    IBOutlet NSButton *openBtn;
    IBOutlet NSTextView *inputTextView;
    IBOutlet NSButton *sendBtn;
    IBOutlet NSButton *clearCmdBtn;
    IBOutlet NSButton *clearLogBtn;
    IBOutlet NSTextView *logTextView;
    
    IBOutlet NSSearchField *searchField;
    IBOutlet NSSearchFieldCell *searchFieldCell;
    IBOutlet MyTableView *cmdsTableView;
}
-(IBAction)searchBtnSearchAction:(id)sender;
-(IBAction)openBtnAcion:(id)sender;
-(IBAction)sendBtnAction:(id)sender;
-(IBAction)clearCmdBtnAction:(id)sender;
-(IBAction)clearLogBtnAction:(id)sender;

@property (nonatomic, strong) ORSSerialPortManager *serialPortManager;
@property (nonatomic, strong) ORSSerialPort *_Nullable serialPort;

@end

NS_ASSUME_NONNULL_END
