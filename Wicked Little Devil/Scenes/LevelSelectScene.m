//
//  LevelSelectScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "LevelSelectScene.h"
#import "LevelScene.h"

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
            int world_score_total = [user getScoreForWorldOnly:w];
            
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
                level.isEnabled = ( user.worldprogress >= w && user.levelprogress >= lvl ? TRUE : FALSE );
                
                if ( level.isEnabled )
                {
                    int souls = [user getSoulsForWorld:w andLevel:lvl];
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

            CCMenuItem *unlock = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"UNLOCK" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_unlock:)];
            CCMenu *unlockmenu = [CCMenu menuWithItems:unlock, nil];
            unlock.tag = w;            
            unlockmenu.position = ccp ( screenSize.width/2, 420 );
            //unlockmenu.visible = ( user.worldprogress >= w ? FALSE : TRUE );
            switch (w)
            {
                case 1:
                    unlockmenu.visible = ( user.unlocked_world_1 ? FALSE : TRUE );
                    break;
                case 2:
                    unlockmenu.visible = ( user.unlocked_world_2 ? FALSE : TRUE );
                    break;
                case 3:
                    unlockmenu.visible = ( user.unlocked_world_3 ? FALSE : TRUE );
                    break;
                case 4:
                    unlockmenu.visible = ( user.unlocked_world_4 ? FALSE : TRUE );
                    break;
                case 5:
                    unlockmenu.visible = ( user.unlocked_world_5 ? FALSE : TRUE );
                    break;
                case 6:
                    unlockmenu.visible = ( user.unlocked_world_6 ? FALSE : TRUE );
                    break;
            }
            [world addChild:unlockmenu];
            
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
        CCMenuItem *stats = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"Player" fontName:@"Marker Felt" fontSize:18] target:self selector:@selector(tap_stats:)];
        CCMenu *storemenu = [CCMenu menuWithItems:store,stats, nil];
        [storemenu alignItemsHorizontallyWithPadding:20];
        storemenu.position = ccp ( screenSize.width - 80, 10 );
        
        CCLOG(@"SETTING THE BUTTON/LABEL FOR FACEBOOK LOGIN");
        lbl_user_collected = [CCLabelTTF labelWithString:@"Collected:" fontName:@"Marker Felt" fontSize:18];
        lbl_user_collected.position = ccp ( lbl_user_collected.contentSize.width, 10 );
        lbl_user_collected.string = [NSString stringWithFormat:@"Collected: %i",user.collected];
        if ( !user.isConnectedToInternet ) lbl_user_collected.string = @"Collected: Offline";
        lbl_user_collected.visible = user.fbloggedin;
        [self addChild:lbl_user_collected z:100];
        
        CCMenuItem *facebook = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"Sign In With Facebook" fontName:@"Marker Felt" fontSize:18] target:self selector:@selector(tap_facebook)];
        facebookmenu = [CCMenu menuWithItems:facebook, nil];
        [facebookmenu alignItemsHorizontallyWithPadding:20];
        facebookmenu.position = ccp ( 85, 10 );
        facebookmenu.visible = !user.fbloggedin;
        [self addChild:facebookmenu z:100];
    
        CCLOG(@"ADDING IN ALL THE LAYERS");
        detail = [LevelDetailLayer node];
        [self addChild:scroller];
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

- (void) tap_facebook
{   
    CCLOG(@"TAPPED LOGIN FACEBOOK");
    NSArray *permissionsArray = [NSArray arrayWithObjects:@"user_about_me",
                                 @"user_birthday",@"user_location",
                                 @"offline_access", nil];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *pfuser, NSError *error) 
    {
        if (!pfuser) 
        {
            CCLOG(@"ERROR: %@",error);
        } 
        else if (pfuser.isNew) 
        {
            [[PFFacebookUtils facebook] requestWithGraphPath:@"me?fields=id,name" andDelegate:self];
            lbl_user_collected.string = [NSString stringWithFormat:@"Collected: %i",user.collected];                        
            
            facebookmenu.visible = FALSE;
            lbl_user_collected.visible = TRUE;
            
            CCLOG(@"USER IS NEW, CREATE ALL THE STUFF");
            CCLOG(@"USER IS NEW, STUFF CREATED");
            [user.udata setBool:TRUE forKey:@"fbloggedin"];            
            user.fbloggedin = TRUE;            
            [user.udata synchronize];
        } 
        else 
        {
            [[PFUser currentUser] refresh];
            PFQuery *query = [PFUser query];
            PFObject *result = [query getObjectWithId:[PFUser currentUser].objectId];
            lbl_user_collected.string = [NSString stringWithFormat:@"Collected: %i",[[result objectForKey:@"collected"] intValue]];
            [[PFUser currentUser] incrementKey:@"RunCount"];
            [[PFUser currentUser] saveInBackground];
            
            facebookmenu.visible = FALSE;
            lbl_user_collected.visible = TRUE;
            
            CCLOG(@"USER IS NOT NEW, JUST LOG IN");     
            [user.udata setBool:TRUE forKey:@"fbloggedin"];
            user.fbloggedin = TRUE;
            [user.udata synchronize];
        }
    }];
}

- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    CCLOG(@"CREATING USER CUSTOM PARAMS | fbID, fbName");    
    [[PFUser currentUser] setObject:[result objectForKey:@"id"] forKey:@"fbId"];
    [[PFUser currentUser] setObject:[result objectForKey:@"name"] forKey:@"fbName"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"collected"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:1] forKey:@"unlocked_world_1"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"unlocked_world_2"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"unlocked_world_3"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"unlocked_world_4"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"unlocked_world_5"];
    [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"unlocked_world_6"];
    [[PFUser currentUser] incrementKey:@"RunCount"];
    [[PFUser currentUser] saveInBackground];
}

-(void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error {
    // OAuthException means our session is invalid
    if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] 
         isEqualToString: @"OAuthException"]) {
        NSLog(@"The facebook token was invalidated");
        [PFUser logOut];
        [user.udata setBool:FALSE forKey:@"fbloggedin"];
        user.fbloggedin = FALSE;
    } else {
        NSLog(@"Some other error");
        [PFUser logOut];
        [user.udata setBool:FALSE forKey:@"fbloggedin"];        
        user.fbloggedin = FALSE;
    }
}

- (void) tap_stats:(id)sender
{
    CCLOG(@"TAPPED STATS");
    [[CCDirector sharedDirector] replaceScene:[PlayerStatsScene scene]];
}
- (void) tap_level:(CCMenuItem*)sender
{
    CCLOG(@"TAPPED LEVEL: %i - %i",sender.tag, user );
    [detail setupDetailsForWorld:(int)sender.userData level:sender.tag withUserData:user];
}
- (void) tap_unlock:(CCMenuItem*)sender
{
    [[CCDirector sharedDirector] replaceScene:[ShopScene scene]];
}

@end