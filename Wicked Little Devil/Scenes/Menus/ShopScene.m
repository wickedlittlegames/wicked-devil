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
#import "MKStoreManager.h"
#import "MBProgressHUD.h"
#import "WorldSelectScene.h"
#import "FlurryAnalytics.h"

@implementation ShopScene

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    ShopScene *current = [ShopScene node];
    [scene addChild:current];
    return scene;
}

-(id) init
{
    if( (self=[super init]) )
    {
        // Load the app so we can do stuff like add tables, ui views etc...
        app             = (AppController*)[[UIApplication sharedApplication] delegate];
        timeout_check   = 0;
        
        // Load the user object for store data
        user = [[User alloc] init];
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        NSString *font = @"CrashLanding BB";
        
        // Show HUD whilst page loads with data from itunes connect
        [MBProgressHUD showHUDAddedTo:[app navController].view animated:YES];
        if ( [[MKStoreManager sharedManager] pricesDictionary].count <= 0 )  [self schedule:@selector(screenSetup) interval:1.0f];
        else [self setupTable];

        // set up the design and functional sprites
        CCSprite *bg                    = [CCSprite spriteWithFile:(IS_IPHONE5 ? @"bg-shop-bg-iphone5.png" : @"bg-shop-bg.png")];
        CCMenu *menu_back               = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-back.png"    selectedImage:@"btn-back.png"       target:self selector:@selector(tap_back)], nil];
        lbl_user_collected              = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"COLLECTED: %i",user.collected] fontName:font fontSize:48];
        
        [bg                 setPosition:ccp(screenSize.width/2,screenSize.height/2)];
        [menu_back          setPosition:ccp(25, 25)];
        [lbl_user_collected setPosition:ccp(screenSize.width/2, screenSize.height - 85)];
        
        [self addChild:bg];
        [self addChild:menu_back z:1000];
        [self addChild:lbl_user_collected z:100];
    }
    return self;
}

- (void) screenSetup
{
    if ( timeout_check <= 15 )
    {
        timeout_check++;
        if ( !([[MKStoreManager sharedManager] pricesDictionary].count <= 0) ) [self setupTable];
    }
    else
    {
        [self unschedule:@selector(screenSetup)];
        [MBProgressHUD hideHUDForView:[app navController].view animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Could not retrieve products."
                                  message:@"Please try again."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void) setupTable
{
    [MBProgressHUD hideHUDForView:[app navController].view animated:YES];
    [self unschedule:@selector(screenSetup)];

    NSDictionary *prices = [[MKStoreManager sharedManager] pricesDictionary];
    NSMutableArray *descs  = [[MKStoreManager sharedManager] purchasableObjectsDescription];
    
    NSString *upgradePrice1 = [prices objectForKey:IAP_2000soul];
    NSString *upgradePrice2 = [prices objectForKey:IAP_5000soul];
    NSString *upgradePrice3 = [prices objectForKey:IAP_10000soul];
    NSString *upgradePrice4 = [prices objectForKey:IAP_50000soul];
    NSString *upgradePrice5 = [prices objectForKey:IAP_100000soul];
    NSString *description1  = [descs objectAtIndex:2];
    NSString *description2  = [descs objectAtIndex:4];
    NSString *description3  = [descs objectAtIndex:1];
    NSString *description4  = [descs objectAtIndex:3];
    NSString *description5  = [descs objectAtIndex:0];
    

    view    = [[UIView alloc] initWithFrame:CGRectMake(0, 115, [CCDirector sharedDirector].winSize.width, [CCDirector sharedDirector].winSize.height - 175)];
    table   = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [CCDirector sharedDirector].winSize.width, [CCDirector sharedDirector].winSize.height - 175)];
    
    data    = [NSArray arrayWithObjects: description1,description2,description3,description4,description5,nil];
    data2   = [NSArray arrayWithObjects: upgradePrice1,upgradePrice2,upgradePrice3,upgradePrice4,upgradePrice5, nil];
    data3   = [NSArray arrayWithObjects: @"10,000 Souls",@"20,000 Souls", @"50,000 Souls", @"100,000 Souls", @"200,000 Souls", nil];
    
    table.dataSource = self;
    table.delegate   = self;
    [view addSubview:table];
    [app.window addSubview:view];
}

