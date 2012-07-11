//
//  OptionsScene.m
//  Wicked Little Devil
//
//  This scene shows the store for purchasing objects (individual or pack)
//
//  Created by Andrew Girvan on 06/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "ShopScene.h"
#import "CCScrollLayer.h"
#import "SimpleTableCell.h"

@implementation ShopScene

+(CCScene *) scene
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
	ShopScene *current = [ShopScene node];
    
    // Fill the scene
	[scene addChild:current z:10];
    
    // Show the scene
	return scene;
}

-(void)buttonTapped:(id)sender
{
	NSLog(@"buttonTapped");
}


-(id) init
{
    if( (self=[super init]) ) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        User *user = [[User alloc] init];
        
        self.isTouchEnabled = YES;
        
        app = (AppController*)[[UIApplication sharedApplication] delegate];
        view  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 450)];
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 450)];
        data = [NSArray arrayWithObjects:@"1,000 souls", @"2,500 souls", @"5,000 souls", @"10,000 souls", @"100,000 souls", @"1,000,000 souls", nil];        
        data2 = [NSArray arrayWithObjects:@"£0.69",@"£0.99",@"£1.99",@"£4.99", @"£8.99", @"£10.99",nil];
        
        table.dataSource = self;
        table.delegate   = self;
        [view addSubview:table];
        [app.window addSubview:view];
        
        //User *user = [User alloc];
        CCMenuItem *back = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"BACK" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_back)];
        CCMenu *menu = [CCMenu menuWithItems:back, nil];
        menu.position = ccp ( screenSize.width - 80, 10 );
        [self addChild:menu z:100];
        
        CCLabelTTF *lbl_user_collected = [CCLabelTTF labelWithString:@"Collected:" fontName:@"Marker Felt" fontSize:18];
        lbl_user_collected.position = ccp ( lbl_user_collected.contentSize.width, 10 );
        lbl_user_collected.string = [NSString stringWithFormat:@"Collected: %i",user.collected];
        [self addChild:lbl_user_collected z:100];
    }
    return self;
}

- (void) tap_back
{
    [view removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];
}

- (void) tap_purchase:(int)item
{
    NSLog(@"Item %d",item);
}

#pragma mark UITableView code

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //switch (section) {
    //    case 0: return  @"Currency"; break;
    //    case 1: return  @"Misc"; break;
    //}
    return @"Currency";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //switch (section) {
      //  case 0: return [data count]; break;
       // case 1: return [data2 count]; break;
    //}
    return [data count];
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    SimpleTableCell *cell = (SimpleTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) 
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    } 
//    int section = [indexPath section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.label_title.text = [data objectAtIndex:indexPath.row];
    cell.label_description.text = @"Lorem ipsum dolor sit amet consequtor";
    cell.label_price.text    = [data2 objectAtIndex:indexPath.row];
    cell.image_thumbnail.image = [UIImage imageNamed:@"platform-normal.png"];
    cell.button_buy.tag = [[data objectAtIndex:indexPath.row] intValue];


//    switch (section) {
//        case 0:
//            cell.label_title.text = [data objectAtIndex:indexPath.row];
//            cell.label_description.text = @"Lorem ipsum dolor sit amet consequtor";
//            cell.label_price.text    = [data2 objectAtIndex:indexPath.row];
//            cell.image_thumbnail.image = [UIImage imageNamed:@"platform-normal.png"];
//            cell.button_buy.tag = [[data objectAtIndex:indexPath.row] intValue];
//            break;
//        case 1:
//            cell.label_title.text = [data2 objectAtIndex:indexPath.row];
//            cell.label_description.text = @"Lorem ipsum dolor sit amet consequtor";
//            cell.label_price.text    = @"2000";
//            [cell.button_buy setEnabled:NO];
//            cell.image_thumbnail.image = [UIImage imageNamed:@"platform-normal.png"];
//            cell.button_buy.tag = [[data objectAtIndex:indexPath.row] intValue];            
//            break;
//    }
        
    return cell;
}


@end
