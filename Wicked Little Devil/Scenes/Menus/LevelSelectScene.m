//
//  LevelSelectScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "LevelSelectScene.h"
#import "WorldSelectScene.h"
#import "ShopScene.h"
#import "GameScene.h"
#import "MKStoreManager.h"
#import "MBProgressHUD.h"
#import "User.h"

@implementation LevelSelectScene

+(CCScene *) sceneWithWorld:(int)world
{
	CCScene *scene              = [CCScene node];
	LevelSelectScene *current   = [[LevelSelectScene alloc] initWithWorld:world];
	[scene addChild:current];
	return scene;
}

- (id) initWithWorld:(int)world
{
    if( (self=[super init]) ) 
    {
        // Used variables throughout
        user = [[User alloc] init];
        app             = (AppController*)[[UIApplication sharedApplication] delegate];

        CGSize screenSize       = [CCDirector sharedDirector].winSize;
        NSString *font          = @"CrashLanding BB";
        NSNumber *itemsPerRow   = [NSNumber numberWithInt:4];
        int fontsize            = 36;
        float menu_x            = (screenSize.width/2);
        float menu_y            = screenSize.height - 212;
        int world_score              = [user getHighscoreforWorld:world];
        int big_collectables_total   = (LEVELS_PER_WORLD * 3);
        int big_collectables_player  = 0;
        int halos_collectables       = 0;
        
        // Object sprite creation
        CCMenu  *menu                   = [CCMenu menuWithItems:nil];
    
        // Loop to show the levels
        for (int lvl = 1; lvl <= LEVELS_PER_WORLD; lvl++)
        {
            CCMenuItemImage *button = [CCMenuItemImage itemWithNormalImage:@"btn-level.png" selectedImage:@"btn-level.png" disabledImage:@"btn-level-locked.png" target:self selector:@selector(tap_level:)];
            button.tag = lvl; button.userData = (int*)world; button.isEnabled = FALSE;
            
            // Putting in debug tools
            if (DEVDEBUG) button.isEnabled = TRUE;
            
            if ( [user getGameProgressforWorld:world level:lvl] == 1 )
            {
                button.isEnabled = TRUE;
            }
            
            if ( button.isEnabled )
            {
                int souls = [user getSoulsforWorld:world level:lvl];
                int halos = [user getHalosforWorld:world level:lvl];
                big_collectables_player += souls;
                halos_collectables += halos;
                
                int soul_x = 13;
                for (int s = 1; s <= souls; s++ )
                {
                    CCSprite *soul = [CCSprite spriteWithFile:@"icon-level-bigcollectable.png"];

                    soul.position = ccp(button.position.x + soul_x, button.position.y - 2);
                    [button addChild:soul];
                    soul_x += 17;
                }
                
                for (int h = 1; h <= halos; h++ )
                {
                    CCSprite *halo = [CCSprite spriteWithFile:@"icon-level-halo.png"];
                    
                    halo.position = ccp(button.position.x + 30, button.position.y + 45);
                    [button addChild:halo];
                }
            }
            
            CCLabelTTF *lbl_level_name = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i",lvl] fontName:font fontSize:fontsize];
            lbl_level_name.position = ccp (lbl_level_name.position.x + 29, button.position.y + 29);
            
            switch (world)
            {
                case 1: 
                    lbl_level_name.color = ccc3(195, 0, 0);
                    break;
                case 2: 
                    lbl_level_name.color = ccc3(99, 99, 99);
                    break;
                case 3: 
                    lbl_level_name.color = ccc3(13, 133, 172);
                    break;
                case 4: 
                    lbl_level_name.color = ccc3(12, 124, 33);
                    break;
                case 5: 
                    lbl_level_name.color = ccc3(0, 0, 0);
                    break;
                case 6: 
                    lbl_level_name.color = ccc3(255, 255, 255);
                    break;
                default:
                    lbl_level_name.color = ccc3(0,0,0);
                    break;
            }
            
            [button addChild:lbl_level_name];               
            lbl_level_name.visible = button.isEnabled;

            [menu addChild:button];
        }
        [menu alignItemsInColumns:itemsPerRow, itemsPerRow, itemsPerRow,itemsPerRow,itemsPerRow,nil];

        CCSprite *bg                    = [CCSprite spriteWithFile:[NSString stringWithFormat:@"bg_%i.png", world]];
        CCMenu *menu_back               = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-back.png"    selectedImage:@"btn-back.png"       target:self selector:@selector(tap_back:)], nil];
        CCMenu *menu_skip               = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-back.png"    selectedImage:@"btn-back.png"       target:self selector:@selector(tap_skip)], nil];
        CCSprite *icon_bigcollectable   = [CCSprite spriteWithFile:@"icon-bigcollectable-med.png"];
        CCSprite *icon_collectable      = [CCSprite spriteWithFile:@"ui-collectable.png"];
        CCSprite *icon_halo             = [CCSprite spriteWithFile:@"icon-halo-med.png"];
        CCLabelTTF *label_world_score   = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %d",world_score] dimensions:CGSizeMake(screenSize.width - 20, 25) hAlignment:kCCTextAlignmentRight fontName:font fontSize:32];
        CCLabelTTF *label_bigcollected  = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i/%i", big_collectables_player, big_collectables_total] dimensions:CGSizeMake(screenSize.width - 80, 30) hAlignment:kCCTextAlignmentRight fontName:font fontSize:32];
        label_collected                 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", user.collected] dimensions:CGSizeMake(screenSize.width - 80, 30) hAlignment:kCCTextAlignmentRight fontName:font fontSize:32];
        CCLabelTTF *label_halo          = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i/%i", halos_collectables, (LEVELS_PER_WORLD)] dimensions:CGSizeMake(80, 30) hAlignment:kCCTextAlignmentLeft fontName:font fontSize:26];
        
        [bg                     setPosition:ccp(screenSize.width/2, screenSize.height/2 )];
        [menu                   setPosition:ccp(menu_x, menu_y)];        
        [menu_back              setPosition:ccp(25, 25)];
        [menu_skip              setPosition:ccp(75, 25)];
        [icon_bigcollectable    setPosition:ccp(screenSize.width - 20, screenSize.height - 20)];
        [label_bigcollected     setPosition:ccp(screenSize.width/2, screenSize.height - 22)];
        [icon_collectable       setPosition:ccp(screenSize.width - 20, icon_bigcollectable.position.y - 26)];
        [label_world_score      setPosition:ccp(screenSize.width/2, 22 )];
        [label_collected        setPosition:ccp(screenSize.width/2, label_bigcollected.position.y - 24)];

        [icon_halo              setPosition:ccp(20, screenSize.height - 20)];
        [label_halo             setPosition:ccp(80, screenSize.height - 20)];
        
        
        [self addChild:bg];
        [self addChild:menu];
        [self addChild:menu_back];
        CCLOG(@"%i",user.worldprogress);
        if ( !(user.worldprogress > world) )
        {
            [self addChild:menu_skip];
        }
        [self addChild:icon_bigcollectable];
        [self addChild:label_bigcollected];
        [self addChild:label_world_score];
        [self addChild:icon_collectable];
        [self addChild:label_collected];
        [self addChild:label_halo];
        [self addChild:icon_halo];
    }
    return self;
}

