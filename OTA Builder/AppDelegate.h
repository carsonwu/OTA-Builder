//
//  AppDelegate.h
//  OTA Builder
//
//  Created by Carson Wu on 1/12/15.
//  Copyright © 2015 Carson Wu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSButton *buildButton;
@property (weak) IBOutlet NSPathControl *projectPath;
@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (weak) IBOutlet NSTextField *targetName;
@property (weak) IBOutlet NSTextField *provisioningProfileName;
@property (unsafe_unretained) IBOutlet NSTextView *outputText;
- (IBAction)startTask:(id)sender;
- (IBAction)stopTask:(id)sender;

/**
 * NSTask
 */
@property (nonatomic, strong) __block NSTask *buildTask;
@property (nonatomic) BOOL isRunning;
@property (nonatomic, strong) NSPipe *outputPipe;

@end

