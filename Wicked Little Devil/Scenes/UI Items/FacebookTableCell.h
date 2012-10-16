//
//  FacebookTableCell.h
//  Wicked Little Devil
//
//  Created by Andy on 16/10/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;
@property (nonatomic, weak) IBOutlet UIImageView *facebookImageView;

@end
