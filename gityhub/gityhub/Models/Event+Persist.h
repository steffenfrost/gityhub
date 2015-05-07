//
//  Event+Persist.h
//  nearIM, Inc.
//
//  Created by Steven Frost-Ruebling on 4/14/15.
//  Copyright (c) 2015 nearIM All rights reserved.
//

#import "Event.h"
#import "NSManagedObject+Helpers.h"

@interface Event (Persist)

- (void)loadFromDictionary:(NSDictionary *)dictionary;
+ (Event *)findOrCreateEventWithIdentifier:(id)identifier inContext:(NSManagedObjectContext *)context;

@end
