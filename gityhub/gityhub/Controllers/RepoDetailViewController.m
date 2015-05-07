#import "RepoDetailViewController.h"

#import "CollectionViewDataFetcher.h"
#import "CollectionViewDataFetcher_usedWith_UICV_plus_NSFRC.h"

#import "Importer.h"
#import "GitWebServices.h"

#import "Repo.h"
#import "Repo+Persist.h"
#import "RepoObject.h"
#import "Fork.h"
#import "Fork+Persist.h"
#import "Watch.h"
#import "Watch+Persist.h"

#import "UserCollectionViewCell.h"

#define kGityHubImageQue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

// If you use Aleksandar Vacić's library
// https://github.com/radianttap/UICollectionView-NSFetchedResultsController
#define USE_UICollectionView_PLUS_NSFetchedResultsController 1

#define CoreDataWay 0
#define TEST_WITH_EVENTS_FROM_ANOTHER_REPO 0
#define TEST_TURN_OFF_WEB_CALL_FOR_REPO_USE_DUMMY 0

#if USE_UICollectionView_PLUS_NSFetchedResultsController
@interface RepoDetailViewController () <CollectionViewDataFetcherDelegateV2>
#else
@interface RepoDetailViewController () <CollectionViewDataFetcherDelegate>
#endif

@property (nonatomic, weak) IBOutlet UILabel *repoNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *codingLanguageLabel;
@property (nonatomic, weak) IBOutlet UILabel *createdAtLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberOfActionsLabel;
@property (atomic   , weak) IBOutlet UICollectionView *collectionView;

#if USE_UICollectionView_PLUS_NSFetchedResultsController
@property (atomic,    strong) CollectionViewDataFetcher_usedWith_UICV_plus_NSFRC *collectionViewDataManager;
#else
@property (atomic   , strong) CollectionViewDataFetcher *collectionViewDataManager;
#endif

@property (nonatomic, strong) GitWebServices            *webservice;
@property (nonatomic, strong) Importer                  *importer;

@property (nonatomic, strong) NSString                  *entityName;
@end



@implementation RepoDetailViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UINib *nib = [UINib nibWithNibName:@"UserCollectionViewCell" bundle:nil];
//    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"UserCollectionViewCell"];

#if CoreDataWay
    // Prime Notification for the Repo
    [[NSNotificationCenter defaultCenter]
        addObserverForName:NSManagedObjectContextObjectsDidChangeNotification
                    object:nil
                    queue:nil
            usingBlock:^(NSNotification* notification) {
             
             NSManagedObjectContext *moc = self.managedObjectContext;
             if (notification.object != moc) {
                 [moc performBlock:^(){
                     for (NSManagedObject* object in notification.userInfo[NSDeletedObjectsKey]) {
                         if ([object.entity.name isEqualToString: @"Repo"]) {
                             [self fetchRepo];
                         }
                     }
                     
                     // Iterate over all of the new objects
                     for (NSManagedObject* object in notification.userInfo[NSInsertedObjectsKey]) {
                         if ([object.entity.name isEqualToString: @"Repo"]) {
                             [self fetchRepo];
                         }
                     }
                     
                     // Iterate over all of the modified objects
                     for (NSManagedObject* object in notification.userInfo[NSUpdatedObjectsKey]) {
                         if ([object.entity.name isEqualToString: @"Repo"]) {
                             [self fetchRepo];
                         }
                     }
                 }];
             }
            }
     ];
    
    // Get our repo and store it into CoreData, should trigger above
    [self.importer importUrl:self.eventObject.repoUrl forClass:TRGitImportClassTypeRepo];

#else
    // NOTE: it might be best to just do an asynch url call to the the repo, and not store it
    // in CoreData.  If we grab the same repo, and we already have it, we won't get the notification

#if TEST_TURN_OFF_WEB_CALL_FOR_REPO_USE_DUMMY
    RepoObject *repoObject = [[RepoObject alloc] init];  // for debuging, want to skirt CoreData right now

    NSDictionary *bogusTestRepo = @{@"name"      : @"Bogus Repo",
                                    @"language"  : @"German",
                                    @"forks"     : [NSNumber numberWithInt:24],
                                    @"watchers"  : [NSNumber numberWithInt:12],
                                    @"created_at": @"2015-04-22 03:44:41 +0000" };
    [repoObject loadFromDictionary:bogusTestRepo];
    [self loadDetailsWithRepo:repoObject];
    NSLog(@"Using bogus repo.");
    
#else
    NSLog(@"Initiating Webservice for...%@: ", self.eventObject.repoUrl);
    NSLog(@"WHY WOULD THIS CAUSE THE COLLECTIONVIEW'S DATAMANAGER TO CRASH LATER????");
    [self.webservice fetchAllObjects:^(NSArray *objects) {
        NSLog(@"Our callback from said webservice");
        if ([objects.lastObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *repoDictionary = objects.lastObject;
//            NSNumber *identifier = repoDictionary[@"id"];
//            Repo *repo = [Repo findOrCreateRepoWithIdentifier:identifier inContext:self.managedObjectContext];
            RepoObject *repo = [[RepoObject alloc] init];  // for debuging, want to skirt CoreData right now
            [repo loadFromDictionary:repoDictionary];
            NSLog(@"Off you go, load up the details.");
            [self loadDetailsWithRepo:repo];
        }
    } withUrl:self.eventObject.repoUrl];
#endif
    
#endif

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

#if CoreDataWay
- (void)fetchRepo {
    NSFetchRequest *request4Repo = [NSFetchRequest fetchRequestWithEntityName:@"Repo"];
    request4Repo.predicate       = [NSPredicate predicateWithFormat:@"identifier = %@", self.eventObject.repoIdentifier];
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request4Repo error:&error];
    NSLog(@"The result in RDVC: %@", result);
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }
    Repo *aRepo = nil;
    if (result.lastObject) {
        NSLog(@"Found: %@", result.lastObject);
        aRepo = result.lastObject;
        [self loadDetailsWithRepo:aRepo];
    }
    
    else {
        NSLog(@"Crap, what do we do now? KVO?");
    }
}
#endif

