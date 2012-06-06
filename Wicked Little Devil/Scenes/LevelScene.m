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
@synthesize started;

#pragma mark === Initialization ===

- (id) init
{
	if( (self=[super init]) ) {
        
        user = [[User alloc] init];
        
        self.started = TRUE;
        
        player = [Player spriteWithFile:@"devil.png"];
        touchLocation.x = player.position.x;
        [self addChild:player];
        
    }
	return self;
}

+(CCScene *) sceneWithWorldNum:(int)worldNum LevelNum:(int)levelNum
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
    UILayer *ui = [UILayer node];
    LevelScene *current = (LevelScene*)[CCBReader 
                                        nodeGraphFromFile:[NSString stringWithFormat:@"world-%d-level-%d.ccbi",worldNum,levelNum]
                                        owner:NULL]; // level example name: world-1-level-2.ccbi
    
    // Build up a collection of arrays of the objects
    [current createWorldWithObjects:[current children]];
    
    // Add layers to the scene
    [scene addChild:ui z:100];
    [scene addChild:current];

	return scene;
}

- (void) createWorldWithObjects:(CCArray*)gameObjects
{
    platforms       = [NSMutableArray arrayWithCapacity:100];
    collectables    = [NSMutableArray arrayWithCapacity:100];
    bigcollectables = [NSMutableArray arrayWithCapacity:3];
    enemies         = [NSMutableArray arrayWithCapacity:100];
    
    for (CCNode* node in gameObjects)
    {
        if ([node isKindOfClass: [Platform class]])
        {
            [platforms addObject:node];
        }
        if ([node isKindOfClass: [Collectable class]])
        {
            [collectables addObject:node];
        }
        if ([node isKindOfClass: [BigCollectable class]])
        {
            [bigcollectables addObject:node];
        }
        if ([node isKindOfClass: [Enemy class]])
        {
            node.tag = 0;
            [enemies addObject:node];
        }        
    }

    [self schedule:@selector(update:)];
}

#pragma mark === Game Loop ===


- (void)update:(ccTime)dt 
{
    if ( ![[CCDirector sharedDirector] isPaused] && self.started == TRUE )
    {
        if (player.isAlive)
        {   
            levelThreshold = 370 - player.position.y;
        
            if ( levelThreshold < 0 )
            {
                background.position = ccp(background.position.x, background.position.y + levelThreshold/40);
                floor.position = ccp(floor.position.x, floor.position.y + levelThreshold);
            }
            
            for (Platform *platform in platforms)
            {                
                if ( [platform isIntersectingPlayer:player] ) 
                {
                    [player jump];
                }

                [platform movementWithThreshold:levelThreshold];
                [platform offScreenCleanup];
            }
            
            for (Collectable *collectable in collectables)
            {
                if ( [collectable isIntersectingPlayer:player] ) 
                {
                    player.collected++;
                }
                [collectable movementWithThreshold:levelThreshold];
            }
            
            for (BigCollectable *bigcollectable in bigcollectables)
            {
                if ( [bigcollectable isIntersectingPlayer:player] )
                {
                    player.bigcollected++;
                }
                [bigcollectable movementWithThreshold:levelThreshold];                
            }
            
            for (Enemy *enemy in enemies)
            {
                if ( enemy.isAlive )
                {
                    //[enemy activateNearPlayerPoint:player];
                    [enemy isIntersectingPlayer:player];
                    [enemy movementWithThreshold:levelThreshold];                    
                }
            }
            
            [self playerMovementChecks];
            [player movement:levelThreshold withGravity:0.200];
        }
        else 
        {
            NSLog(@"Dead");
        }
    }
}

#pragma mark === Touch and Movement ===

- (void) playerMovementChecks
{
    float diff = touchLocation.x - player.position.x;
    if (diff > 4)  diff = 4;
    if (diff < -4) diff = -4;
    CGPoint new_player_location = CGPointMake(player.position.x + diff, player.position.y);
    player.position = new_player_location;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for( UITouch *touch in touches ) {
        CGPoint location = [touch locationInView: [touch view]];
        touchLocation = location;
    }
}

- (void)launch:(id)sender
{
    player.velocity = ccp ( player.velocity.x, -18.5 );
    menu.visible = NO;
    started = TRUE;
}

@end