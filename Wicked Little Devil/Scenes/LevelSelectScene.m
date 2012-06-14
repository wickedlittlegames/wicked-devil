//
//  LevelSelectScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//
#import "CCScrollLayer.h"
#import "UILayer.h"
#import "LevelScene.h"
#import "LevelSelectScene.h"
#import "ShopScene.h"

@implementation LevelSelectScene

+(CCScene *) scene
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
    UILayer *ui = [UILayer node];
	LevelSelectScene *current = [LevelSelectScene node];
    
    // Fill the scene
    [scene addChild:ui z:100];
	[scene addChild:current z:10];
    
    // Show the scene
	return scene;
}

-(id) init
{
	if( (self=[super init]) ) {
        // Get the user
        user = [[User alloc] init];
        
        // Screen Size
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        NSNumber* itemsPerRow = [NSNumber numberWithInt:3];
        float menu_x = (screenSize.width/2) - 23;
        float menu_y = 275;
        
        NSMutableArray *worlds = [NSMutableArray arrayWithCapacity:WORLDS_PER_GAME];
        
        for (int w = 1; w <= WORLDS_PER_GAME; w++)
        {
            CCLayer *world = [CCLayer node];
            CCMenu *world_menu = [CCMenu menuWithItems:nil];
            world_menu.position = ccp ( menu_x, menu_y );
            
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
                NSLog(@"World:%d, Level: %d ENABLED = %i",w,lvl,level.isEnabled);
                [world_menu addChild:level];
            }
            
            [world_menu alignItemsInColumns:itemsPerRow, itemsPerRow, itemsPerRow,nil];
            [world addChild:world_menu];
            [worlds addObject:world];
        }
        
        CCScrollLayer *scroller = [[CCScrollLayer alloc] initWithLayers:worlds widthOffset: 0];
        
        CCLayer *community = [CCLayer node];
        [scroller addPage:community];

        CCMenuItem *storeButton = [CCMenuItemImage itemWithNormalImage:@"Icon-Small.png" selectedImage:@"Icon-Small.png" target:self selector:@selector(tap_store:)];
        CCMenu *storemenu = [CCMenu menuWithItems:storeButton, nil];
        storemenu.position = ccp ( 120, 440 );
        
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

- (void) tap_level:(CCMenuItem*)sender
{
    NSLog(@"W:%d,L:%d",(int)sender.userData,sender.tag);
    //[detail setupDetailsForWorld:(int)sender.userData level:sender.tag withUserData:user];
    [[CCDirector sharedDirector] replaceScene:[LevelScene sceneWithWorldNum:(int)sender.userData LevelNum:sender.tag]];
}

@end