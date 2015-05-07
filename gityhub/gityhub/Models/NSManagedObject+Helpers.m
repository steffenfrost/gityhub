//
//  NSManagedObject+Helpers.m
//  nearIM, Inc.

//
//  Created by Steven Frost-Ruebling on 4/21/15.
//  Copyright (c) 2015 nearIM All rights reserved.

//

#import "NSManagedObject+Helpers.h"

@implementation NSManagedObject (Helpers)

+ (id)entityName
{
    return NSStringFromClass(self);
}

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext*)context
{                             
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

@end