- (void) tap_purchase:(id) sender
{
    [MBProgressHUD showHUDAddedTo:[app navController].view animated:YES];
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    UIButton *button = (UIButton*)sender;
    
    [FlurryAnalytics logEvent:[NSString stringWithFormat:@"Player Tapped Purchase Item %i",button.tag]];
    
    NSString *feature = @"";
    int collectedincrease = 0;
    
    switch(button.tag)
    {
        case 0: feature = IAP_2000soul; collectedincrease = 10000; break;
        case 1: feature = IAP_5000soul; collectedincrease = 20000; break;
        case 2: feature = IAP_10000soul; collectedincrease = 50000; break;
        case 3: feature = IAP_50000soul; collectedincrease = 100000; break;
        case 4: feature = IAP_100000soul; collectedincrease = 200000; break;
        default:break;
    }
    
    tmp_collectables            = user.collected;
    tmp_collectable_increment   = collectedincrease;

    [[MKStoreManager sharedManager] buyFeature:feature onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt)
    {
        [FlurryAnalytics logEvent:[NSString stringWithFormat:@"Player Completed Purchase Item %i",button.tag]];
        
        user = [[User alloc] init];
        user.collected += collectedincrease;
        [user sync];
        [MBProgressHUD hideHUDForView:[app navController].view animated:YES];
        [self schedule: @selector(collectable_add_tick) interval: 1.0f/60.0f];
    }
    onCancelled:^
    {
        [MBProgressHUD hideHUDForView:[app navController].view animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Transaction Canceled"
                                  message:@"There appears to have been a problem with the transaction."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }];
}

- (void) collectable_add_tick
{
    if ( tmp_collectable_increment > 0 )
    {
        if (tmp_collectable_increment > 500)
		{
            tmp_collectable_increment -= 500;
            tmp_collectables += 500;
            [lbl_user_collected setString:[NSString stringWithFormat:@"COLLECTED: %i",tmp_collectables]];
        }

        if (tmp_collectable_increment > 100)
		{
            tmp_collectable_increment -= 100;
            tmp_collectables += 100;
            [lbl_user_collected setString:[NSString stringWithFormat:@"COLLECTED: %i",tmp_collectables]];
        }
        if (tmp_collectable_increment > 10)
		{
            tmp_collectable_increment -= 10;
            tmp_collectables += 10;
            [lbl_user_collected setString:[NSString stringWithFormat:@"COLLECTED: %i",tmp_collectables]];
        }
        else
		{
            tmp_collectable_increment --;
            tmp_collectables ++;
            [lbl_user_collected setString:[NSString stringWithFormat:@"COLLECTED: %i",tmp_collectables]];
        }
    }
    else
    {
        [self unschedule: @selector(collectable_add_tick)];
    }
}

- (void) tap_back
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [view removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[WorldSelectScene scene]]];
}



#pragma mark UITableView code

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.scrollEnabled = NO;

    SimpleTableCell *cell = (SimpleTableCell *)[tableView dequeueReusableCellWithIdentifier:@"SimpleTableCell"];
    if (cell == nil) 
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    } 

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.label_title.font           = [UIFont fontWithName:@"CrashLanding BB" size:24.0f];
    cell.label_price.font           = [UIFont fontWithName:@"CrashLanding BB" size:32.0f];
    cell.label_description.font     = [UIFont fontWithName:@"CrashLanding BB" size:22.0f];

    cell.label_title.text       = [data objectAtIndex:indexPath.row];
    cell.label_price.text       = [data2 objectAtIndex:indexPath.row];
    cell.label_description.text = [data3 objectAtIndex:indexPath.row];
    
    cell.button_buy.tag = indexPath.row;
    [cell.button_buy addTarget:self action:@selector(tap_purchase:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {return nil;}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return [data count]; }
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView { return 1; }
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { return 46; }

@end
