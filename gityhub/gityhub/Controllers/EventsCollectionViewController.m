#import "EventsCollectionViewController.h"

#import "CollectionViewDataFetcher.h"
#import "Event.h"
#import "EventCollectionViewCell.h"

#import "RepoDetailViewController.h"
#import "GitWebServices.h"
#import "Importer.h"

#import "RepoObject.h"

#define kGityHubImageQue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#if USE_UICollectionView_PLUS_NSFetchedResultsController
@interface EventsCollectionViewController () <CollectionViewDataFetcherDelegateV2>
@property (nonatomic, strong) CollectionViewDataFetcher_usedWith_UICV_plus_NSFRC *collectionViewDataManager;
#else
@interface EventsCollectionViewController () <CollectionViewDataFetcherDelegate>
@property (nonatomic, strong) CollectionViewDataFetcher *collectionViewDataManager;
#endif

@property (nonatomic, strong) GitWebServices  *webservice;
@property (nonatomic, strong) Importer        *importer;

@end


@implementation EventsCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#define TEST_IF_CALL_TO_WEB_TRIPS_UP_COLLECTIONVIEWDATAFETCHER 0
    
#if TEST_IF_CALL_TO_WEB_TRIPS_UP_COLLECTIONVIEWDATAFETCHER
    NSLog(@"WHY WOULD THIS CAUSE THE COLLECTIONVIEW'S DATAMANAGER TO CRASH LATER????");
    [self.webservice fetchAllObjects:^(NSArray *objects) {
        NSLog(@"Our callback from said webservice");
        if ([objects.lastObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *repoDictionary = objects.lastObject;
            //            NSNumber *identifier = repoDictionary[@"id"];
            //            Repo *repo = [Repo findOrCreateRepoWithIdentifier:identifier inContext:self.managedObjectContext];
            RepoObject *repo = [[RepoObject alloc] init];  // for debuging, want to skirt CoreData right now
            [repo loadFromDictionary:repoDictionary];
            NSLog(@"TEST: finished loading repop via web service.");
            
            UINib *nib = [UINib nibWithNibName:@"EventCollectionViewCell" bundle:nil];
            [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"EventCollectionViewCell"];
            
            self.collectionViewDataManager = [[CollectionViewDataFetcher alloc] initWithCollectionView:self.collectionView];
            self.collectionViewDataManager.reuseIdentifier = @"EventCollectionViewCell";
            
            // This VC is responsible for configuring the cell and handling user selecting cell
            self.collectionViewDataManager.delegate = self;
            
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
            NSLog(@"The request: %@", request);
            request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending: NO],
                                        [NSSortDescriptor sortDescriptorWithKey:@"repoName"  ascending:YES]];
            
            self.collectionViewDataManager.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                                          managedObjectContext:self.managedObjectContext
                                                                                                            sectionNameKeyPath:nil cacheName:nil];
            
            NSLog(@"self.collectionViewDataManager.frc: %@", self.collectionViewDataManager.fetchedResultsController);
            
            NSString *eventsUrl = @"https://api.github.com/orgs/taskrabbit/events";
            [self.importer importUrl:eventsUrl forClass:TRGitImportClassTypeEvent];
        }
    } withUrl:@"https://api.github.com/repos/taskrabbit/elasticsearch-dump"];
    
#else

    UINib *nib = [UINib nibWithNibName:@"EventCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"EventCollectionViewCell"];
    
    self.collectionViewDataManager = [[CollectionViewDataFetcher alloc] initWithCollectionView:self.collectionView];
    self.collectionViewDataManager.reuseIdentifier = @"EventCollectionViewCell";

    // This VC is responsible for configuring the cell and handling user selecting cell
    self.collectionViewDataManager.delegate = self;
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    NSLog(@"The request: %@", request);
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending: NO],
                                [NSSortDescriptor sortDescriptorWithKey:@"repoName"  ascending:YES]];
    
    self.collectionViewDataManager.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                                  managedObjectContext:self.managedObjectContext
                                                                                                    sectionNameKeyPath:nil cacheName:nil];
    
    NSLog(@"self.collectionViewDataManager.frc: %@", self.collectionViewDataManager.fetchedResultsController);

    NSString *eventsUrl = @"https://api.github.com/orgs/taskrabbit/events";
    [self.importer importUrl:eventsUrl forClass:TRGitImportClassTypeEvent];
#endif
}

// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"viewWillAppear");
}

// Called when the view has been fully transitioned onto the screen. Default does nothing
- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"viewDidAppear");
    
    self.collectionViewDataManager.paused = NO;
}

// Called when the view is dismissed, covered or otherwise hidden. Default does nothing
- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"viewWillDisappear");
}

// Called after the view was dismissed, covered or otherwise hidden. Default does nothing
- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"viewDidDisappear");
}

- (NSString *)title {
    return @"Stream";
}

- (Importer *)importer {
    if (!_importer) {
        _importer = [[Importer alloc] initWithContext:self.managedObjectContext webservice:self.webservice];
    }
    return _importer;
}

- (GitWebServices *)webservice {
    if (!_webservice) {
        _webservice = [[GitWebServices alloc] init];
    }
    return _webservice;
}



#pragma mark - FetchedResultsControllerDataSourceDelegate

- (void)configureCell:(EventCollectionViewCell *)cell withObject:(Event *)object
{
    cell.repoNameLabel.text    = object.repoName;
    cell.actionTakenLabel.text = object.actionTaken;
    cell.userNameLabel.text    = object.userName;
    cell.dateLabel.text        = [NSDateFormatter localizedStringFromDate:object.timeStamp
                                                          dateStyle:NSDateFormatterMediumStyle
                                                          timeStyle:NSDateFormatterNoStyle];
    
    cell.userAvatarImageView.image = [UIImage imageNamed:@"identicon"];
    
    // http://www.raywenderlich.com/51127/nsurlsession-tutorial
    // Other ways 2 investigate: http://cocoanuts.mobi/2014/04/27/fastscroll/
    dispatch_async(kGityHubImageQue, ^{
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:object.userIconURL]];
        if (imgData) {
            UIImage *image = [UIImage imageWithData:imgData];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.userAvatarImageView.image = image;
                });
            }
        }
    });
}


/*
 On tap of an EventCollectionViewCell, display a RepoDetailViewController with the name of the repo, date of the repo creation, coding language, total stars or forks with icon, and UserCollectionViewCells for users that did the action. In the UserCollectionViewCell display the user name, avatar, and date of action.
*/
- (void)selectedItemWithObject:(Event *)object {
    self.collectionViewDataManager.paused = YES;
    
    NSLog(@" ");NSLog(@" ");NSLog(@" ");NSLog(@" ");NSLog(@" ");NSLog(@" ");
    NSLog(@"---------------------------------------------------------------------------");
    NSLog(@"The selected event: %@", object);

    RepoDetailViewController *detailViewController = [[RepoDetailViewController alloc] initWithNibName:@"RepoDetailViewController" bundle:nil];
    
    detailViewController.managedObjectContext = self.managedObjectContext;
    detailViewController.eventObject          = object;
    
    NSLog(@"Pushing detail view controller...");
    [self.navigationController pushViewController:detailViewController animated:YES];
}


@end
