//
//  LevelSelectScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "LevelSelectScene.h"

@implementation LevelSelectScene

+(CCScene *) scene
{
    // Create a Scene
	CCScene *scene = [CCScene node];
	LevelSelectScene *current = [LevelSelectScene node];
    
    // Fill the scene
	[scene addChild:current];
    
    // Show the scene
	return scene;
}

-(id) init
{
	if( (self=[super init]) ) {
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        NSString *font = @"CrashLanding BB";
        int fontsize = 36;
        
        // Get the user
        user = [[User alloc] init];
                
        // Set up the world menu system
        [self world_menu_setup];

        // Store button
        CCMenu *menu_store = [CCMenu menuWithItems:nil];
        CCMenuItem *btn_store = [CCMenuItemImage 
                                 itemWithNormalImage:@"Storebutton.png"
                                 selectedImage:@"Storebutton.png"
                                 disabledImage:@"Storebutton.png"
                                 target:self 
                                 selector:@selector(tap_store)];
        [menu_store setPosition:ccp(screenSize.width - 20, 20)];
        [menu_store addChild:btn_store];
        [self addChild:menu_store];
        
        // Collectable Button
        lbl_user_collected = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"SOULS: %i",user.collected] fontName:font fontSize:fontsize];
        [lbl_user_collected setPosition:ccp ( lbl_user_collected.contentSize.width - 35, 20 )];
        [self addChild:lbl_user_collected z:100];
        
//        // Equippable Button
        CCMenu *menu_equip = [CCMenu menuWithItems:nil];
        CCMenuItem *btn_equip = [CCMenuItemImage 
                                 itemWithNormalImage:@"Powerupsbutton.png"
                                 selectedImage:@"Powerupsbutton.png"
                                 disabledImage:@"Powerupsbutton.png"
                                 target:self 
                                 selector:@selector(tap_equipment)];
        [menu_equip setPosition:ccp(screenSize.width - 60, 20)];
        [menu_equip addChild:btn_equip];
        [self addChild:menu_equip];

//        // Facebook Button
//        if ( user.isConnectedToFacebook )
//        {   
//            NSArray *fbName = [[[PFUser currentUser] valueForKey:@"fbName"] componentsSeparatedByString:@" "];
//            NSString *firstName = [fbName objectAtIndex:0];
//            
//            CCMenu *menu_facebook = [CCMenu menuWithItems:[CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:[NSString stringWithFormat:@"Welcome to HELL, %@",firstName] fontName:font fontSize:fontsize] target:self selector:@selector(tap_facebook)], nil];
//            [menu_facebook setPosition:ccp(95, screenSize.height - 25 )];
//            [self addChild:menu_facebook];
//        }
//        else 
//        {
//            CCMenu *menu_facebook = [CCMenu menuWithItems:[CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"LOGIN WITH FACEBOOK" fontName:font fontSize:fontsize] target:self selector:@selector(tap_facebook)], nil];
//            [menu_facebook setPosition:ccp(95, screenSize.height - 25 )];
//            [self addChild:menu_facebook];            
//        }
    }
	return self;    
}

#pragma mark Taps

- (void) tap_settings
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[SettingsScene scene]]];
}

- (void) tap_stats
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[StatsScene scene]]];    
}

- (void) tap_store
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[ShopScene scene]]];    
}

- (void) tap_equipment
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[EquipScene scene]]];    
}

- (void) tap_back
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[LevelSelectScene scene]]];    
}

- (void) tap_level:(CCMenuItem*)sender
{
    user.cache_current_world  = (int)sender.userData;
    [user sync_cache_current_world];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeTR transitionWithDuration:1 scene:[GameScene sceneWithWorld:(int)sender.userData andLevel:sender.tag isRestart:FALSE]]];        
}

- (void) tap_facebook
{   
    if ( user.isOnline )
    {
        NSArray *permissions = [NSArray arrayWithObjects:@"email,publish_actions", nil];
        [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *pfuser, NSError *error) {
            if (!pfuser) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else if (pfuser.isNew) {

                [[PFFacebookUtils facebook] requestWithGraphPath:@"me?fields=id,name,email" andDelegate:self];
                
            } else {
                
                // show the picture in the corner
                
            }
        }];
    }
}

#pragma mark PARSE FACEBOOK

- (void)request:(PF_FBRequest *)request didLoad:(id)result 
{
    [[PFUser currentUser] setObject:[result objectForKey:@"id"] forKey:@"fbId"];
    [[PFUser currentUser] setObject:[result objectForKey:@"name"] forKey:@"fbName"];
    [[PFUser currentUser] setObject:[result objectForKey:@"email"] forKey:@"email"];
    
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:100] forKey:@"collected"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"worlds_unlocked"];    
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if ( succeeded )
        {
            user.collected += 1000;
            [user sync];
        }
        else 
        {
            NSLog(@"THERE WERE ERRORS: %@",error);
        }
    }];
}

-(void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error 
{
    if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] isEqualToString: @"OAuthException"]) 
    {
        NSLog(@"The facebook token was invalidated:%@",error);
    } 
    else 
    {
        NSLog(@"Some other error:%@",error);
    }
}

#pragma mark UI Setup

