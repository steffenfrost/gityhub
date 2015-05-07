#import <UIKit/UIKit.h>
#import "Event.h"

@class CollectionViewDataFetcher;

@interface RepoDetailViewController : UIViewController 

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Event                  *eventObject;

@end

