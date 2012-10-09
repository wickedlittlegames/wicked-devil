//
//  OptionsScene.m
//  Wicked Little Devil
//
//  This scene shows the store for purchasing objects (individual or pack)
//
//  Created by Andrew Girvan on 06/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "EquipScene.h"
#import "CCScrollLayer.h"
#import "SimpleTableCell.h"
#import "MKStoreManager.h"
#import "WorldSelectScene.h"

@implementation EquipScene

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    EquipScene *current = [EquipScene node];
    [scene addChild:current];
    return scene;
}

-(id) init
{
    if( (self=[super init]) )
    {
        MKStoreObserver *observer = [[MKStoreObserver alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:observer];
        
        user = [[User alloc] init];
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        NSString *font = @"CrashLanding BB";

        app     = (AppController*)[[UIApplication sharedApplication] delegate];
        view    = [[UIView alloc] initWithFrame:CGRectMake(0, 115, screenSize.width, screenSize.height - 175)];
        table   = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height - 175)];
        
        data    = [NSArray arrayWithObjects:
                   @"Wicked Little Devil",
                   @"Bigger Jump",
                   @"Double Health",
                   nil];
        
        data2   = [NSArray arrayWithObjects:
                   @"1500",
                   @"3500",
                   @"3500",
                   nil];
        
        data3   = [NSArray arrayWithObjects:
                   @"Turn into a Little Devil",
                   @"Jump higher than ever!",
                   @"Double your chances of completing a level with enemies...",
                   @"Buy 50,000 Souls",
                   @"Buy 100,000 Souls",
                   nil];
        
        table.dataSource = self;
        table.delegate   = self;
        [view addSubview:table];
        [app.window addSubview:view];
        
        
        CCSprite *bg = [CCSprite spriteWithFile:@"bg-shop-bg.png"];
        [bg setPosition:ccp(screenSize.width/2,screenSize.height/2)];
        [self addChild:bg];
        
        CCMenu *menu_back               = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-back.png"    selectedImage:@"btn-back.png"       target:self selector:@selector(tap_back)], nil];
        [menu_back              setPosition:ccp(25, 25)];
        [self addChild:menu_back z:1000];
        
        // Collectable Button
        lbl_user_collected = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"COLLECTED: %i",user.collected] fontName:font fontSize:48];
        [lbl_user_collected setPosition:ccp ( screenSize.width/2, screenSize.height - 85 )];
        [self addChild:lbl_user_collected z:100];
    }
    return self;
}

- (void) tap_back
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click2.mp3"];}
    
    [view removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[WorldSelectScene scene]]];
}

- (void) tap_purchase:(int)item
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.mp3"];}
    
    NSString *feature = @"";
    int collectedincrease = 0;
    switch(item)
    {
        case 0:
            feature = IAP_2000soul; collectedincrease = 2000;
            break;
        case 1:
            feature = IAP_5000soul; collectedincrease = 5000;
            break;
        case 2:
            feature = IAP_10000soul; collectedincrease = 10000;
            break;
        case 3:
            feature = IAP_50000soul; collectedincrease = 50000;
            break;
        case 4:
            feature = IAP_100000soul; collectedincrease = 100000;
            break;
        default:break;
    }
    
    
    CCLOG(@"PURCHASING: %@", feature);
    
    [[MKStoreManager sharedManager] buyFeature:feature
                                    onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt)
     {
         NSLog(@"Purchased: %@", purchasedFeature);
         user = [[User alloc] init];
         CCLOG(@"USER COLLECTED %i", user.collected);
         user.collected += collectedincrease;
         [user sync];
         
         [lbl_user_collected setString:[NSString stringWithFormat:@"SOULS: %i",user.collected]];
         
         CCLOG(@"USER COLLECTED %i", user.collected);
     }
                                   onCancelled:^
     {
         NSLog(@"User Cancelled Transaction");
     }];
}


#pragma mark UITableView code

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [data count];
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.scrollEnabled = NO;
    
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    SimpleTableCell *cell = (SimpleTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    //    int section = [indexPath section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.label_description.font  = [UIFont fontWithName:@"CrashLanding BB" size:24.0f];
    cell.label_description.text = [data3 objectAtIndex:indexPath.row];
    cell.label_title.text = [data objectAtIndex:indexPath.row];
    cell.label_title.font = [UIFont fontWithName:@"CrashLanding BB" size:32.0f];
    cell.label_price.text    = [data2 objectAtIndex:indexPath.row];
    cell.label_price.font = [UIFont fontWithName:@"CrashLanding BB" size:40.0f];
    cell.image_thumbnail.image = [UIImage imageNamed:@"icon-bigcollectable-med.png"];
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
