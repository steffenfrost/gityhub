//
//  GitWebServices.h
//  nearIM, Inc.

//
//  Created by Steven Frost-Ruebling on 4/16/15.
//  Copyright (c) 2015 nearIM All rights reserved.

//
//  http://www.objc.io/issue-10/networked-core-data-application.html
//

#import <Foundation/Foundation.h>

@interface GitWebServices : NSObject

// Called by an importer
- (void)fetchAllObjects:(void (^)(NSArray *objects))callback withUrl:(NSString *)urlString;

@end
