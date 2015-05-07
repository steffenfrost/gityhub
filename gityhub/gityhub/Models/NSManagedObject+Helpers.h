//
//  NSManagedObject+Helpers.h
//  nearIM, Inc.

//
//  Created by Steven Frost-Ruebling on 4/21/15.
//  Copyright (c) 2015 nearIM All rights reserved.

//

#import <CoreData/CoreData.h>
#import "GTRUtility.h"

@interface NSManagedObject (Helpers)

+ (id)entityName;
+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext*)context;

@end