#pragma mark TAPS

- (void) tap_skip
{
    if ( user.collected >= SKIP_COST )
    {
        tmp_collectables  = user.collected;
        tmp_collectable_increment = SKIP_COST;
        
        user.collected -= SKIP_COST;
        [user sync];
        
        [self schedule: @selector(collectable_remove_tick) interval: 1.0f/60.0f];
    }
    else
    {
        [self tap_purchase];
    }
}

- (void) collectable_remove_tick
{
    if ( tmp_collectable_increment > 0 )
    {
        if (tmp_collectable_increment > 500)
		{
            tmp_collectable_increment -= 500;
            tmp_collectables -= 500;
            [label_collected setString:[NSString stringWithFormat:@"%i",tmp_collectables]];
        }
        
        if (tmp_collectable_increment > 100)
		{
            tmp_collectable_increment -= 100;
            tmp_collectables -= 100;
            [label_collected setString:[NSString stringWithFormat:@"%i",tmp_collectables]];
        }
        if (tmp_collectable_increment > 10)
		{
            tmp_collectable_increment -= 10;
            tmp_collectables -= 10;
            [label_collected setString:[NSString stringWithFormat:@"%i",tmp_collectables]];
        }
        else
		{
            tmp_collectable_increment --;
            tmp_collectables --;
            [label_collected setString:[NSString stringWithFormat:@"%i",tmp_collectables]];
        }
    }
    else
    {
        [self unschedule: @selector(collectable_remove_tick)];
        [user skipLevel];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[LevelSelectScene sceneWithWorld:user.worldprogress]]];
    }
}

- (void) collectable_add_tick
{
    if ( tmp_collectable_increment > 0 )
    {
        if (tmp_collectable_increment > 500)
		{
            tmp_collectable_increment -= 500;
            tmp_collectables += 500;
            [label_collected setString:[NSString stringWithFormat:@"%i",tmp_collectables]];
        }
        
        if (tmp_collectable_increment > 100)
		{
            tmp_collectable_increment -= 100;
            tmp_collectables += 100;
            [label_collected setString:[NSString stringWithFormat:@"%i",tmp_collectables]];
        }
        if (tmp_collectable_increment > 10)
		{
            tmp_collectable_increment -= 10;
            tmp_collectables += 10;
            [label_collected setString:[NSString stringWithFormat:@"%i",tmp_collectables]];
        }
        else
		{
            tmp_collectable_increment --;
            tmp_collectables ++;
            [label_collected setString:[NSString stringWithFormat:@"%i",tmp_collectables]];
        }
    }
    else
    {
        [self unschedule: @selector(collectable_add_tick)];
    }
}

- (void) tap_purchase
{
    [MBProgressHUD showHUDAddedTo:[app navController].view animated:YES];
    
    int collectedincrease = 10000;
    tmp_collectables            = user.collected;
    tmp_collectable_increment   = collectedincrease;
    
    [[MKStoreManager sharedManager] buyFeature:IAP_2000soul onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt)
     {
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

- (void) tap_level:(CCMenuItem*)sender
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameScene sceneWithWorld:(int)sender.userData andLevel:sender.tag isRestart:FALSE restartMusic:YES]]];
}

- (void) tap_back:(CCMenuItem*)sender
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[WorldSelectScene scene]]];
}

@end