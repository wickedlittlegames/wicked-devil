//
//  FacebookTableCell.m
//  Wicked Little Devil
//
//  Created by Andy on 16/10/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import "FacebookTableCell.h"

@implementation FacebookTableCell
@synthesize nameLabel = _nameLabel;
@synthesize scoreLabel = _scoreLabel;
@synthesize facebookImageView = _facebookImageView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
