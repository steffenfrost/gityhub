//
//  Fork.h
//  nearIM, Inc.
//
//  Created by Steven Frost-Ruebling on 4/20/15.
//  Copyright (c) 2015 nearIM All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Fork : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * repoName;
@property (nonatomic, retain) NSString * userIconURL;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSDate * timeStamp;

@end
