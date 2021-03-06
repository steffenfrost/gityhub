//
//  UserCollectionViewCell.h
//  GityHub
//
//  Created by Steven Frost-Ruebling on 5/7/15.
//  Copyright (c) 2015 nearIM, Inc. All rights reserved.

#import <UIKit/UIKit.h>

@interface UserCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *actionTakenAndDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userAvatarImageView;

@end
