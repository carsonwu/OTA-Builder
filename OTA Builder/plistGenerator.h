//
//  plistGenerator.h
//  OTA Builder
//
//  Created by Carson Wu on 7/12/15.
//  Copyright © 2015 Carson Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface plistGenerator : NSObject
/*The path or directory where you want to export the plist file*/
@property (nonatomic, strong) NSString* exportPath;

/*The file name of the plist file*/
@property (nonatomic, strong) NSString* fileName;

/*The specific FTP folder where you want to upload the plist file*/
@property (nonatomic, strong) NSString* ftpUrl;

/*The name which will show in the alert view when the ipa is being downloaded*/
@property (nonatomic, strong) NSString* ipaTitle;

/*The bundle Id of the target project which is to be export*/
@property (nonatomic, strong) NSString* targetBundleId;

- (void)generatePlistFile;

@end
