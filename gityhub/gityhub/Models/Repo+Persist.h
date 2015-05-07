//
//  Repo+Persist.h
//  nearIM, Inc.

//
//  Created by Steven Frost-Ruebling on 4/16/15.
//  Copyright (c) 2015 nearIM All rights reserved.

//

#import "Repo.h"
#import "NSManagedObject+Helpers.h"

@interface Repo (Persist)

- (void)loadFromDictionary:(NSDictionary *)dictionary;
+ (Repo *)findOrCreateRepoWithIdentifier:(id)identifier inContext:(NSManagedObjectContext *)context;

@end
