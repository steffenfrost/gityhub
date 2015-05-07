//
//  Repo+Persist.m
//  nearIM, Inc.

//
//  Created by Steven Frost-Ruebling on 4/16/15.
//  Copyright (c) 2015 nearIM All rights reserved.

//

#import "Repo+Persist.h"

@implementation Repo (Persist)

/*
 @property (nonatomic, retain) NSString * identifier;
 @property (nonatomic, retain) NSString * codingLanguage;
 @property (nonatomic, retain) NSNumber * numberOfForks;
 @property (nonatomic, retain) NSNumber * numberOfWatchers;
 @property (nonatomic, retain) NSString * repoName;
 @property (nonatomic, retain) NSDate * timeStamp;

{
    "id": 15321010,
    "name": "elasticsearch-dump",
    ...
    "description": "Import and export tools for elasticsearch",
    ...
    "releases_url": "https://api.github.com/repos/taskrabbit/elasticsearch-dump/releases{/id}",
    "created_at": "2013-12-19T19:42:31Z",
    "updated_at": "2015-04-16T18:59:39Z",
    ...
    "watchers_count": 771,
    "language": "JavaScript",
    "has_issues": true,
    ...
    "forks_count": 61,
    ...
    "forks": 61,
    "open_issues": 2,
    "watchers": 771,
    ...
}
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
    self.codingLanguage    = dictionary[@"language"];
    self.numberOfForks     = dictionary[@"forks"];
    self.numberOfWatchers  = dictionary[@"watchers"];
    self.timeStamp         = [GTRUtility dateForRFC3339DateTimeString:dictionary[@"created_at"]];
}

// TODO: this is probably inefficient, better to batch up events and then find all the events
// http://www.objc.io/issue-4/importing-large-data-sets-into-core-data.html
+ (Repo *)findOrCreateRepoWithIdentifier:(id)identifier
                               inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    fetchRequest.predicate       = [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
    NSError *error = nil;
    NSLog(@"About to issue fetchRequest of a repo: %@", fetchRequest);
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }
    if (result.lastObject) {
        NSLog(@"Found: %@", result.lastObject);
        return result.lastObject;
    } else {
        Repo *repo = [self insertNewObjectIntoContext:context];
        repo.identifier = identifier;        
        return repo;
    }
}

@end
