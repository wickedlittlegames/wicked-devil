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
	[scene addChild:current z:10];
    
    // Show the scene
	return scene;
}

-(id) init
{
	if( (self=[super init]) ) {
        CCLOG(@"LEVELSELECT SCENE INIT");
        
        // Get the user
        user = [[User alloc] init];
        
        // Screen Size
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        NSNumber* itemsPerRow = [NSNumber numberWithInt:4];
        float menu_x = (screenSize.width/2);
        float menu_y = 275;
        
        NSMutableArray *worlds = [NSMutableArray arrayWithCapacity:WORLDS_PER_GAME];
        CCLOG(@"LOOPING THROUGH WORLDS TO CREATE LEVEL MENUS");
        for (int w = 1; w <= WORLDS_PER_GAME; w++)
        {
            CCLayer *world = [CCLayer node];
                      
            CCMenu *world_menu = [CCMenu menuWithItems:nil];
            world_menu.position = ccp ( menu_x, menu_y );
            
            int world_souls_total = 0;
            int world_score_total = [user getHighscoreforWorld:w];
            
            for (int lvl = 1; lvl <= LEVELS_PER_WORLD; lvl++)
            {
                CCMenuItem *level = [CCMenuItemImage 
                                           itemWithNormalImage:[NSString stringWithFormat:@"Icon.png",lvl]
                                           selectedImage:[NSString stringWithFormat:@"Icon.png",lvl] 
                                           disabledImage:[NSString stringWithFormat:@"icon-locked.png",lvl] 
                                           target:self 
                                           selector:@selector(tap_level:)];
                
                CCLabelTTF *lbl_level_name = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i - %i",w,lvl] fontName:@"Marker Felt" fontSize:12];
                lbl_level_name.position = ccp (lbl_level_name.position.x + 27, lbl_level_name.position.y - 12);
                [level addChild:lbl_level_name];
                
                level.userData = (int*)w;
                level.tag      = lvl;
                level.isEnabled = FALSE;
                
                if ( w == 1 )
                {
                    level.isEnabled = TRUE;
                    if ( user.worldprogress > 1 )
                    {
                        level.isEnabled = TRUE;
                    }
                    else 
                    {
                        level.isEnabled = ( user.levelprogress >= lvl ? TRUE : FALSE );
                    }
                }
                if ( user.worlds_unlocked )
                {
                    if ( user.worldprogress > w )
                    {
                        level.isEnabled = TRUE;
                    }
                    else if ( user.worldprogress < w )
                    {
                        level.isEnabled = FALSE;
                    }
                    else if ( user.worldprogress == w )
                    {
                        level.isEnabled = ( user.levelprogress >= lvl ? TRUE : FALSE );
                    }
                }

                if ( level.isEnabled )
                {
                    int souls = [user getSoulsforWorld:w level:lvl];
                    world_souls_total += souls;
                    
                    CCLabelTTF *lbl_level_souls = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",souls] fontName:@"Marker Felt" fontSize:16];
                    lbl_level_souls.color = ccc3(0,0,0);
                    lbl_level_souls.position = ccp (lbl_level_souls.position.x + 50, lbl_level_souls.position.y + 10);
                    [level addChild:lbl_level_souls];                    
                }
                
                [world_menu addChild:level];
                CCLOG(@"LEVEL %i CREATED", lvl);
            }
            
            [world_menu alignItemsInColumns:itemsPerRow, itemsPerRow, itemsPerRow,nil];
            
            CCLOG(@"SETTING WORLD SCORE");             
            CCLabelTTF *world_score = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"World: %d",world_score_total] fontName:@"Marker Felt" fontSize:14];
            world_score.position = ccp (90, 390);
            [world addChild:world_score];            
            
            CCLOG(@"SETTING WORLD STARS");                         
            CCLabelTTF *world_stars = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d / %d",world_souls_total,LEVELS_PER_WORLD*3] fontName:@"Marker Felt" fontSize:14];
            world_stars.position = ccp ( screenSize.width - 80, 390);
            [world addChild:world_stars];
            
            [world addChild:world_menu];
            
            [worlds addObject:world];
            CCLOG(@"WORLD %i CREATED", w);
        }
        
        CCLOG(@"INIT SCROLLER");
        CCScrollLayer *scroller = [[CCScrollLayer alloc] initWithLayers:worlds widthOffset: 0];

        CCLOG(@"ADDING PURGATORY PAGE");
        CCLayer *purgatory = [CCLayer node];
        CCLabelTTF *lbl_purgatory = [CCLabelTTF labelWithString:@"PURGATORY" fontName:@"Marker Felt" fontSize:18];
        lbl_purgatory.position = ccp ( screenSize.width/2, 420 );
        [purgatory addChild:lbl_purgatory];
        [scroller addPage:purgatory];
        
        CCLOG(@"ADDING COMMUNITY PAGE");
        CCLayer *community = [CCLayer node];
        CCLabelTTF *lbl_community = [CCLabelTTF labelWithString:@"COMMUNITY" fontName:@"Marker Felt" fontSize:18];
        lbl_community.position = ccp ( screenSize.width/2, 420 );
        [community addChild:lbl_community];        
        [scroller addPage:community];
        
        CCLOG(@"ADDING UI ELEMENTS");        
        CCMenuItem *store = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"Store" fontName:@"Marker Felt" fontSize:18] target:self selector:@selector(tap_store:)];
        CCMenu *storemenu = [CCMenu menuWithItems:store, nil];
        [storemenu alignItemsHorizontallyWithPadding:20];
        storemenu.position = ccp ( screenSize.width - 60, 10 );
        
        CCMenuItem *btn_leaderboards = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"Leaderboards" fontName:@"Marker Felt" fontSize:18] target:self selector:@selector(tap_leaderboards:)];
        CCMenuItem *btn_achievements = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"Achievements" fontName:@"Marker Felt" fontSize:18] target:self selector:@selector(tap_achievements:)];
        CCMenu *menu_gamecenter = [CCMenu menuWithItems:btn_leaderboards,btn_achievements, nil];
        [menu_gamecenter alignItemsHorizontallyWithPadding:20];
        menu_gamecenter.position = ccp ( screenSize.width/2, 40 );
        [self addChild:menu_gamecenter z:101];
        
        CCLOG(@"SETTING THE BUTTON/LABEL FOR FACEBOOK LOGIN");
        lbl_user_collected = [CCLabelTTF labelWithString:@"Collected:" fontName:@"Marker Felt" fontSize:18];
        lbl_user_collected.position = ccp ( lbl_user_collected.contentSize.width, 10 );
        lbl_user_collected.string = [NSString stringWithFormat:@"Collected: %i",user.collected];
        [self addChild:lbl_user_collected z:100];
                
        /*CCMenuItem *btn_facebook = [CCMenuItemFont 
                                    itemWithLabel:[CCLabelTTF labelWithString:str_facebook fontName:@"Marker Felt" fontSize:18] 
                                    target:self 
                                    selector:@selector(tap_facebook)];
        
        menu_facebook = [CCMenu menuWithItems:btn_facebook, nil];
        [menu_facebook alignItemsHorizontallyWithPadding:20];
        menu_facebook.position = ccp ( 85, 10 );
        menu_facebook.visible = TRUE;
        [self addChild:menu_facebook z:100];*/
    
        CCLOG(@"ADDING IN ALL THE LAYERS");
        detail = [LevelDetailLayer node];
        
        [self addChild:scroller];
        [scroller selectPage:user.cache_current_world-1];
        
        [self addChild:storemenu];
        [self addChild:detail];
    }
	return self;    
}

- (void) tap_store:(id)sender
{
    CCLOG(@"TAPPED STORE");
    [[CCDirector sharedDirector] replaceScene:[ShopScene scene]];    
}

- (void) tap_level:(CCMenuItem*)sender
{
    CCLOG(@"TAPPED LEVEL: %i - %i",sender.tag, user );
    user.cache_current_world  = (int)sender.userData;
    [user sync_cache_current_world];

    [detail setupDetailsForWorld:(int)sender.userData level:sender.tag withUserData:user];
}

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

- (void) tap_facebook
{   
    if ( user.isOnline )
    {
        NSArray *permissions = [NSArray arrayWithObjects:@"email", nil];
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

#pragma mark GameKit delegate

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