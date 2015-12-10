//
//  AppDelegate.m
//  OTA Builder
//
//  Created by Carson Wu on 1/12/15.
//  Copyright © 2015 Carson Wu. All rights reserved.
//

#import "AppDelegate.h"
#import "Provisioning.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    hasChosenAProject = NO;
    [self getProvisioningProfileInfo];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)getProvisioningProfileInfo{
    provisionings = [[NSMutableArray alloc] init];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *LibPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *provisioningDir = [LibPath stringByAppendingString:@"/MobileDevice/Provisioning Profiles"];
    NSError *error;
    NSArray *provisioningArr = [fm contentsOfDirectoryAtPath:provisioningDir error:&error];
    if (!error) {
        for (NSString* file in provisioningArr){
            if ([file hasPrefix:@"."])
                continue;
            Provisioning *provisioning = [[Provisioning alloc] initWithPath:[NSString stringWithFormat:@"%@/%@", provisioningDir, file]];
            if ([provisioning isExpired])
                continue;
            [provisionings addObject:provisioning.name];
        }
        [provisionings sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [self.popupButton removeAllItems];
        [self.popupButton addItemsWithTitles:provisionings];
        [self.popupButton insertItemWithTitle:@"Choose Provisioning Profile" atIndex:0];//add one more item and put it in the first as the default title.
    }
}

- (void)runScriptWithArguments:(NSArray*)arguments{
    //1
    [self.outputView setHidden:NO];
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(taskQueue, ^{
        //2
        self.isRunning = YES;
        
        //3
        @try {
            // 01
            NSString *path = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"OTAScript" ofType:@"sh"]];
            // 02
            self.buildTask = [[NSTask alloc] init];
            self.buildTask.launchPath = path;
            self.buildTask.arguments = arguments;
            
            //output handling
            self.outputPipe = [[NSPipe alloc] init];
            self.buildTask.standardOutput = self.outputPipe;
            [[self.outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:[self.outputPipe fileHandleForReading] queue:nil usingBlock:^(NSNotification *note) {
                NSData *outputData = [self.outputPipe fileHandleForReading].availableData;
                NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.outputText.string = [self.outputText.string stringByAppendingString:[NSString stringWithFormat:@"\n%@", outputString]];
                    [self.outputText scrollRangeToVisible:NSMakeRange(self.outputText.string.length, 0)];
                });
                [[self.outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            }];
            
            [self.buildTask launch];
            [self.buildTask waitUntilExit];
            if (self.buildTask.terminationReason == NSTaskTerminationReasonExit) {
                [self generatePlistFile];
                self.clearLogButton.hidden = NO;
            }else{
                NSLog(@"stop button clicked");
            }
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

- (void)removeOutputTestView{
    self.clearLogButton.hidden = YES;
    [self.outputView setHidden:YES];
}

- (void)showAlertWithMessage:(NSString*)message{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Warning"];
    [alert setInformativeText:message];
    [alert runModal];
}

- (void)generatePlistFile{
    //create .plist file
    plistGenerator *plist = [[plistGenerator alloc] init];
    plist.exportPath = projectLocation;
    plist.ftpUrl = @"www.google.com";
    plist.ipaTitle = projectName;
    plist.targetBundleId = @"";
    plist.fileName = [NSString stringWithFormat:@"%@-%@", projectName, dateString];
    [plist generatePlistFile];
}

#pragma mark - IBAction

- (IBAction)startTask:(id)sender {
    
    if (!hasChosenAProject) {
        //prompt alert
        [self showAlertWithMessage:@"Please choose your project through \"Choose Project\" button before proceding."];
    }else{
        self.outputText.string = @"";
        self.clearLogButton.hidden = YES;
        
        NSString *archiveFile = [NSString stringWithFormat:@"%@.xcarchive", projectName];
        NSString *provisioningProfile = self.popupButton.title;//self.provisioningProfileName.stringValue;
        //get current timestamp
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat: @"yyyyMMddHHmm"];
        dateString = [dateFormatter stringFromDate:[NSDate date]];
        
        NSMutableArray *arguments = [[NSMutableArray alloc] init];
        [arguments addObject:projectLocation];
        [arguments addObject:xcodeProjectFile];
        [arguments addObject:projectName];
        [arguments addObject:archiveFile];
        [arguments addObject:provisioningProfile];
        [arguments addObject:[NSString stringWithFormat:@"%@-%@", projectName, dateString]];
        
        [self.buildButton setEnabled:NO];
        [self.spinner startAnimation:self];
        [self runScriptWithArguments:arguments];
    }
}

- (IBAction)stopTask:(id)sender {
    if ([self.buildTask isRunning]) {
        [self.buildTask terminate];
        [self removeOutputTestView];
    }
}

- (IBAction)chooseProject:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:@[@"xcodeproj", @"xcworkspace"]];
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            hasChosenAProject = YES;
            projectLocation = panel.directoryURL.path;
            projectFileFullPath = panel.URL.path;
            xcodeProjectFile = [projectFileFullPath lastPathComponent];
            projectName = [[projectFileFullPath lastPathComponent] stringByDeletingPathExtension];
            self.chooseProjectButton.title = projectName;
        }
    }];
}

- (IBAction)clearLog:(id)sender {
    [self removeOutputTestView];
}

- (IBAction)chooseProvisioningProfile:(id)sender {
    self.popupButton.title = self.popupButton.titleOfSelectedItem;
}

@end
