//
//  Watch+Persist.h
//  nearIM, Inc.

//
//  Created by Steven Frost-Ruebling on 4/16/15.
//  Copyright (c) 2015 nearIM All rights reserved.

//

#import "Watch.h"
#import "NSManagedObject+Helpers.h"

@interface Watch (Persist)

- (void)loadFromDictionary:(NSDictionary *)dictionary;
+ (Watch *)findOrCreateWatchWithIdentifier:(id)identifier inContext:(NSManagedObjectContext *)context;

@end
