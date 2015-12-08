//
//  plistGenerator.m
//  OTA Builder
//
//  Created by Carson Wu on 7/12/15.
//  Copyright © 2015 Carson Wu. All rights reserved.
//

#import "plistGenerator.h"

@implementation plistGenerator

-(id)init{
    if (self == [super init]) {
//        [self generatePlistFile];
    }
    return self;
}

- (void)generatePlistFile{
    NSString *path = [self.exportPath stringByAppendingString:[NSString stringWithFormat:@"/%@.plist", self.fileName]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSMutableDictionary *data;// root object
    if ([fileManager fileExistsAtPath: path]) {
        // If the file exists, delete the file
        NSError *error;
        [fileManager removeItemAtPath:path error:&error];
    }else{
        // If the file doesn’t exist, create an empty dictionary which will be added into the plist file later
        data = [[NSMutableDictionary alloc] init];
    }
    
    //create assets array
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    NSDictionary *assetDict = @{@"kind":@"software-package",
                                 @"url":[NSString stringWithFormat:@"%@/%@.ipa", self.ftpUrl, self.fileName]};
    [assets addObject:assetDict];
    
    //create metadata dictionary
    NSDictionary *metaDataDict = @{@"bundle-identifier":self.targetBundleId,
                                                @"kind":@"software",
                                               @"title":self.ipaTitle};
    
    //create plist content info dictionary which includes assets array & metadata dictionary
    NSDictionary *contentDict = @{  @"assets":assets,
                                  @"metadata":metaDataDict};
    
    //create root array which inlcudes the contentDict
    NSArray *rootArr = [NSArray arrayWithObject:contentDict];
    
    //create root dictionary to include the root array
    NSDictionary *rootDict = @{@"items":rootArr};
    NSError *error = nil;
    id plist = [NSPropertyListSerialization dataWithPropertyList:rootDict format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    [plist writeToFile:path atomically:YES];
}

@end
