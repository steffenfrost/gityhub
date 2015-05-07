#import <UIKit/UIKit.h>

@interface UserCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *actionTakenAndDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userAvatarImageView;

@end
