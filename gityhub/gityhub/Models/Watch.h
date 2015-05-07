//
//  Watch.h
//  nearIM, Inc.
//
//  Created by Steven Frost-Ruebling on 4/22/15.
//  Copyright (c) 2015 nearIM All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Watch : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * repoName;
@property (nonatomic, retain) NSString * userIconURL;
@property (nonatomic, retain) NSString * userName;

@end
