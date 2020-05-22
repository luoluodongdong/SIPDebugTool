//
//  PanelViewController.m
//  SIPDebugTool
//
//  Created by WeidongCao on 2020/5/20.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "PanelViewController.h"

@interface PanelViewController ()

@property (retain, nonatomic) NSMutableArray *commandsArray;
@property (retain, nonatomic) NSArray *filterData;
@property dispatch_queue_t printLogQueue;
@property dispatch_queue_t searchActionQueue;
@property (retain, nonatomic) NSString *currentCommand;
@property BOOL isUpdating;
@property NSMutableString *logString;
@property (retain, nonatomic) NSTimer *timer;
@property NSNumber *baudrate;
@end

@implementation PanelViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.isUpdating = NO;
    self.currentCommand = @"";
    self.logString = [NSMutableString string];
    self.printLogQueue = dispatch_queue_create("com.sipdebugtool.printlogqueue", DISPATCH_QUEUE_SERIAL);
    self.searchActionQueue = dispatch_queue_create("com.sipdebugtool.searchactionqueue", DISPATCH_QUEUE_SERIAL);
    NSSearchFieldCell *searchCell=searchFieldCell;
    NSButtonCell *searchBtnCell = [searchCell searchButtonCell];
    [searchBtnCell setTarget:self];
    [searchBtnCell setAction:@selector(searchBtnSearchAction:)];
    NSButtonCell *cancelBtnCell = [searchCell cancelButtonCell];
    [cancelBtnCell setTarget:self];
    [cancelBtnCell setAction:@selector(searchBtnCancelAction:)];
    cmdsTableView.rightKeyClickDelegate = self;
    
    //load commands.txt file
    NSString *listFile = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/files/commands.txt"];
    NSString *listData=[NSString stringWithContentsOfFile:listFile encoding:NSUTF8StringEncoding error:nil];
    NSArray *cmdAll = [listData componentsSeparatedByString:@"\n"];
    if ([cmdAll count] > 0) {
        //NSLog(@"===cmdAll:%@",cmdAll);
        NSArray *sortCmds=[cmdAll sortedArrayUsingSelector:@selector(compare:)];
        //NSLog(@"==>>sortCmds:%@",sortCmds);
        self.commandsArray = [NSMutableArray new];
        for (NSString *cmd in sortCmds)
        {
            [self.commandsArray addObject:cmd];
        }
        self.filterData = self.commandsArray;
        [cmdsTableView reloadData];
    }
    
    NSString *configFile=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"config.plist"];
    NSDictionary *rootSet = [NSDictionary dictionaryWithContentsOfFile:configFile];
    self.baudrate=[rootSet objectForKey:@"baudrate"];
    NSLog(@"load baudrate:%@",self.baudrate);
    [portPopUpBtn removeAllItems];
    self.serialPortManager = [ORSSerialPortManager sharedSerialPortManager];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(serialPortsWereConnected:) name:ORSSerialPortsWereConnectedNotification object:nil];
    [nc addObserver:self selector:@selector(serialPortsWereDisconnected:) name:ORSSerialPortsWereDisconnectedNotification object:nil];
}
-(void)viewWillAppear{
    self.timer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(timeTick) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
-(void)viewDidAppear{
    
}
-(IBAction)searchBtnCancelAction:(id)sender{
    NSLog(@"click searchField-canel btn");
    [searchField setStringValue:@""];
    self.filterData = self.commandsArray;
    [cmdsTableView reloadData];
}
-(IBAction)searchBtnSearchAction:(id)sender{
    NSLog(@"click searchField-search btn");
    NSString *searchStr = [searchField stringValue];
    if ([searchStr length] == 0) {
        [self searchBtnCancelAction:searchField];
        return;
    }
    dispatch_async(self.searchActionQueue, ^{
        [self performSelectorOnMainThread:@selector(showSearchResult:) withObject:searchStr waitUntilDone:YES];
    });
    
}
-(void)showSearchResult:(NSString *)searchStr{
    //定义谓词
    //[c]标示不区分大小写
    NSString *t = [NSString stringWithFormat:@"self like [c]'*%@*'",searchStr];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:t];
    //过滤元素
    self.filterData = [self.commandsArray filteredArrayUsingPredicate:predicate];
    //刷新视图
    [cmdsTableView reloadData];
}

