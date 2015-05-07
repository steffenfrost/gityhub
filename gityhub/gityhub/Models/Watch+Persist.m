//
//  Watch+Persist.m
//  nearIM, Inc.

//
//  Created by Steven Frost-Ruebling on 4/16/15.
//  Copyright (c) 2015 nearIM All rights reserved.

//

#import "Watch+Persist.h"

@implementation Watch (Persist)


/*
 @property (nonatomic, retain) NSString * identifier;
 @property (nonatomic, retain) NSString * repoName;
 @property (nonatomic, retain) NSString * userIconURL;
 @property (nonatomic, retain) NSString * userName;
 [
     {
         "login": "slattery",
         "id": 1829326,
         "avatar_url": "https://avatars.githubusercontent.com/u/1829326?v=3",
         "gravatar_id": "",
         "url": "https://api.github.com/users/slattery",
         "html_url": "https://github.com/slattery",
         "followers_url": "https://api.github.com/users/slattery/followers",
         "following_url": "https://api.github.com/users/slattery/following{/other_user}",
         "gists_url": "https://api.github.com/users/slattery/gists{/gist_id}",
         "starred_url": "https://api.github.com/users/slattery/starred{/owner}{/repo}",
         "subscriptions_url": "https://api.github.com/users/slattery/subscriptions",
         "organizations_url": "https://api.github.com/users/slattery/orgs",
         "repos_url": "https://api.github.com/users/slattery/repos",
         "events_url": "https://api.github.com/users/slattery/events{/privacy}",
         "received_events_url": "https://api.github.com/users/slattery/received_events",
         "type": "User",
         "site_admin": false
     },
     {
         "login": "alligator-io",
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
    self.repoName          = @"tbd"; // dictionary[@"tbd"];
    self.userName          = dictionary[@"login"];
    self.userIconURL       = dictionary[@"avatar_url"];
}

// TODO: this is probably inefficient, better to batch up events and then find all the events (???)
// http://www.objc.io/issue-4/importing-large-data-sets-into-core-data.html
+ (Watch *)findOrCreateWatchWithIdentifier:(id)identifier
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
        return result.lastObject;
    } else {
        Watch *watch = [self insertNewObjectIntoContext:context];
        watch.identifier = identifier;
        return watch;
    }
}

@end