- (void) world_menu_setup
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    NSNumber* itemsPerRow = [NSNumber numberWithInt:4];
    float menu_x = (screenSize.width/2);
    float menu_y = 275;
    NSString *font = @"CrashLanding BB";
    int fontsize = 38;
    
    NSMutableArray *worlds = [NSMutableArray arrayWithCapacity:WORLDS_PER_GAME];
    
    CCLayer *community = [CCLayer node];
    CCLabelTTF *lbl_community = [CCLabelTTF labelWithString:@"COMMUNITY" fontName:font fontSize:18];
    CCLabelTTF *news = [CCLabelTTF labelWithString:@"You need to be online to retreive the latest news" fontName:font fontSize:14];
    [news setPosition:ccp(screenSize.width/2, screenSize.height/2)];
    
    if ( user.isOnline )
    {
        PFQuery *query = [PFQuery queryWithClassName:@"News"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
            if (!error) {
                for (int i = 0; i < [posts count]; i++)
                {
                    PFObject *post = [[posts objectAtIndex:i] valueForKey:@"Content"];
                    [news setString:[NSString stringWithFormat:@"%@",post]];
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    
    [community addChild:news];
    lbl_community.position = ccp ( screenSize.width/2, 420 );
    [community addChild:lbl_community];        
    [worlds addObject:community];
    
    for (int w = 1; w <= WORLDS_PER_GAME; w++)
    {
        CCLayer *world = [CCLayer node];
        
        CCMenu *menu_world = [CCMenu menuWithItems:nil];
        menu_world.position = ccp ( menu_x, menu_y );
        
        CCSprite *bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"bg_%i.png", w]];
        [world addChild:bg];
        [bg setPosition:ccp(screenSize.width/2, screenSize.height/2 )];
        
        int world_souls_total = 0;
        int world_score_total = [user getHighscoreforWorld:w];
        
        for (int lvl = 1; lvl <= LEVELS_PER_WORLD; lvl++)
        {
            CCMenuItem *btn_level = [CCMenuItemImage 
                                     itemWithNormalImage:[NSString stringWithFormat:@"level.png",lvl]
                                     selectedImage:[NSString stringWithFormat:@"level.png",lvl] 
                                     disabledImage:[NSString stringWithFormat:@"level-locked.png",lvl] 
                                     target:self 
                                     selector:@selector(tap_level:)];
            
            CCLabelTTF *lbl_level_name = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i",lvl] fontName:font fontSize:fontsize];
            lbl_level_name.position = ccp (lbl_level_name.position.x + 29, btn_level.position.y + 29);
            
            switch (w)
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
            
            [btn_level addChild:lbl_level_name];
            
            btn_level.userData = (int*)w;
            btn_level.tag      = lvl;
            btn_level.isEnabled = FALSE;
            
            if ( w == 1 )
            {
                btn_level.isEnabled = TRUE;
                if ( user.worldprogress > 1 )
                {
                    btn_level.isEnabled = TRUE;
                }
                else 
                {
                    btn_level.isEnabled = ( user.levelprogress >= lvl ? TRUE : FALSE );
                }
            }
            
            if ( user.worldprogress > w )
            {
                btn_level.isEnabled = TRUE;
            }
            else if ( user.worldprogress < w )
            {
                btn_level.isEnabled = FALSE;
            }
            else if ( user.worldprogress == w )
            {
                btn_level.isEnabled = ( user.levelprogress >= lvl ? TRUE : FALSE );
            }
            
            if ( btn_level.isEnabled )
            {
                int souls = [user getSoulsforWorld:w level:lvl];
                world_souls_total += souls;
                
                CCLabelTTF *lbl_level_souls = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",souls] fontName:font fontSize:16];
                lbl_level_souls.color = ccc3(0,0,0);
                lbl_level_souls.position = ccp (lbl_level_souls.position.x + 50, lbl_level_souls.position.y + 10);
                //[btn_level addChild:lbl_level_souls];                    
            }
            
            lbl_level_name.visible = btn_level.isEnabled;            
            
            [menu_world addChild:btn_level];
        }
        
        [menu_world alignItemsInColumns:itemsPerRow, itemsPerRow, itemsPerRow,nil];
        
        CCLabelTTF *world_score = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"World: %d",world_score_total] fontName:font fontSize:32];
        world_score.position = ccp (90, 390);
        [world addChild:world_score];            
        
        CCLabelTTF *world_stars = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d / %d",world_souls_total,LEVELS_PER_WORLD*3] fontName:font fontSize:32];
        world_stars.position = ccp ( screenSize.width - 80, 390);
        [world addChild:world_stars];
        
        [world addChild:menu_world];
        [worlds addObject:world];
    }
    
    CCLayer *purgatory = [CCLayer node];
    CCLabelTTF *lbl_purgatory = [CCLabelTTF labelWithString:@"PURGATORY" fontName:font fontSize:42];
    lbl_purgatory.position = ccp ( screenSize.width/2, 420 );
    [purgatory addChild:lbl_purgatory];
    [worlds addObject:purgatory];
    
    CCScrollLayer *scroller = [[CCScrollLayer alloc] initWithLayers:worlds widthOffset: 0];
    if ( user.cache_current_world == 0 )
    {
        [scroller selectPage:1];
        user.cache_current_world = 1;
        [user sync];
    }
    else 
    {
        [scroller selectPage:user.cache_current_world];        
    }
    
    [self addChild:scroller];
}

#pragma mark GameKit delegate

- (void) tap_achievements:(id)sender
{
    GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
    achivementViewController.achievementDelegate = self;
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    
    [[app navController] presentModalViewController:achivementViewController animated:YES];
}

- (void) tap_leaderboards:(id)sender
{
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    leaderboardViewController.leaderboardDelegate = self;
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    
    [[app navController] presentModalViewController:leaderboardViewController animated:YES];
    
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end