//
//  AppDelegate.h
//  OTA Builder
//
//  Created by Carson Wu on 1/12/15.
//  Copyright © 2015 Carson Wu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "plistGenerator.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    BOOL hasChosenAProject;
    //project info
    NSString *projectFileFullPath;
    NSString *projectLocation, *xcodeProjectFile, *projectName, *dateString, *bundleId;
    NSMutableArray *provisionings;
}

@property (weak) IBOutlet NSButton *buildButton;
@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (unsafe_unretained) IBOutlet NSTextView *outputText;
@property (weak) IBOutlet NSScrollView *outputView;
@property (weak) IBOutlet NSButton *chooseProjectButton;
@property (weak) IBOutlet NSButton *clearLogButton;
@property (weak) IBOutlet NSPopUpButton *popupButton;
- (IBAction)startTask:(id)sender;
- (IBAction)stopTask:(id)sender;
- (IBAction)chooseProject:(id)sender;
- (IBAction)clearLog:(id)sender;
- (IBAction)chooseProvisioningProfile:(id)sender;

/**
 * NSTask
 */
@property (nonatomic, strong) __block NSTask *buildTask;
@property (nonatomic) BOOL isRunning;
@property (nonatomic, strong) NSPipe *outputPipe;

@end

