//
//  AppDelegate.m
//  OTA Builder
//
//  Created by Carson Wu on 1/12/15.
//  Copyright © 2015 Carson Wu. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)runScriptWithArguments:(NSArray*)arguments{
    //1
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(taskQueue, ^{
        //2
        self.isRunning = YES;
        
        //3
        @try {
            // 01
            NSString *path = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"BuildScript" ofType:@"command"]];
            // 02
            self.buildTask = [[NSTask alloc] init];
            self.buildTask.launchPath = path;
            self.buildTask.arguments = arguments;
            [self.buildTask launch];
            [self.buildTask waitUntilExit];
        }
        @catch (NSException *exception) {
            NSLog(@"Problem runnig task:%@", [exception description]);
        }
        @finally {
            [self.buildButton setEnabled:YES];
            [self.spinner stopAnimation:self];
            self.isRunning = NO;
        }
    });
}

#pragma mark - IBAction

- (IBAction)startTask:(id)sender {
    
    self.outputText.string = @"";
    
    NSString *projectLocation = self.projectPath.URL.path;
    NSString *finalLocation = self.repoPath.URL.path;
    
    NSString *projectName = self.projectPath.URL.lastPathComponent;
    NSString *xcodeProjectFile = [projectLocation stringByAppendingString:[NSString stringWithFormat:@"/%@.xcodeproj", projectName]];
    
    NSString *buildLocation = projectLocation;//[projectLocation stringByAppendingString:@"/build/Release-iphoneos"];
    
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    [arguments addObject:xcodeProjectFile];
    [arguments addObject:self.targetName.stringValue];
    [arguments addObject:buildLocation];
    [arguments addObject:projectName];
    [arguments addObject:finalLocation];
    
    [self.buildButton setEnabled:NO];
    [self.spinner startAnimation:self];
    [self runScriptWithArguments:arguments];
}

- (IBAction)stopTask:(id)sender {
}

@end
