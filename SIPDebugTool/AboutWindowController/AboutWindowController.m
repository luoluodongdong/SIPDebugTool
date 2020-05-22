//
//  AboutWindowController.m
//  UPHmonitor
//
//  Created by WeidongCao on 2020/4/26.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "AboutWindowController.h"
#import "ContentViewController.h"

@interface AboutWindowController ()

@property (weak) IBOutlet NSWindow *mainWindow;

@end

@implementation AboutWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // 设置标题隐藏
    self.mainWindow.titleVisibility = NSWindowTitleHidden;
    // 设置标题栏透明
    self.mainWindow.titlebarAppearsTransparent = YES;
    // 设置contentview与titlebar融合到一起（此时设置背景颜色也将影响titlebar的颜色）
    self.mainWindow.styleMask = self.window.styleMask | NSWindowStyleMaskFullSizeContentView;
    //[self.window setOpaque:NO];
    //[self.window setBackgroundColor:[NSColor colorWithCalibratedRed:0.5f green:0.8f blue:0.9f alpha:0.9]];  //背景色
    //[self.window setBackgroundColor:[NSColor windowBackgroundColor]];
    //[[self.window standardWindowButton:NSWindowZoomButton] setEnabled:NO];
    //[[self.window standardWindowButton:NSWindowMiniaturizeButton] setEnabled:NO];
    //self.window.alphaValue = 0.98;
    //毛玻璃效果
    NSVisualEffectView *visualEffectView = [[NSVisualEffectView alloc] initWithFrame:self.mainWindow.contentView.bounds];
    visualEffectView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    visualEffectView.material = 0x0;
    visualEffectView.blendingMode = 0x0;
    //visualEffectView.state = NSVisualEffectStateActive;
    [self.mainWindow.contentView addSubview:visualEffectView];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    ContentViewController *contentVC = [[ContentViewController alloc] init];
    [self.mainWindow.contentView addSubview:contentVC.view];
    
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSApplication sharedApplication] stopModal];
}

@end
