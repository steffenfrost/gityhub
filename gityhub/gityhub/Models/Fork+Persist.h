//
//  Fork+Persist.h
//  nearIM, Inc.
//
//  Created by Steven Frost-Ruebling on 4/16/15.
//  Copyright (c) 2015 nearIM All rights reserved.
//

#import "Fork.h"
#import "NSManagedObject+Helpers.h"

@interface Fork (Persist)

- (void)loadFromDictionary:(NSDictionary *)dictionary;
+ (Fork *)findOrCreateForkWithIdentifier:(id)identifier inContext:(NSManagedObjectContext *)context;

@end