-(IBAction)openBtnAcion:(id)sender{
    self.serialPort.baudRate = self.baudrate;
    if ([openBtn.title isEqualToString:@"Open"]) {
        NSString *log = [NSString stringWithFormat:@"[info]serial port:%@ baudrate:%@\r\n",self.serialPort.name,self.baudrate];
        dispatch_async(self.printLogQueue, ^{
            [self safeAppendLog:log];
        });
    }
    self.serialPort.isOpen ? [self.serialPort close] : [self.serialPort open];
}
-(IBAction)sendBtnAction:(id)sender{
    NSString *cmd = [inputTextView.textStorage string];
    if ([cmd length] == 0) {
        return;
    }
    [self sendCommand:cmd];
}
-(void)sendCommand:(NSString *)cmd{
    if (self.serialPort == nil || self.serialPort.isOpen == NO) {
        dispatch_async(self.printLogQueue, ^{
            [self safeAppendLog:@"[error]please open serial first!\r\n"];
        });
        return;
    }
    NSString *log=[NSString stringWithFormat:@"[TX]%@\r\n",cmd];
    dispatch_async(self.printLogQueue, ^{
        [self safeAppendLog:log];
    });
    cmd = [cmd stringByAppendingString:@"\r\n"];
    [self.serialPort sendData:[cmd dataUsingEncoding:NSUTF8StringEncoding]];
}
-(IBAction)clearCmdBtnAction:(id)sender{
    inputTextView.string = @"";
}
-(IBAction)clearLogBtnAction:(id)sender{
    logTextView.string = @"";
}

#pragma mark --TableView
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.filterData count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:( NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([self.filterData count] == 0) {
        return nil;
    }
    
    //return cell;
    return [self.filterData objectAtIndex:row];
}


- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger row = [cmdsTableView selectedRow];
    if (row >= [self.filterData count]) {
        return;
    }
    NSString *clickCmd=[self.filterData objectAtIndex:row];
    NSLog(@"click cmd:%@",clickCmd);
    //[self updateCmds:clickCmd];
    self.currentCommand = clickCmd;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    return true ;
}

-(void)event:(NSDictionary *)event fromMyTable:(id)tableview{
    NSString *eventName = [event objectForKey:@"name"];
    NSLog(@"event:%@ form tableview:%@",[tableview identifier],[event description]);
    if ([eventName isEqualToString:@"View"]) {
        NSString *log=[NSString stringWithFormat:@"[View] item => %@\r\n",self.currentCommand];
        dispatch_async(self.printLogQueue, ^{
            [self safeAppendLog:log];
        });
    }else if([eventName isEqualToString:@"Select"]){
        NSString *log=[NSString stringWithFormat:@"[Select] item => %@\r\n",self.currentCommand];
        dispatch_async(self.printLogQueue, ^{
            [self safeAppendLog:log];
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updatSelectedCmds];
        });
    }else if([eventName isEqualToString:@"Send"]){
        [self sendCommand:self.currentCommand];
    }
}
-(void)updatSelectedCmds{
    NSString *inputStr = [inputTextView.textStorage string];
    if ([inputStr length] == 0) {
        NSAttributedString *attrString= [[NSAttributedString alloc] initWithString:self.currentCommand];
        [inputTextView.textStorage appendAttributedString:attrString];
    }else{
        NSAttributedString *attrString= [[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@";%@",self.currentCommand]];
        [inputTextView.textStorage appendAttributedString:attrString];
    }
}
//自动刷新log view
-(void)timeTick{
    if (self.isUpdating == YES) {
            return;
        }
        self.isUpdating = YES;
        NSUInteger textLen = self->logTextView.textStorage.length;
        if (textLen > 500000) {
            [self->logTextView.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:@""]];
        }
        NSString *log = [self safeReadLog];
        if ([log isEqualToString:@""]) {
            self.isUpdating = NO;
            return;
        }
        // 设置字体颜色NSForegroundColorAttributeName，取值为 UIColor对象，默认值为黑色
        NSMutableAttributedString *textColor = [[NSMutableAttributedString alloc] initWithString:log];
    //        [textColor addAttribute:NSForegroundColorAttributeName
    //                          value:[NSColor greenColor]
    //                          range:[@"NSAttributedString设置字体颜色" rangeOfString:@"NSAttributedString"]];
        [textColor addAttribute:NSForegroundColorAttributeName
                          value:[NSColor systemGreenColor]
                          range:NSMakeRange(0, log.length)];
        
        //NSAttributedString *attrStr=[[NSAttributedString alloc] initWithString:self.logString];
        textLen = textLen + log.length;
        [self->logTextView.textStorage appendAttributedString:textColor];
        [self->logTextView scrollRangeToVisible:NSMakeRange(textLen,0)];
        self.isUpdating = NO;
}
//存 log
-(void)safeAppendLog:(NSString *)log{
    @synchronized (self) {
        [self.logString appendString:log];
    }
}
//取 log
-(NSString *)safeReadLog{
    @synchronized (self) {
        NSMutableString *logStr = self.logString;
        [self setLogString:[NSMutableString string]];
        return logStr;
    }
}
#pragma mark - ORSSerialPortDelegate Methods

