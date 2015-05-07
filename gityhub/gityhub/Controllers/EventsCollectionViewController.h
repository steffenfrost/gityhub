//
//  EventsCollectionViewController.h
//  GityHub
//
//  Created by Steven Frost-Ruebling on 5/7/15.
//  Copyright (c) 2015 nearIM, Inc. All rights reserved.

#import <UIKit/UIKit.h>


@interface EventsCollectionViewController : UICollectionViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
