//
//  FetchedResultsControllerDataSource.m
//  nearIM, Inc.

//
//  Created by Steven Frost-Ruebling on 4/14/15.
//  Copyright (c) 2015 nearIM All rights reserved.

//

#import "CollectionViewDataFetcher.h"

@interface CollectionViewDataFetcher ()

@property (atomic, weak)   UICollectionView    *collectionView;

@property (atomic, strong) NSMutableDictionary *objectChanges;
@property (atomic, strong) NSMutableDictionary *sectionChanges;


@end


@implementation CollectionViewDataFetcher

- (id)initWithCollectionView:(UICollectionView*)collectionView
{
    self = [super init];
    if (self) {
        self.collectionView = collectionView;
        self.collectionView.dataSource = self;
        self.collectionView.delegate   = self;
    }
    return self;
}

- (void)setFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController
{
    NSLog(@"About to set FRC, currently self.fetchedResultsController: %@", self.fetchedResultsController);
    NSAssert(_fetchedResultsController == nil, @"TODO: you can currently only assign this property once");
    fetchedResultsController.delegate = self;
    [fetchedResultsController performFetch:NULL];
    _fetchedResultsController = fetchedResultsController;
    NSLog(@"FRC: %@", _fetchedResultsController);
}

// Usefull for Storyboard in the prepareForSegue call
- (id)selectedItem
{
    NSIndexPath* path = [self.collectionView.indexPathsForSelectedItems objectAtIndex:0];
    NSLog(@"The seleted item path: %@", path);
    return path ? [self.fetchedResultsController objectAtIndexPath:path] : nil;
}


- (void)setPaused:(BOOL)paused
{
    _paused = paused;
    if (paused) {
        self.fetchedResultsController.delegate = nil;
    } else {
        self.fetchedResultsController.delegate = self;
        [self.fetchedResultsController performFetch:NULL];
        [self.collectionView reloadData];
    }
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath
{
    id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return object;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self objectAtIndexPath:indexPath];
    [self.delegate selectedItemWithObject:object];  // Pass object to VC. 
}



#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSLog(@"# of sections: %lu", (unsigned long)self.fetchedResultsController.sections.count);
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionIndex = self.fetchedResultsController.sections[section];
    NSLog(@"Section index: %@", sectionIndex);
    NSLog(@"#of objects:   %lu", (unsigned long)sectionIndex.numberOfObjects);
    return sectionIndex.numberOfObjects;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"collectionView asking for #cell4itematindexpath");
    id object = [self objectAtIndexPath:indexPath];
    id cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.reuseIdentifier
                                                        forIndexPath:indexPath];
    [self.delegate configureCell:cell withObject:object];
    return cell;
}


#pragma mark NSFetchedResultsControllerDelegate

