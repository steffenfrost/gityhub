//
//  RepoDetailViewController.h
//  GityHub
//
//  Created by Steven Frost-Ruebling on 5/7/15.
//  Copyright (c) 2015 nearIM, Inc. All rights reserved.

#import <UIKit/UIKit.h>
#import "Event.h"


@interface RepoDetailViewController : UIViewController 

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Event                  *eventObject;

@end

