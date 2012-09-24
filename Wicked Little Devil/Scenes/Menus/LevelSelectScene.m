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
        float menu_y            = 270;
        int world_score_total   = [user getHighscoreforWorld:world];
        int world_souls_total   = 0;
        
        CCMenu  *menu     = [CCMenu menuWithItems:nil];
        
        // Background
        CCSprite *bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"bg_%i.png", world]];
        bg.position = ccp(screenSize.width/2, screenSize.height/2 );
        [self addChild:bg];
        
        // Collectable Button
//        CCLabelTTF *collected = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"COLLECTED: %i",user.collected] dimensions:CGSizeMake(480, 100) hAlignment:UITextAlignmentLeft fontName:font fontSize:fontsize]; 
//        collected.position = ccp ( 20, screenSize.height - 20 );
//        [self addChild:collected];

        for (int lvl = 1; lvl <= LEVELS_PER_WORLD; lvl++)
        {
            CCMenuItemImage *button = [CCMenuItemImage
                                       itemWithNormalImage:@"level.png"
                                       selectedImage:@"level.png"
                                       disabledImage:@"level-locked.png"
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
                int souls = [user getSoulsforWorld:world level:lvl];
                world_souls_total += souls;
                
                int soul_x = 13;
                for (int s = 1; s <= souls; s++ )
                {
                    CCSprite *soul = [CCSprite spriteWithFile:@"item-bigcollectable.png"];
                    soul.scale *= 0.40;
                    soul.position = ccp(button.position.x + soul_x, button.position.y - 7);
                    [button addChild:soul];
                    soul_x += 14;
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
        menu.position = ccp(menu_x, menu_y);
        [self addChild:menu];
                    
        CCSprite *icon_bigcollectable = [CCSprite spriteWithFile:@"icon-bigcollectable-med.png"];
        icon_bigcollectable.position = ccp (screenSize.width - 20, screenSize.height - 20);
        [self addChild:icon_bigcollectable z:100];
        
        CCLabelTTF *world_collected = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d/%d",world_souls_total,LEVELS_PER_WORLD*3] dimensions:CGSizeMake(screenSize.width - 75, 30) hAlignment:kCCTextAlignmentRight fontName:font fontSize:32];
        world_collected.position = ccp ( screenSize.width/2, screenSize.height - 22);
        [self addChild:world_collected z:100];
        
        CCLabelTTF *world_score = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %d",world_score_total] dimensions:CGSizeMake(screenSize.width - 20, 25) hAlignment:kCCTextAlignmentRight fontName:font fontSize:32];
        world_score.position = ccp ( screenSize.width/2, 22 );
        [self addChild:world_score];
        
        // Back Button
        CCMenu *menu_back = [CCMenu menuWithItems:nil];
        CCMenuItem *btn_back = [CCMenuItemImage
                                itemWithNormalImage:@"btn-back.png"
                                selectedImage:@"btn-back.png"
                                disabledImage:@"btn-back.png"
                                target:self
                                selector:@selector(tap_back:)];
        [menu_back setPosition:ccp(25, 25)];
        [menu_back addChild:btn_back];
        [self addChild:menu_back];
        
        CCMenu *menu_store = [CCMenu menuWithItems:nil];
        CCMenuItem *btn_store = [CCMenuItemImage
                                 itemWithNormalImage:@"btn-powerup.png"
                                 selectedImage:@"btn-powerup.png"
                                 disabledImage:@"btn-powerup.png"
                                 target:self
                                 selector:@selector(tap_store:)];
        [menu_store setPosition:ccp(25, screenSize.height - 25)];
        [menu_store addChild:btn_store];
        [self addChild:menu_store];
    }
    return self;
}

#pragma mark Taps

- (void) tap_level:(CCMenuItem*)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameScene sceneWithWorld:(int)sender.userData andLevel:sender.tag isRestart:FALSE]]];
}

- (void) tap_back:(CCMenuItem*)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[WorldSelectScene scene]]];
}

- (void) tap_store:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[ShopScene scene]]];
}

@end