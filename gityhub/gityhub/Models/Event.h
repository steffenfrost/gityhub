//
//  Event.h
//  nearIM, Inc.

//
//  Created by Steven Frost-Ruebling on 4/20/15.
//  Copyright (c) 2015 nearIM All rights reserved.

//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * actionTaken;
@property (nonatomic, retain) NSString * forksUrl;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * repoIdentifier;
@property (nonatomic, retain) NSString * repoName;
@property (nonatomic, retain) NSString * repoUrl;
@property (nonatomic, retain) NSString * userIconURL;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * watchersUrl;
@property (nonatomic, retain) NSDate * timeStamp;

@end
