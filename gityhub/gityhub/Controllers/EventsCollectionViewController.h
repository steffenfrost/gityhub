#import <UIKit/UIKit.h>

@class CollectionViewDataFetcher;


@interface EventsCollectionViewController : UICollectionViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
