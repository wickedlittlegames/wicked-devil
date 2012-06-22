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
        // Get the user
        user = [[User alloc] init];
        CCLOG(@"Highscores: %@",user.highscores);
        CCLOG(@"Souls: %@",user.souls);
        CCLOG(@"World Progress: %i",user.worldprogress);
        CCLOG(@"Level Progress: %i",user.levelprogress);
        CCLOG(@"Collected: %i", user.collected);
        CCLOG(@"Powerup: %@",user.powerup);
        
        // Screen Size
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        NSNumber* itemsPerRow = [NSNumber numberWithInt:3];
        float menu_x = (screenSize.width/2);
        float menu_y = 275;
        
        NSMutableArray *worlds = [NSMutableArray arrayWithCapacity:WORLDS_PER_GAME];
        
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
                level.userData = (int*)w;
                level.tag      = lvl;
                if ( user.worldprogress >= w )
                {
                    level.isEnabled = ( user.levelprogress >= lvl ? TRUE : FALSE );
                }
                else 
                {
                    level.isEnabled = FALSE;
                }
                if ( level.isEnabled )
                {
                    int world_souls = [user getSoulsForWorld:w andLevel:lvl];
                    world_souls_total += world_souls;
                    NSString *str_level_souls = [NSString stringWithFormat:@"%d",world_souls];
                    CCLabelTTF *lbl_level_souls = [CCLabelTTF labelWithString:str_level_souls fontName:@"Marker Felt" fontSize:16];
                    [level addChild:lbl_level_souls];
                    lbl_level_souls.color = ccc3(0,0,0);
                    lbl_level_souls.position = ccp (lbl_level_souls.position.x + 50, lbl_level_souls.position.y + 10);
                }
                
                NSString *str_level_name = [NSString stringWithFormat:@"%i - %i",w,lvl];
                CCLabelTTF *lbl_level_name = [CCLabelTTF labelWithString:str_level_name fontName:@"Marker Felt" fontSize:12];
                [level addChild:lbl_level_name];
                lbl_level_name.position = ccp (lbl_level_name.position.x + 27, lbl_level_name.position.y - 12);
                
                [world_menu addChild:level];
            }
            
            [world_menu alignItemsInColumns:itemsPerRow, itemsPerRow, itemsPerRow,nil];
            if ( w == 1 )
            {
                CCSprite *background = [CCSprite spriteWithFile:@"bg_hell.png"];
                background.position = ccp (screenSize.width/2, screenSize.height/2);
                [world addChild:background];
            }
            else if ( w == 2 )
            {
                CCSprite *background = [CCSprite spriteWithFile:@"bg_underground.png"];
                background.position = ccp (screenSize.width/2, screenSize.height/2);
                [world addChild:background];
            }
            
            CCLabelTTF *world_score = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"World: %d",world_score_total] fontName:@"Marker Felt" fontSize:14];
            world_score.position = ccp (90, 390);
            [world addChild:world_score];            
            
            CCLabelTTF *world_stars = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d / %d",world_souls_total,LEVELS_PER_WORLD*3] fontName:@"Marker Felt" fontSize:14];
            world_stars.position = ccp ( screenSize.width - 80, 390);
            [world addChild:world_stars];
            
            [world addChild:world_menu];
            [worlds addObject:world];
        }
        
        CCScrollLayer *scroller = [[CCScrollLayer alloc] initWithLayers:worlds widthOffset: 0];
        
        CCLayer *community = [CCLayer node];
        [scroller addPage:community];

        CCMenuItem *store = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"Store" fontName:@"Marker Felt" fontSize:18] target:self selector:@selector(tap_store:)];
        CCMenuItem *stats = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"Player" fontName:@"Marker Felt" fontSize:18] target:self selector:@selector(tap_stats:)];
        CCMenu *storemenu = [CCMenu menuWithItems:store,stats, nil];
        [storemenu alignItemsHorizontallyWithPadding:20];
        storemenu.position = ccp ( screenSize.width - 80, 10 );
        
        CCLabelTTF *lbl_user_collected = [CCLabelTTF labelWithString:@"Collected:" fontName:@"Marker Felt" fontSize:18];
        lbl_user_collected.position = ccp ( lbl_user_collected.contentSize.width, 10 );
        lbl_user_collected.string = [NSString stringWithFormat:@"Collected: %i",user.collected];
        [self addChild:lbl_user_collected];
        
        detail = [LevelDetailLayer node];
        
        [self addChild:scroller];
        [self addChild:storemenu];
        [self addChild:detail];
    }
	return self;    
}

- (void) tap_store:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[ShopScene scene]];
}
- (void) tap_stats:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[PlayerStatsScene scene]];
}
- (void) tap_level:(CCMenuItem*)sender
{
    [detail setupDetailsForWorld:(int)sender.userData level:sender.tag withUserData:user];
}

@end