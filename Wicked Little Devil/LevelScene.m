//
//  LevelScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "UILayer.h"
#import "LevelScene.h"


@implementation LevelScene
@synthesize world, gravity, level;

+(CCScene *) sceneWithLevelNum:(int)levelNum
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
    UILayer *ui = [UILayer node];
	LevelScene *current = [LevelScene node];
    
    // UI options (label example of ads)
    ui.label.visible = NO;
    
    // Fill the scene
    [scene addChild:ui z:100];
	[scene addChild:[current initWithLevelNum:1] z:10];
    
    // Show the scene
	return scene;
}

- (id)initWithLevelNum:(int)levelNum
{
	if( (self=[super init]) ) {      
        // Get level data
        //NSString *level_data_file = [NSString stringWithFormat:@"level_%@.plist",levelNum];
        //[self buildWorld:[NSDictionary dictionaryWithContentsOfFile:level_data_file]];
        self.gravity = 0.225;
        
        // Load Background
        background = [CCLayer node];
        CCSprite *bg_image = [CCSprite spriteWithFile:@"bg0.png"];
        bg_image.position = ccp ( (320/2), (480/2) );
        [background addChild:bg_image];
        [self addChild:background z:-1];
        
        // Load floor
        floor = [Platform spriteWithFile:@"Default.png"];
        floor.position = ccp ( 160, -200 );
        [self addChild:floor];
        
        // Load platforms array
        platforms = [NSMutableArray arrayWithCapacity:100];
        
        // Load platform
        for (int i = 0; i < 10; i++) {
            Platform *platform = [Platform spriteWithFile:@"Icon-Small-50.png"];
            platform.position = ccp ( 150, ( 100 + (i*10)));
            [self addChild:platform];
            [platforms addObject:platform];            
        }
        
        // Instanciate Player
        player = [Player spriteWithFile:@"Icon.png"];
        player.position = ccp(150,300);        
        [self addChild:player];
        
        // Start Game loop
        [self schedule:@selector(update:)];
    }
	return self;
}

- (void) buildWorld:(NSDictionary*)levelData
{
    // Load in the level helper file and maninpualte crazy  
    self.world      = [levelData valueForKey:@"world"];
    self.gravity    = [[levelData valueForKey:@"gravity"] floatValue];
}

- (void)update:(ccTime)dt 
{
    if ( ![[CCDirector sharedDirector] isPaused] )
    {
        if (player.isAlive)
        {   
            // Stop the player from going up too high
            levelThreshold = 300 - player.position.y;
            
            // Move background down
            if ( levelThreshold <= 0 )
            {
                background.position = ccp(background.position.x, background.position.y + levelThreshold/10);
            }
            
            // Platform Stuff
            for (Platform *platform in platforms)
            {
                if ( [platform isIntersectingPlayer:player] )
                {
                    player.velocity = ccp ( player.velocity.x, player.velocity.y - (player.velocity.y *3) );
                }
                
                [platform movementWithThreshold:levelThreshold];
            }
            
            // Finally move the player down
            player.velocity = ccp( player.velocity.x, player.velocity.y - gravity );
            if (levelThreshold <= 0) 
            {
                player.position = ccp(player.position.x + player.velocity.x, player.position.y + player.velocity.y + levelThreshold);
            }
            else 
            {
                player.position = ccp(player.position.x + player.velocity.x, player.position.y + player.velocity.y);
            }
        }
        else 
        {
            NSLog(@"Dead");
        }
    }
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event 
{
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event 
{
    CGPoint location = [touch locationInView: [touch view]];
    touchLocation = location; 
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event 
{

}
@end