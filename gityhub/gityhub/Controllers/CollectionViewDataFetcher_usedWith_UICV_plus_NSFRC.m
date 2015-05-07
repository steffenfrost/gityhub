//
//  FetchedResultsControllerDataSource.m
//  Git-TaskRabbit
//
//  Created by Steven Frost-Ruebling on 4/14/15.
//  Copyright (c) 2015 TaskRabbit. All rights reserved.
//

#import "CollectionViewDataFetcher_usedWith_UICV_plus_NSFRC.h"

@interface CollectionViewDataFetcher_usedWith_UICV_plus_NSFRC ()

@property (atomic, weak)   UICollectionView    *collectionView;

@end


@implementation CollectionViewDataFetcher_usedWith_UICV_plus_NSFRC

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

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    // http://aplus.rs/2014/one-not-weird-trick-to-save-your-sanity-with-nsfetchedresultscontroller/
    if (self.collectionView.window == nil) {
        return;
    }

    [self.collectionView addChangeForSection:sectionInfo atIndex:sectionIndex forChangeType:type];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    // http://aplus.rs/2014/one-not-weird-trick-to-save-your-sanity-with-nsfetchedresultscontroller/
    if (self.collectionView.window == nil) {
        return;
    }

    [self.collectionView addChangeForObjectAtIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // http://aplus.rs/2014/one-not-weird-trick-to-save-your-sanity-with-nsfetchedresultscontroller/
    if (self.collectionView.window == nil) {
        return;
    }
    
    [self.collectionView commitChanges];

}


@end
