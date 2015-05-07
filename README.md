# gityhub
Open source project demonstrating CoreData and UICollectionView making API calls to github

There have are a couple libraries which try to solve the problem that UICollectionViewController does not have an equivalent "reload" method like TableView.  This is due to using block based methods.  The problem arrises since NSFetchedResultsController doesn't have compatible delegate methods to handle it as discussed here:

http://jose-ibanez.tumblr.com/post/38494557094/uicollectionviews-and-nsfetchedresultscontrollers


