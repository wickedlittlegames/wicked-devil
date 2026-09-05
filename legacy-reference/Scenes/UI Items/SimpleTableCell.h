//
//  SimpleTableCell.h
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 10/07/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleTableCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *label_title;
@property (nonatomic, strong) IBOutlet UILabel *label_description;
@property (nonatomic, strong) IBOutlet UILabel *label_price;
@property (nonatomic, strong) IBOutlet UIImageView *image_thumbnail;
@property (nonatomic, strong) IBOutlet UIButton *button_buy;

-(IBAction)buy:(id)sender;

@end