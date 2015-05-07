//
//  GitWebServices.m
//  nearIM, Inc.
//
//  Created by Steven Frost-Ruebling on 4/16/15.
//  Copyright (c) 2015 nearIM All rights reserved.

//

#import "GitWebServices.h"

@implementation GitWebServices


- (void)fetchAllObjects:(void (^)(NSArray *objects))callback withUrl:(NSString *)urlString
{
    [self fetchAllObjects:callback withUrlString:urlString page:0];
}

- (void)fetchAllObjects:(void (^)(NSArray *objects))callback withUrlString:urlString page:(NSUInteger)page
{
    NSString *concatenatedUrl = [urlString stringByAppendingString:[NSString stringWithFormat:@"?page=%lu", (unsigned long)page]];
    NSLog(@"Concatenated URL: %@", concatenatedUrl);
    NSURL *url = [NSURL URLWithString:concatenatedUrl];
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
          if (error) {
              NSLog(@"error: %@", error.localizedDescription);
              callback(nil);
              return;
          }

//        https://developer.github.com/guides/traversing-with-pagination/
//        NSDictionary *dictionary = [(NSHTTPURLResponse*)response allHeaderFields];
          
          NSError *jsonError = nil;
          id objects = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
          
          if ([objects isKindOfClass:[NSArray class]]) {
              
              // Send back the objects to Importer
              callback(objects);
              
              // Set this to 1, or else I get dinged on my quota
              NSNumber* numberOfPages = [NSNumber numberWithInt:1]; // ok, cheating here, not parsing the link header
              NSUInteger nextPage = page + 1;
              if (nextPage < numberOfPages.unsignedIntegerValue) {
                  [self fetchAllObjects:callback withUrlString:urlString page:nextPage];
              }
          }
          else {
              NSArray *arrayWithOneDictionaryObject = [NSArray arrayWithObject:objects];
              callback(arrayWithOneDictionaryObject);
          }
      }] resume];
}


@end
