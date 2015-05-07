//
//  FetchedResultsControllerDataSource.h
//  Git-TaskRabbit
//
//  Created by Steven Frost-Ruebling on 4/14/15.
//  Copyright (c) 2015 TaskRabbit. All rights reserved.
//
//  http://www.objc.io/issue-10/networked-core-data-application.html
//  https://github.com/radianttap/UICollectionView-NSFetchedResultsController

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

#import "UICollectionView+NSFetchedResultsController.h"


@class NSFetchedResultsController;

@protocol CollectionViewDataFetcherDelegateV2

@optional
- (void)configureCell:(id)cell withObject:(id)object;
- (void)selectedItemWithObject:(id)object;
- (void)deleteObject:(id)object;
@end

// TODO: rename this to CollectionViewDataSourceAndDelegate
@interface CollectionViewDataFetcher_usedWith_UICV_plus_NSFRC : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController                     *fetchedResultsController;
@property (nonatomic, weak)   id<CollectionViewDataFetcherDelegateV2>           delegate;
@property (nonatomic, copy)   NSString                                       *reuseIdentifier;
@property (nonatomic)         BOOL                                            paused;

- (id)initWithCollectionView:(UICollectionView*)collectionView;
- (id)objectAtIndexPath:(NSIndexPath*)indexPath;
- (id)selectedItem;


@end
