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
#import "WorldSelectScene.h"
#import "ShopScene.h"
#import "FlurryAnalytics.h"

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
        user = [[User alloc] init];
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        NSString *font = @"CrashLanding BB";

        app     = (AppController*)[[UIApplication sharedApplication] delegate];
        view    = [[UIView alloc] initWithFrame:CGRectMake(0, 115, screenSize.width, screenSize.height - 175)];
        table   = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height - 175)];
    
        
        // Pull in the Cards plist
        NSArray *contentArray = [[NSDictionary  dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Powerups" ofType:@"plist"]] objectForKey:@"Powerups"];
        data = [NSMutableArray arrayWithCapacity:100];
        data2 = [NSMutableArray arrayWithCapacity:100];
        data3 = [NSMutableArray arrayWithCapacity:100];
        
        for (int i = 0; i <[contentArray count]; i++ )
        {
            // Grab the powerup contents
            NSDictionary *dict = [contentArray objectAtIndex:i]; //name, description, cost, unlocked, image
            [data addObject:[dict objectForKey:@"Name"]];
            [data2 addObject:[dict objectForKey:@"Cost"]];
            [data3 addObject:[dict objectForKey:@"Description"]];;
            
        }

        table.dataSource = self;
        table.delegate   = self;
        [view addSubview:table];
        [app.window addSubview:view];
        
        CCSprite *bg                    = [CCSprite spriteWithFile:(IS_IPHONE5 ? @"bg-shop-bg-iphone5.png" : @"bg-shop-bg.png")];
        CCMenu *menu_back               = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-back.png"    selectedImage:@"btn-back.png"       target:self selector:@selector(tap_back)], nil];
        resetAll                        = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-unequip-all.png" selectedImage:@"btn-unequip-all.png"           target:self selector:@selector(tap_resetPowerups)],nil];
        lbl_user_collected              = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"COLLECTED: %i",user.collected] fontName:font fontSize:48];
        
        [bg                 setPosition:ccp(screenSize.width/2,screenSize.height/2)];
        [menu_back          setPosition:ccp(25, 25)];
        [lbl_user_collected setPosition:ccp(screenSize.width/2, screenSize.height - 85)];
        [resetAll           setPosition:ccp(screenSize.width - 80, 25)];
        [resetAll setOpacity:0];
        
        [self addChild:bg];
        [self addChild:menu_back z:1000];
        [self addChild:lbl_user_collected z:100];
        [self addChild:resetAll];
        
        if ( user.bought_powerups )
        {
            [resetAll setOpacity:255];
        }
    }
    return self;
}

- (void) tap_resetPowerups
{
    [resetAll runAction:[CCFadeOut actionWithDuration:0.5f]];
    user.powerup = 0;
    user.bought_powerups = NO;
    [user sync];
    
    NSMutableArray *tmp_table_view = [NSMutableArray arrayWithCapacity:data.count];
    for (int i = 0; i < data.count; i++)
    {
        NSIndexPath *equip_item = [NSIndexPath indexPathForItem:i inSection:0];
        [tmp_table_view addObject:equip_item];
    }
    [table reloadRowsAtIndexPaths:tmp_table_view withRowAnimation:UITableViewRowAnimationNone];
}

- (void) tap_back
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [view removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[WorldSelectScene scene]]];
}

- (void) tap_purchase:(UIButton*)sender
{
    [FlurryAnalytics logEvent:[NSString stringWithFormat:@"Player Tapped Equip Purchase for item: %i",sender.tag]];
    int item = sender.tag;
    int cost = [[data2 objectAtIndex:item] intValue];

    if ( user.collected >= cost )
    {
        [FlurryAnalytics logEvent:[NSString stringWithFormat:@"Player Completed Equip Purchase for item: %i",sender.tag]];
        
        tmp_collectables = user.collected;
        tmp_collectable_increment = cost;
        
        user.collected -= cost;
        [user buyItem:sender.tag];
        [user sync];
        
        NSMutableArray *tmp_table_view = [NSMutableArray arrayWithCapacity:data.count];
        for (int i = 0; i < data.count; i++)
        {
            NSIndexPath *equip_item = [NSIndexPath indexPathForItem:i inSection:0];
            [tmp_table_view addObject:equip_item];
        }
        [table reloadRowsAtIndexPaths:tmp_table_view withRowAnimation:UITableViewRowAnimationNone];

        [self schedule: @selector(collectable_remove_tick) interval: 1.0f/60.0f];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Not Enough Souls!"
                                  message:@"You don't have enough souls! Would you like to buy some?"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"Buy Souls", nil];
        [alertView show];
    }

}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [view removeFromSuperview];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[ShopScene scene]]];
    }
}

