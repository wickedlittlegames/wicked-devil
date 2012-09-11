//
//  LevelSelectScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "LevelSelectScene.h"
#import "WorldSelectScene.h"

@implementation LevelSelectScene

+(CCScene *) sceneWithWorld:(int)world
{
    // Create a Scene
	CCScene *scene = [CCScene node];
	LevelSelectScene *current = [[LevelSelectScene alloc] initWithWorld:world];
    
    // Fill the scene
	[scene addChild:current];
    
    // Show the scene
	return scene;
}

- (id) initWithWorld:(int)world
{
    if( (self=[super init]) ) 
    {
        user = [[User alloc] init];
        CCLOG(@"USER STATS:%@",user.udata);
        
        CCLOG(@"WORLD: %i",world);
        
        CGSize screenSize       = [CCDirector sharedDirector].winSize;
        NSString *font          = @"CrashLanding BB";
        NSNumber *itemsPerRow   = [NSNumber numberWithInt:4];
        int fontsize            = 36;
        float menu_x            = (screenSize.width/2);
        float menu_y            = 275;
        int world_score_total   = [user getHighscoreforWorld:world];
        int world_souls_total   = 0;
        
        CCMenu  *menu     = [CCMenu menuWithItems:nil];
        
        // Background
        CCSprite *bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"bg_%i.png", world]];
        bg.position = ccp(screenSize.width/2, screenSize.height/2 );
        [self addChild:bg];
        
        // Back Button
        CCMenuItem *button_back = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"BACK" fontName:font fontSize:fontsize] target:self selector:@selector(tap_back:)];
        CCMenu *menu_back = [CCMenu menuWithItems:button_back, nil];
        menu_back.position = ccp ( 20, screenSize.height - 20 );
        [self addChild:menu_back];
        
        // Collectable Button
        CCLabelTTF *collected = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"COLLECTED: %i",user.collected] dimensions:CGSizeMake(480, 100) hAlignment:UITextAlignmentLeft fontName:font fontSize:fontsize]; 
        collected.position = ccp ( 20 , 20 );        
        [self addChild:collected];

        for (int lvl = 1; lvl <= LEVELS_PER_WORLD; lvl++)
        {
            CCMenuItemImage *button = [CCMenuItemImage
                                       itemWithNormalImage:[NSString stringWithFormat:@"level.png",lvl]
                                       selectedImage:[NSString stringWithFormat:@"level.png",lvl] 
                                       disabledImage:[NSString stringWithFormat:@"level-locked.png",lvl] 
                                       target:self 
                                       selector:@selector(tap_level:)];
            button.tag = lvl;
            button.userData = (int*)world;
            button.isEnabled = FALSE;
            
            if ( world == 1 )
            {
                button.isEnabled = TRUE;
                if ( user.worldprogress > 1 )
                {
                    button.isEnabled = TRUE;
                }
                else 
                {
                    button.isEnabled = ( user.levelprogress >= lvl );
                }
            }
            
            if ( user.worldprogress > world )
            {
                button.isEnabled = TRUE;
            }
            else if ( user.worldprogress < world )
            {
                button.isEnabled = FALSE;
            }
            else if ( user.worldprogress == world )
            {
                button.isEnabled = ( user.levelprogress >= lvl );
            }
            
            if ( button.isEnabled )
            {
                //  int souls = [user getSoulsforWorld:world level:lvl];
                //  world_souls_total += souls;
                //                
                //  CCLabelTTF *lbl_level_souls = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",souls] fontName:font fontSize:16];
                //  lbl_level_souls.color = ccc3(0,0,0);
                //  lbl_level_souls.position = ccp (lbl_level_souls.position.x + 50, lbl_level_souls.position.y + 10);
                //  //[btn_level addChild:lbl_level_souls];                    
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
        
        [menu alignItemsInColumns:itemsPerRow, itemsPerRow, itemsPerRow,nil];
        menu.position = ccp(menu_x, menu_y);
        [self addChild:menu];
            
        CCLabelTTF *world_score = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"World: %d",world_score_total] fontName:font fontSize:32];
        world_score.position = ccp (90, 390);
        [self addChild:world_score];
        
        CCLabelTTF *world_stars = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d / %d",world_souls_total,LEVELS_PER_WORLD*3] fontName:font fontSize:32];
        world_stars.position = ccp ( screenSize.width - 80, 390);
        [self addChild:world_stars];
    }
    return self;
}

#pragma mark Taps

- (void) tap_level:(CCMenuItem*)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeTR transitionWithDuration:1 scene:[GameScene sceneWithWorld:(int)sender.userData andLevel:sender.tag isRestart:FALSE]]];
}

- (void) tap_back:(CCMenuItem*)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[WorldSelectScene scene]]];
}

#pragma mark FACEBOOK STUFF - NEEDS MOVING

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

@end