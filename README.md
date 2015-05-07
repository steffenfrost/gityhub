# gityhub
Open source project demonstrating 'CoreData' and 'UICollectionView' making API calls to github

There have are a couple libraries which address the problem of the 'UICollectionView' not having an equivalent "reload" method like 'UITableView'.  This is due to the block based approach used by the 'UICollectionView' in the delegate methods.  NSFetchedResultsController doesn't have compatible delegate methods to handle the blocks as discussed here:

http://jose-ibanez.tumblr.com/post/38494557094/uicollectionviews-and-nsfetchedresultscontrollers

# Credit

This project uses two libraries attempting to solve the problem.  One adapts the code from [Ash Furrow](https://github.com/ashfurrow/UICollectionView-NSFetchedResultsController), the other from [Aleksandar Vacić](https://github.com/radianttap/UICollectionView-NSFetchedResultsController).

We are still getting crashes on the 'performBatchUpdates' delegate method for the 'UICollectionView' if we make a web call prior to the fetch request.

Compilor switches are in place to turn on or off the offending web call.


# Setup
Download the project and run, it will not crash.  The 'RepoDetailViewController' doesn't go out and makes a web call to obtain the details for the repo.  To make the app crash, in the 'RepoDetailViewController' set

'#define TEST_TURN_OFF_WEB_CALL_FOR_REPO_USE_DUMMY 0'


This is the case for both libraries, which you can set which library to use in the 'GTHCommonFile.h' file

For Aleksandar Vacić approach, set
'#define USE_UICollectionView_PLUS_NSFetchedResultsController 1'

For Ash Furrow's library, set
'#define USE_UICollectionView_PLUS_NSFetchedResultsController 0'