// http://jose-ibanez.tumblr.com/post/38494557094/uicollectionviews-and-nsfetchedresultscontrollers
// https://github.com/ashfurrow/UICollectionView-NSFetchedResultsController/blob/master/AFMasterViewController.m
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"controllerWillChangeContent: %@", controller);
    self.objectChanges  = [NSMutableDictionary dictionary];
    self.sectionChanges = [NSMutableDictionary dictionary];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    // http://aplus.rs/2014/one-not-weird-trick-to-save-your-sanity-with-nsfetchedresultscontroller/
    if (self.collectionView.window == nil) {
        return;
    }
    
    NSLog(@"controller didChangeSection: %@", controller);
    NSLog(@"sectionInfo:                 %@", sectionInfo);
    NSLog(@"atIndex:                    %lu", (unsigned long)sectionIndex);
    NSLog(@"forChangeType:              %lu", (unsigned long)type);
    if (type == NSFetchedResultsChangeInsert || type == NSFetchedResultsChangeDelete) {
        NSMutableIndexSet *changeSet = self.sectionChanges[@(type)];
        if (changeSet != nil) {
            [changeSet addIndex:sectionIndex];
        } else {
            self.sectionChanges[@(type)] = [[NSMutableIndexSet alloc] initWithIndex:sectionIndex];
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    // http://aplus.rs/2014/one-not-weird-trick-to-save-your-sanity-with-nsfetchedresultscontroller/
    if (self.collectionView.window == nil) {
        return;
    }
    
    NSMutableArray *changeSet = self.objectChanges[@(type)];
    if (changeSet == nil) {
        changeSet = [[NSMutableArray alloc] init];
        self.objectChanges[@(type)] = changeSet;
    }
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [changeSet addObject:newIndexPath];
            break;
        case NSFetchedResultsChangeDelete:
            [changeSet addObject:indexPath];
            break;
        case NSFetchedResultsChangeUpdate:
            [changeSet addObject:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [changeSet addObject:@[indexPath, newIndexPath]];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // http://aplus.rs/2014/one-not-weird-trick-to-save-your-sanity-with-nsfetchedresultscontroller/
    if (self.collectionView.window == nil) {
        return;
    }
    
    NSLog(@"controllerDidChangeContent..");
    NSMutableArray *moves = self.objectChanges[@(NSFetchedResultsChangeMove)];
    if (moves.count > 0) {
        NSMutableArray *updatedMoves = [[NSMutableArray alloc] initWithCapacity:moves.count];
        
        NSMutableIndexSet *insertSections = self.sectionChanges[@(NSFetchedResultsChangeInsert)];
        NSMutableIndexSet *deleteSections = self.sectionChanges[@(NSFetchedResultsChangeDelete)];
        
        for (NSArray *move in moves) {
            NSIndexPath *fromIP = move[0];
            NSIndexPath *toIP   = move[1];
            
            if ([deleteSections containsIndex:fromIP.section]) {
                if (![insertSections containsIndex:toIP.section]) {
                    NSMutableArray *changeSet = self.objectChanges[@(NSFetchedResultsChangeInsert)];
                    if (changeSet == nil) {
                        changeSet = [[NSMutableArray alloc] initWithObjects:toIP, nil];
                        self.objectChanges[@(NSFetchedResultsChangeInsert)] = changeSet;
                    } else {
                        [changeSet addObject:toIP];
                    }
                }
            } else if ([insertSections containsIndex:toIP.section]) {
                NSMutableArray *changeSet = self.objectChanges[@(NSFetchedResultsChangeDelete)];
                if (changeSet == nil) {
                    changeSet = [[NSMutableArray alloc] initWithObjects:fromIP, nil];
                    self.objectChanges[@(NSFetchedResultsChangeDelete)] = changeSet;
                } else {
                    [changeSet addObject:fromIP];
                }
            } else {
                [updatedMoves addObject:move];
            }
        }
        
        if (updatedMoves.count > 0) {
            self.objectChanges[@(NSFetchedResultsChangeMove)] = updatedMoves;
        } else {
            [self.objectChanges removeObjectForKey:@(NSFetchedResultsChangeMove)];
        }
    }
    
    NSMutableArray *deletes = self.objectChanges[@(NSFetchedResultsChangeDelete)];
    if (deletes.count > 0) {
        NSMutableIndexSet *deletedSections = self.sectionChanges[@(NSFetchedResultsChangeDelete)];
        [deletes filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath *evaluatedObject, NSDictionary *bindings) {
            return ![deletedSections containsIndex:evaluatedObject.section];
        }]];
    }
    
    NSMutableArray *inserts = self.objectChanges[@(NSFetchedResultsChangeInsert)];
    if (inserts.count > 0) {
        NSMutableIndexSet *insertedSections = self.sectionChanges[@(NSFetchedResultsChangeInsert)];
        [inserts filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath *evaluatedObject, NSDictionary *bindings) {
            return ![insertedSections containsIndex:evaluatedObject.section];
        }]];
    }
    
    __unsafe_unretained typeof(self) weakSelf = self;
    [self.collectionView performBatchUpdates:^{
        NSLog(@"Performing Batch Updates.");
        NSLog(@"Section Changes: %@", weakSelf.sectionChanges);
        NSLog(@"Object  Changes: %@", weakSelf.objectChanges);
        NSIndexSet *deletedSections = weakSelf.sectionChanges[@(NSFetchedResultsChangeDelete)];
        if (deletedSections.count > 0) {
            [weakSelf.collectionView deleteSections:deletedSections];
        }
        
        NSIndexSet *insertedSections = weakSelf.sectionChanges[@(NSFetchedResultsChangeInsert)];
        if (insertedSections.count > 0) {
            [weakSelf.collectionView insertSections:insertedSections];
        }
        
        NSArray *deletedItems = weakSelf.objectChanges[@(NSFetchedResultsChangeDelete)];
        if (deletedItems.count > 0) {
            [weakSelf.collectionView deleteItemsAtIndexPaths:deletedItems];
        }
        
        NSArray *insertedItems = weakSelf.objectChanges[@(NSFetchedResultsChangeInsert)];
        if (insertedItems.count > 0) {
            [weakSelf.collectionView insertItemsAtIndexPaths:insertedItems];
        }
        
        NSArray *reloadItems = weakSelf.objectChanges[@(NSFetchedResultsChangeUpdate)];
        if (reloadItems.count > 0) {
            [weakSelf.collectionView reloadItemsAtIndexPaths:reloadItems];
        }
        
        NSArray *moveItems = weakSelf.objectChanges[@(NSFetchedResultsChangeMove)];
        for (NSArray *paths in moveItems) {
            [weakSelf.collectionView moveItemAtIndexPath:paths[0] toIndexPath:paths[1]];
        }
    } completion:nil];
    
//    _objectChanges = nil;
//    _sectionChanges = nil;
}


@end