- (void) tap_equip:(UIButton*)sender
{
    [FlurryAnalytics logEvent:[NSString stringWithFormat:@"Player Equipped item: %i",sender.tag]];

    if ( !user.bought_powerups ) user.bought_powerups = TRUE;
    user.powerup = sender.tag;
    [user sync];
    
    NSMutableArray *tmp_table_view = [NSMutableArray arrayWithCapacity:data.count];
    for (int i = 0; i < data.count; i++)
    {
        NSIndexPath *equip_item = [NSIndexPath indexPathForItem:i inSection:0];
        [tmp_table_view addObject:equip_item];
    }
    [table reloadRowsAtIndexPaths:tmp_table_view withRowAnimation:UITableViewRowAnimationNone];
    
    [resetAll runAction:[CCFadeIn actionWithDuration:0.5f]];
}

- (void) collectable_remove_tick
{
    if ( tmp_collectable_increment > 0 )
    {
        if (tmp_collectable_increment > 500)
		{
            tmp_collectable_increment -= 500;
            tmp_collectables -= 500;
            [lbl_user_collected setString:[NSString stringWithFormat:@"COLLECTED: %i",tmp_collectables]];
        }
        
        if (tmp_collectable_increment > 100)
		{
            tmp_collectable_increment -= 100;
            tmp_collectables -= 100;
            [lbl_user_collected setString:[NSString stringWithFormat:@"COLLECTED: %i",tmp_collectables]];
        }
        if (tmp_collectable_increment > 10)
		{
            tmp_collectable_increment -= 10;
            tmp_collectables -= 10;
            [lbl_user_collected setString:[NSString stringWithFormat:@"COLLECTED: %i",tmp_collectables]];
        }
        else
		{
            tmp_collectable_increment --;
            tmp_collectables --;
            [lbl_user_collected setString:[NSString stringWithFormat:@"COLLECTED: %i",tmp_collectables]];
        }
    }
    else
    {
        [self unschedule: @selector(collectable_remove_tick)];
    }
}


#pragma mark UITableView code

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];

    SimpleTableCell *cell = (SimpleTableCell *)[tableView dequeueReusableCellWithIdentifier:@"SimpleTableCell"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    cell.selectionStyle             = UITableViewCellSelectionStyleNone;
    cell.label_title.font           = [UIFont fontWithName:@"CrashLanding BB" size:32.0f];    
    cell.label_price.font           = [UIFont fontWithName:@"CrashLanding BB" size:40.0f];
    cell.label_description.font     = [UIFont fontWithName:@"CrashLanding BB" size:24.0f];
    
    cell.label_title.text           = [data objectAtIndex:indexPath.row];
    cell.label_price.text           = [NSString stringWithFormat:@"%i",[[data2 objectAtIndex:indexPath.row] intValue]];
    cell.label_description.text     = [data3 objectAtIndex:indexPath.row];
    
    cell.button_buy.selected        = TRUE;    
    cell.button_buy.tag             = indexPath.row;
    
    [cell.button_buy removeTarget:self action:@selector(tap_equip:)     forControlEvents:UIControlEventTouchUpInside];
    [cell.button_buy removeTarget:self action:@selector(tap_purchase:)  forControlEvents:UIControlEventTouchUpInside];
    
    if ( [[user.items objectAtIndex:indexPath.row] intValue] == 1 )
    {
        if (user.powerup == indexPath.row && user.bought_powerups )
        {
            cell.button_buy.imageView.image = [UIImage imageNamed:@"btn-equipequipped.png"];
            cell.label_price.text = @"EQUIPPED";
        }
        else
        {
            cell.label_price.text = @"EQUIP";
        }
        
        cell.button_buy.selected = FALSE;
        [cell.button_buy addTarget:self action:@selector(tap_equip:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [cell.button_buy addTarget:self action:@selector(tap_purchase:) forControlEvents:UIControlEventTouchUpInside];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section     { return nil; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section        { return [data count]; }
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView                              { return 1; }
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  { return 75; }

@end
