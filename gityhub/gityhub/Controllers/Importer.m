//
//  Importer.m
//  nearIM, Inc.

//
//  Created by Steven Frost-Ruebling on 4/16/15.
//  Copyright (c) 2015 nearIM All rights reserved.

//

#import "Importer.h"

#import "GitWebServices.h"
#import "Event.h"
#import "Event+Persist.h"
#import "Repo.h"
#import "Repo+Persist.h"
#import "Fork.h"
#import "Fork+Persist.h"
#import "Watch.h"
#import "Watch+Persist.h"


@interface Importer ()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) GitWebServices         *webservice;
@property (nonatomic, strong) NSString               *url;
@property (nonatomic)         int                     batchCount;

@end

@implementation Importer

- (id)initWithContext:(NSManagedObjectContext *)context webservice:(GitWebServices *)webservice
{
    self = [super init];
    if (self) {
        self.context    = context;
        self.webservice = webservice;
    }
    return self;
}

- (void)importUrl:(NSString *)url forClass:(TRGitImportClassType)classType {
    self.batchCount = 0;
        
    [self.webservice fetchAllObjects:^(NSArray *objects)
    
     // Callback WebService...you might get several of these
    {
        // http://stackoverflow.com/questions/27632458/assertion-failure-in-uicollectionview-enditemanimations-crash
        // The wait didn't help tho
        [self.context performBlockAndWait:^
         {
             for(NSDictionary *anObject in objects) {
                 
                 NSString *identifier = nil;
                 if ([anObject[@"id"] isKindOfClass:[NSNumber class]]) {
                     identifier = [anObject[@"id"] stringValue];
                 }
                 else {
                     identifier = anObject[@"id"];
                 }

                 // Now the "importing" the Importer does, importing into CoreData
                 switch(classType) {
                     case TRGitImportClassTypeEvent:
                     {
                         Event *event = [Event findOrCreateEventWithIdentifier:identifier inContext:self.context];
                         [event loadFromDictionary:anObject];
                         break;
                     }
                     case TRGitImportClassTypeRepo:
                     {
                         Repo *repo = [Repo findOrCreateRepoWithIdentifier:identifier inContext:self.context];
                         NSLog(@"Found or Created repo: %@", repo);

                         [repo loadFromDictionary:anObject];
                         break;
                     }
                     case TRGitImportClassTypeFork:
                     {
                         Fork *fork = [Fork findOrCreateForkWithIdentifier:identifier inContext:self.context];
                         [fork loadFromDictionary:anObject];
                         break;
                     }
                     case TRGitImportClassTypeWatch:
                     {
                         Watch *watch = [Watch findOrCreateWatchWithIdentifier:identifier inContext:self.context];
                         [watch loadFromDictionary:anObject];
                         break;
                     }
                     default:
                         break;
                 }
                 
             }
             
             self.batchCount++;
             NSLog(@"Batch count: %d", self.batchCount);
             NSLog(@"Batch count mod 10 = %d", self.batchCount % 1);
             if (self.batchCount % 1 == 0) {
                 NSLog(@"******************** Saving context of type (1=event, 2=repo, 3=fork, 4=wath): %lu", (unsigned long)classType);
                 
                 //Important: Always verify that the context has uncommitted changes (using the hasChanges property) before invoking the save: method. Otherwise, Core Data may perform unnecessary work.
                 if ([self.context hasChanges]) {
                     NSError *error = nil;
                     [self.context save:&error];
                     if (error) {
                         NSLog(@"Error: %@", error.localizedDescription);
                     }
                 }
             }
         }];
    } withUrl:url];
}

@end