- (void)loadDetailsWithRepo:(RepoObject*)repo {
    NSLog(@"Repo Loading: %@", repo);
    self.repoNameLabel.text        = repo.repoName;
    self.codingLanguageLabel.text  = repo.codingLanguage;
    NSString *actions = nil;
    if ([self.eventObject.actionTaken isEqualToString:@"W"]) {
        self.entityName = @"Watch";
        actions = [repo.numberOfWatchers stringValue];
    }
    else {
        self.entityName = @"Fork";
        actions = [repo.numberOfForks stringValue];
    }
    
    self.numberOfActionsLabel.text = [@"#: " stringByAppendingString:actions];
    
    self.createdAtLabel.text = [NSDateFormatter localizedStringFromDate:repo.timeStamp
                                                              dateStyle:NSDateFormatterMediumStyle
                                                              timeStyle:NSDateFormatterNoStyle];
    
    UINib *nib = [UINib nibWithNibName:@"UserCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"UserCollectionViewCell"];
    
    self.collectionViewDataManager = [[CollectionViewDataFetcher alloc] initWithCollectionView:self.collectionView];
    self.collectionViewDataManager.reuseIdentifier = @"UserCollectionViewCell";
  
    // This VC is responsible for configuring cell
    self.collectionViewDataManager.delegate = self;

#if TEST_WITH_EVENTS_FROM_ANOTHER_REPO
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
#else
    NSLog(@"creating request with entityName: %@", self.entityName);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
    NSLog(@"The request: %@", request);
#endif
    
//  request.predicate       = [NSPredicate predicateWithFormat:@"repoName = %@", repo.repoName];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"userName"  ascending:YES]];
//                              [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending: NO]];
    
    self.collectionViewDataManager.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                   managedObjectContext:self.managedObjectContext
                                                                                     sectionNameKeyPath:nil cacheName:nil];
    
    NSLog(@"self.collectionViewDataManager.frc: %@", self.collectionViewDataManager.fetchedResultsController);

#if TEST_WITH_EVENTS_FROM_ANOTHER_REPO
    // **** TEST **** : lets try events
    NSString *eventsUrl = @"https://api.github.com/orgs/firebase/events";
    [self.importer importUrl:eventsUrl forClass:TRGitImportClassTypeEvent];
    return;
#endif
    // Now that the dataSource is waiting and listening for changes in CoreData, we start loading the data
    if ([self.entityName isEqualToString:@"Watch"]) {
        NSLog(@"Start loading Watch objects into CoreData");
        [self.importer importUrl:self.eventObject.watchersUrl forClass:TRGitImportClassTypeWatch];
    }
    else {
        NSLog(@"Start loading %@", self.eventObject.forksUrl);
        [self.importer importUrl:self.eventObject.forksUrl forClass:TRGitImportClassTypeFork];
    }
}


#pragma mark - FetchedResultsControllerDataSourceDelegate

#if TEST_WITH_EVENTS_FROM_ANOTHER_REPO
// In the UserCollectionViewCell display the user name, avatar, and date of action.
- (void)configureCell:(UserCollectionViewCell *)cell withObject:(Event *)object
{
    NSLog(@"Configuring our Cell with object: %@", object);
    cell.userNameLabel.text    = object.userName;
    
    cell.userAvatarImageView.image = [UIImage imageNamed:@"identicon"];
    
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

#else

- (void)configureCell:(UserCollectionViewCell *)cell withObject:(NSManagedObject *)object
{
    cell.userAvatarImageView.image = [UIImage imageNamed:@"identicon"];
    NSLog(@"object for cell: %@", object);
    NSLog(@"object class: %@", [object entity].name);
    //    NSLog(@"entityName of object: %@", [object entityName]);

    if ([[object entity].name isEqualToString:@"Fork"]) {
        cell.userNameLabel.text = [(Fork*)object userName];
        cell.actionTakenAndDateLabel.text = [NSDateFormatter localizedStringFromDate:[(Fork*)object timeStamp]
                                                                           dateStyle:NSDateFormatterMediumStyle
                                                                           timeStyle:NSDateFormatterNoStyle];
        
        // Other ways 2 investigate: http://cocoanuts.mobi/2014/04/27/fastscroll/
        dispatch_async(kGityHubImageQue, ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[(Fork*)object userIconURL]]];
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
    else if ([[object entity].name isEqualToString:@"Watch"]) {
        cell.userNameLabel.text = [(Watch*)object userName];
//        cell.actionTakenAndDateLabel.text = [NSDateFormatter localizedStringFromDate:[(Watch*)object timeStamp]
//                                                                           dateStyle:NSDateFormatterMediumStyle
//                                                                           timeStyle:NSDateFormatterNoStyle];
        
        // Other ways 2 investigate: http://cocoanuts.mobi/2014/04/27/fastscroll/
        dispatch_async(kGityHubImageQue, ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[(Watch*)object userIconURL]]];
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
    else {
        return;
    }
}
#endif

- (void)selectedItemWithObject:(id)object {
    return;
}



@end


