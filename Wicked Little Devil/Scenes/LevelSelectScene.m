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
        
        // World & level array
        int world_count = 6;
        int levels_per_world = 9;
        
        NSMutableArray *worlds = [NSMutableArray arrayWithCapacity:world_count];
        
        for (int w = 1; w <= world_count; w++)
        {
            CCLayer *world = [CCLayer node];
            CCMenu *world_menu = [CCMenu menuWithItems:nil];
            world_menu.position = ccp ( menu_x, menu_y );
            
            for (int lvl = 1; lvl <= levels_per_world; lvl++)
            {
                CCMenuItem *level = [CCMenuItemImage 
                                           itemWithNormalImage:[NSString stringWithFormat:@"Icon.png",lvl]
                                           selectedImage:[NSString stringWithFormat:@"Icon.png",lvl] 
                                           disabledImage:[NSString stringWithFormat:@"Icon.png",lvl] 
                                           target:self 
                                           selector:@selector(levelButtonTapped:)];
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
                
                [world_menu addChild:level];
            }
            
            [world_menu alignItemsInRows:itemsPerRow, itemsPerRow, itemsPerRow,nil];
            [world addChild:world_menu];
            [worlds addObject:world];
        }
        
        CCScrollLayer *scroller = [[CCScrollLayer alloc] initWithLayers:worlds widthOffset: 0];
        
        CCLayer *community = [CCLayer node];
        [scroller addPage:community];

        CCMenuItem *storeButton = [CCMenuItemImage itemWithNormalImage:@"Icon-Small.png" selectedImage:@"Icon-Small.png" target:self selector:@selector(storeButtonTapped:)];
        CCMenu *storemenu = [CCMenu menuWithItems:storeButton, nil];
        storemenu.position = ccp ( 120, 400 );
        
        [self addChild:scroller];
        [self addChild:storemenu];
        
    }
	return self;    
}


- (void)storeButtonTapped:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[ShopScene scene]];
}

- (void)levelButtonTapped:(CCMenuItem*)sender {
    [[CCDirector sharedDirector] replaceScene:[LevelScene sceneWithWorldNum:(int)sender.userData LevelNum:sender.tag]];
}

@end
