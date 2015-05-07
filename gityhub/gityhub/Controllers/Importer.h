//
//  Importer.h
//  nearIM, Inc.

//
//  Created by Steven Frost-Ruebling on 4/16/15.
//  Copyright (c) 2015 nearIM All rights reserved.

//
//  http://www.objc.io/issue-10/networked-core-data-application.html
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GitWebServices;

typedef NS_ENUM(NSUInteger, TRGitImportClassType) {
    TRGitImportClassTypeEvent = 1,
    TRGitImportClassTypeRepo  = 2,
    TRGitImportClassTypeFork  = 3,
    TRGitImportClassTypeWatch = 4
};


@interface Importer : NSObject

- (id)initWithContext:(NSManagedObjectContext *)context
           webservice:(GitWebServices *)webservice;

- (void)importUrl:(NSString *)url forClass:(TRGitImportClassType)classType;

@end
