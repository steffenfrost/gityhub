//
//  Event+Persist.m
//  nearIM, Inc.

//
//  Created by Steven Frost-Ruebling on 4/14/15.
//  Copyright (c) 2015 nearIM All rights reserved.

//

#import "Event+Persist.h"

@implementation Event (Persist)


/*
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
 
[
 {
     "id": "2731207539",
     "type": "WatchEvent",
     "actor": {
         "id": 1937869,
         "login": "alfasin",
         "gravatar_id": "",
         "url": "https://api.github.com/users/alfasin",
         "avatar_url": "https://avatars.githubusercontent.com/u/1937869?"
     },
     "repo": {
         "id": 15321010,
         "name": "taskrabbit/elasticsearch-dump",
         "url": "https://api.github.com/repos/taskrabbit/elasticsearch-dump"
     },
     "payload": {
         "action": "started"
     },
     "public": true,
     "created_at": "2015-04-16T18:59:40Z",
     "org": {
         "id": 666590,
         "login": "taskrabbit",
         "gravatar_id": "",
         "url": "https://api.github.com/orgs/taskrabbit",
         "avatar_url": "https://avatars.githubusercontent.com/u/666590?"
     }
 },
 {
     "id": "2731206720",
     ...
*/
- (void)loadFromDictionary:(NSDictionary *)dictionary
{
    if ([dictionary[@"id"] isKindOfClass:[NSNumber class]]) {
        self.identifier = [dictionary[@"id"] stringValue];
    }
    else {
        self.identifier = dictionary[@"id"];
    }
    
    self.userName       = dictionary[@"actor"][@"login"];
    self.userIconURL    = dictionary[@"actor"][@"avatar_url"];
    self.repoIdentifier = dictionary[@"repo"][@"id"];
    self.repoName       = dictionary[@"repo"][@"name"];
    self.repoUrl        = dictionary[@"repo"][@"url"];
    self.forksUrl       = [self.repoUrl stringByAppendingString:@"/forks"];
    self.watchersUrl    = [self.repoUrl stringByAppendingString:@"/watchers"];
    self.actionTaken    = [dictionary[@"type"] substringToIndex:1];
    self.timeStamp      = [GTRUtility dateForRFC3339DateTimeString:dictionary[@"created_at"]];
}

// TODO: this is probably inefficient, better to batch up events and then find all the events
// http://www.objc.io/issue-4/importing-large-data-sets-into-core-data.html
+ (Event *)findOrCreateEventWithIdentifier:(id)identifier
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
//        NSLog(@"Found: %@", result.lastObject);
        return result.lastObject;
    } else {
        Event *event = [self insertNewObjectIntoContext:context];
//        NSLog(@"Inserted Event: %@", event);
        event.identifier = identifier;
        return event;
    }
}

@end
