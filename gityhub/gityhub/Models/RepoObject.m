//
//  RepoObject.m
//  nearIM, Inc.
//
//  Created by Steven Frost-Ruebling on 4/20/15.
//  Copyright (c) 2015 nearIM All rights reserved.
//

#import "RepoObject.h"

@implementation RepoObject


//https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html
- (NSDate *)dateForRFC3339DateTimeString:(NSString *)rfc3339DateTimeString {
    /*
     Returns a date that corresponds to the specified
     RFC 3339 date time string. Note that this does not handle all possible
     RFC 3339 date time strings, just one of the most common styles.
     */
    
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    // Convert the RFC 3339 date time string to an NSDate.
    NSDate *date = [rfc3339DateFormatter dateFromString:rfc3339DateTimeString];
    return date;
}

/*
 @property (nonatomic, retain) NSNumber * identifier;
 @property (nonatomic, retain) NSString * repoName;
 @property (nonatomic, retain) NSString * codingLanguage;
 @property (nonatomic, retain) NSNumber * numberOfForks;
 @property (nonatomic, retain) NSNumber * numberOfWatchers;
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
    self.identifier        = dictionary[@"id"];
    self.repoName          = dictionary[@"name"];
    self.codingLanguage    = dictionary[@"language"];
    self.numberOfForks     = dictionary[@"forks"];
    self.numberOfWatchers  = dictionary[@"watchers"];
    self.timeStamp         = [self dateForRFC3339DateTimeString:dictionary[@"created_at"]];
}




@end
