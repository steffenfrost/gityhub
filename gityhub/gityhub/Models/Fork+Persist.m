//
//  Fork+Persist.m
//  nearIM, Inc.
//
//  Created by Steven Frost-Ruebling on 4/16/15.
//  Copyright (c) 2015 nearIM All rights reserved.
//

#import "Fork+Persist.h"

@implementation Fork (Persist)

/*
 @property (nonatomic, retain) NSString * identifier;
 @property (nonatomic, retain) NSString * repoName;
 @property (nonatomic, retain) NSString * userIconURL;
 @property (nonatomic, retain) NSString * userName;
 @property (nonatomic, retain) NSDate * timeStamp;
[
 {
     "id": 34074729,
     "name": "elasticsearch-dump",
     "full_name": "alfasin/elasticsearch-dump",
     "owner": {
         "login": "alfasin",
         "id": 1937869,
         "avatar_url": "https://avatars.githubusercontent.com/u/1937869?v=3",
         ...
     },
     ...
     "releases_url": "https://api.github.com/repos/alfasin/elasticsearch-dump/releases{/id}",
     "created_at": "2015-04-16T18:59:24Z",
     "updated_at": "2015-04-16T18:59:24Z",
     "pushed_at": "2015-04-08T12:19:53Z",
     ...
 },
 {
     "id": 33605023
     ....
*/
     
- (void)loadFromDictionary:(NSDictionary *)dictionary
{
    if ([dictionary[@"id"] isKindOfClass:[NSNumber class]]) {
        self.identifier = [dictionary[@"id"] stringValue];
    }
    else {
        self.identifier = dictionary[@"id"];
    }
    
    self.repoName          = dictionary[@"name"];
    self.userName          = dictionary[@"owner"][@"login"];
    self.userIconURL       = dictionary[@"owner"][@"avatar_url"];
    self.timeStamp         = [GTRUtility dateForRFC3339DateTimeString:dictionary[@"created_at"]];
}

// TODO: this is probably inefficient, better to batch up events and then find all the events
// http://www.objc.io/issue-4/importing-large-data-sets-into-core-data.html
+ (Fork *)findOrCreateForkWithIdentifier:(id)identifier
                               inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    fetchRequest.predicate       = [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }
    if (result.lastObject) {
        NSLog(@"Found: %@", result.lastObject);
        return result.lastObject;
    } else {
        Fork *fork = [self insertNewObjectIntoContext:context];
        fork.identifier = identifier;
        return fork;
    }
}

@end