- (void)serialPortWasOpened:(ORSSerialPort *)serialPort
{
    openBtn.title = @"Close";
    [portPopUpBtn setEnabled:NO];
    dispatch_async(self.printLogQueue, ^{
        [self safeAppendLog:@"serial port opened successful!\r\n"];
    });
}

- (void)serialPortWasClosed:(ORSSerialPort *)serialPort
{
    openBtn.title = @"Open";
    [portPopUpBtn setEnabled:YES];
    dispatch_async(self.printLogQueue, ^{
        [self safeAppendLog:@"serial port closed!\r\n"];
    });
}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    dispatch_async(self.printLogQueue, ^{
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([string length] == 0) return;
        [self safeAppendLog:string];
    });
}

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort;
{
    // After a serial port is removed from the system, it is invalid and we must discard any references to it
    self.serialPort = nil;
    openBtn.title = @"Open";
    dispatch_async(self.printLogQueue, ^{
        [self safeAppendLog:@"serial port was removed form system!\r\n"];
    });
}

- (void)serialPort:(ORSSerialPort *)serialPort didEncounterError:(NSError *)error
{
    NSLog(@"Serial port %@ encountered an error: %@", serialPort, error);
    dispatch_async(self.printLogQueue, ^{
        [self safeAppendLog:[NSString stringWithFormat:@"[error]%@\r\n",[error localizedDescription]]];
    });
}

#pragma mark - NSUserNotificationCenterDelegate

#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [center removeDeliveredNotification:notification];
    });
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

#endif

#pragma mark - Notifications

- (void)serialPortsWereConnected:(NSNotification *)notification
{
    NSArray *connectedPorts = [notification userInfo][ORSConnectedSerialPortsKey];
    NSLog(@"Ports were connected: %@", connectedPorts);
    [self postUserNotificationForConnectedPorts:connectedPorts];
    NSString *log = [NSString stringWithFormat:@"Ports were connected: %@\r\n", connectedPorts];
    dispatch_async(self.printLogQueue, ^{
        [self safeAppendLog:log];
    });
}

- (void)serialPortsWereDisconnected:(NSNotification *)notification
{
    NSArray *disconnectedPorts = [notification userInfo][ORSDisconnectedSerialPortsKey];
    NSLog(@"Ports were disconnected: %@", disconnectedPorts);
    [self postUserNotificationForDisconnectedPorts:disconnectedPorts];
    NSString *log = [NSString stringWithFormat:@"Ports were disconnected: %@\r\n", disconnectedPorts];
    dispatch_async(self.printLogQueue, ^{
        [self safeAppendLog:log];
    });
}

- (void)postUserNotificationForConnectedPorts:(NSArray *)connectedPorts
{
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
    if (!NSClassFromString(@"NSUserNotificationCenter")) return;
    
    NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
    for (ORSSerialPort *port in connectedPorts)
    {
        NSUserNotification *userNote = [[NSUserNotification alloc] init];
        userNote.title = NSLocalizedString(@"Serial Port Connected", @"Serial Port Connected");
        NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was connected to your Mac.", @"Serial port connected user notification informative text");
        userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
        userNote.soundName = nil;
        [unc deliverNotification:userNote];
    }
#endif
}

- (void)postUserNotificationForDisconnectedPorts:(NSArray *)disconnectedPorts
{
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
    if (!NSClassFromString(@"NSUserNotificationCenter")) return;
    
    NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
    for (ORSSerialPort *port in disconnectedPorts)
    {
        NSUserNotification *userNote = [[NSUserNotification alloc] init];
        userNote.title = NSLocalizedString(@"Serial Port Disconnected", @"Serial Port Disconnected");
        NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was disconnected from your Mac.", @"Serial port disconnected user notification informative text");
        userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
        userNote.soundName = nil;
        [unc deliverNotification:userNote];
    }
#endif
}


#pragma mark - Properties

- (void)setSerialPort:(ORSSerialPort *)port
{
    if (port != _serialPort)
    {
        [_serialPort close];
        _serialPort.delegate = nil;
        
        _serialPort = port;
        
        _serialPort.delegate = self;
        NSLog(@"1111111");
    }
}

@end
