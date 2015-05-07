#import <UIKit/UIKit.h>
#import "Event.h"


@interface RepoDetailViewController : UIViewController 

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Event                  *eventObject;

@end

