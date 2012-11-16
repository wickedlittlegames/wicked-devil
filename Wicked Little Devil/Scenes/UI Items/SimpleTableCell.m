//
//  SimpleTableCell.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 10/07/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import "SimpleTableCell.h"
#import "ShopScene.h"

@implementation SimpleTableCell

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

-(IBAction)buy:(id)sender
{
    
}

@end
