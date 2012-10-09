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
@synthesize label_title = _label_title,label_description = _label_description ,label_price = _label_price,image_thumbnail = _image_thumbnail,button_buy = _button_buy;

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
