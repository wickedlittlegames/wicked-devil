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
        float menu_x = (screenSize.width/2) - 23;
        float menu_y = 275;
        
        // Set up page layers for scroller
        CCLayer *world_1 = [CCLayer node];
        CCLayer *world_2 = [CCLayer node];
        CCLayer *community = [CCLayer node];
        
        int world_1_levels = 10;
        int world_2_levels = 10;
        NSNumber* itemsPerRow = [NSNumber numberWithInt:3];
        
        CCMenu *world_1_menu = [CCMenu menuWithItems:nil];
        CCMenu *world_2_menu = [CCMenu menuWithItems:nil];

        world_1_menu.position = ccp ( menu_x, menu_y );
        world_2_menu.position = ccp ( menu_x, menu_y );
        
        for (int i = 1; i < world_1_levels; i++)
        {
            CCMenuItem *world_level = [CCMenuItemImage 
                                      itemWithNormalImage:[NSString stringWithFormat:@"Icon.png",i]
                                      selectedImage:[NSString stringWithFormat:@"Icon.png",i] 
                                      disabledImage:[NSString stringWithFormat:@"Icon-locked.png",i] 
                                      target:self 
                                      selector:@selector(levelButtonTapped:)];
            world_level.isEnabled = ( user.levelprogress >= i ? TRUE : FALSE );
            [world_1_menu addChild:world_level];
        }
        for (int i = 1; i < world_2_levels; i++)
        {
            CCMenuItem *world_level = [CCMenuItemImage 
                                       itemWithNormalImage:[NSString stringWithFormat:@"Icon.png",i]
                                       selectedImage:[NSString stringWithFormat:@"Icon.png",i] 
                                       disabledImage:[NSString stringWithFormat:@"Icon-locked.png",i] 
                                       target:self 
                                       selector:@selector(levelButtonTapped:)];
            world_level.isEnabled = ( user.worldprogress >= 2  ? TRUE : FALSE );
            world_level.isEnabled = ( user.levelprogress >= (i+10) ? TRUE : FALSE );
            [world_2_menu addChild:world_level];
        }
        
        [world_1_menu alignItemsInRows:itemsPerRow, itemsPerRow, itemsPerRow,nil];
        [world_2_menu alignItemsInRows:itemsPerRow, itemsPerRow, itemsPerRow,nil];
        [world_1 addChild:world_1_menu];
        [world_2 addChild:world_2_menu];
        
        CCSprite *bg1 = [CCSprite spriteWithFile:@"bg0.png"];
        bg1.position = ccp( screenSize.width/2, screenSize.height/2 );
        //[world_1 addChild:bg1 z:-1];
        
        CCSprite *bg2 = [CCSprite spriteWithFile:@"bg4.png"];
        bg2.position = ccp( screenSize.width/2, screenSize.height/2 );
        //[world_2 addChild:bg2 z:-1];
        
        CCScrollLayer *scroller = [[CCScrollLayer alloc] initWithLayers:[NSMutableArray arrayWithObjects: world_1, world_2, community,nil] widthOffset: 0];

        [self addChild:scroller];

    }
	return self;    
}

- (void)levelButtonTapped:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[LevelScene sceneWithLevelNum:1]];
}

@end
