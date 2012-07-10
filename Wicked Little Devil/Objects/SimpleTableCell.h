//
//  SimpleTableCell.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 10/07/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleTableCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *label_title;
@property (nonatomic, weak) IBOutlet UILabel *label_description;
@property (nonatomic, weak) IBOutlet UILabel *label_price;
@property (nonatomic, weak) IBOutlet UIImageView *image_thumbnail;
@property (nonatomic, weak) IBOutlet UIButton *button_buy;

-(IBAction)buy:(id)sender;

@end