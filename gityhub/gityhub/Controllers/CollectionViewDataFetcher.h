//
//  FetchedResultsControllerDataSource.h
//  nearIM, Inc.
//
//  Created by Steven Frost-Ruebling on 4/14/15.
//  Copyright (c) 2015 nearIM All rights reserved.

//
//  http://www.objc.io/issue-10/networked-core-data-application.html
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>



@class NSFetchedResultsController;

@protocol CollectionViewDataFetcherDelegate

@optional
- (void)configureCell:(id)cell withObject:(id)object;
- (void)selectedItemWithObject:(id)object;
- (void)deleteObject:(id)object;
@end

// TODO: rename this to CollectionViewDataSourceAndDelegate
@interface CollectionViewDataFetcher : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController                     *fetchedResultsController;
@property (nonatomic, weak)   id<CollectionViewDataFetcherDelegate>           delegate;
@property (nonatomic, copy)   NSString                                       *reuseIdentifier;
@property (nonatomic)         BOOL                                            paused;

- (id)initWithCollectionView:(UICollectionView*)collectionView;
- (id)objectAtIndexPath:(NSIndexPath*)indexPath;
- (id)selectedItem;


@end
