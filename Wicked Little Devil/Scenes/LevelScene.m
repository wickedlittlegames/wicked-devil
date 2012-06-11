//
//  LevelScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "UILayer.h"
#import "LevelSelectScene.h"
#import "LevelScene.h"

@implementation LevelScene
@synthesize started, player, worldNumber, levelNumber, touchLocation;

#pragma mark === Initialization ===

- (id) init
{
	if( (self=[super init]) ) {
        
        user = [[User alloc] init];
        
        self.started = FALSE;
                
        floor = [CCSprite spriteWithFile:@"floor.png"];
        floor.position = ccp ( 320 / 2, 80 );
        [self addChild:floor];
        
        CCMenuItem *launchButton = [CCMenuItemImage itemWithNormalImage:@"Start-button.png" selectedImage:@"Start-button.png" target:self selector:@selector(launch:)];
        menu = [CCMenu menuWithItems:launchButton, nil];
        menu.position = ccp ( 320/2, 30 );
        [self addChild:menu];
        
        player = [Player spriteWithFile:@"devil.png"];
        player.position = ccp( 320/2 , 110 );
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
    UILayer *ui                 = [UILayer node];
    CCLayer  *world             = [CCLayer node];
    LevelScene *objectLayer     = (LevelScene*)[CCBReader 
                                        nodeGraphFromFile:[NSString stringWithFormat:@"world-%d-level-%d.ccbi",worldNum,levelNum]
                                        owner:NULL];
    
    // Add objects and players to world
    [world addChild:objectLayer];

    // Build up a collection of arrays of the objects
    [objectLayer createWorldWithObjects:[objectLayer children]];
    
    // Capture the player for the main layer
    [objectLayer setWorldNumber:worldNum];
    [objectLayer setLevelNumber:levelNum];
    
    // Add layers to the scene
    [scene addChild:ui z:100];
    [scene addChild:world z:50];

	return scene;
}

- (void) createWorldWithObjects:(CCArray*)gameObjects
{
    platforms       = [NSMutableArray arrayWithCapacity:100];
    collectables    = [NSMutableArray arrayWithCapacity:100];
    bigcollectables = [NSMutableArray arrayWithCapacity:3];
    enemies         = [NSMutableArray arrayWithCapacity:100];
    triggers        = [NSMutableArray arrayWithCapacity:100];
    
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
            [enemies addObject:node];
        }
        if ([node isKindOfClass: [Trigger class]])
        {
            [triggers addObject:node];
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
            levelThreshold = 340 - player.position.y;
            
            if ( levelThreshold < 0 && floor.visible == TRUE )
            {
                floor.position = ccp(floor.position.x, floor.position.y + levelThreshold);
                floor.visible = (floor.position.y < -300 ? FALSE : TRUE);
            }

            for (Platform *platform in platforms)
            {       
                if ( [platform isIntersectingPlayer:player] ) 
                {
                    [self.player jump];
                }
                
                [platform movementWithThreshold:levelThreshold];
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
            
            for (Trigger *trigger in triggers)
            {
                // TODO - TRIGGER TYPE
                switch (trigger.tag)
                {
                    case 0:
                        // Platform toggle
                        
                        break;
                    case 10:
                        // This is the end of level trigger!
                        if ( CGRectIntersectsRect(player.boundingBox, trigger.boundingBox ) )
                        {
                            [self gameover];
                        }
                        break;
                }
                
                [trigger movementWithThreshold:levelThreshold];
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

- (void) gameover
{
    self.started = FALSE;
    [self unschedule:@selector(update:)];
    
    user.collected += player.collected;
    if (self.levelNumber == user.levelprogress)
    {
        user.levelprogress = (player.bigcollected > 0 ? user.levelprogress++ : user.levelprogress);
        if (user.levelprogress > 9)
        {
            user.worldprogress++;
            user.levelprogress = 1;
        }
    }
    [user syncData];
    
    CCLayer *gameover = [CCLayer node];
    CCMenuItem *restartButton = [CCMenuItemImage itemWithNormalImage:@"Icon.png" selectedImage:@"Icon.png" target:self selector:@selector(restartButtonTapped:)];
    CCMenuItem *nextLevelButton = [CCMenuItemImage itemWithNormalImage:@"Icon.png" selectedImage:@"Icon.png" target:self selector:@selector(nextLevelButtonTapped:)];
    CCMenuItem *backtoMenuButton = [CCMenuItemImage itemWithNormalImage:@"Icon.png" selectedImage:@"Icon.png" target:self selector:@selector(backToMenuButtonTapped:)];
    
    nextLevelButton.isEnabled = (player.bigcollected > 0 ? TRUE : FALSE);
    
    CCMenu *gameovermenu = [CCMenu menuWithItems:restartButton,nextLevelButton,backtoMenuButton,nil]; 
    gameovermenu.position = ccp ( 120, 300 );
    [gameover addChild:gameovermenu];
    
    [self addChild:gameover];
}


#pragma mark === Touch and Movement ===

- (void) playerMovementChecks
{
    float diff = self.touchLocation.x - player.position.x;
    if (diff > 4)  diff = 4;
    if (diff < -4) diff = -4;
    CGPoint new_player_location = CGPointMake(player.position.x + diff, player.position.y);
    player.position = new_player_location;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for( UITouch *touch in touches ) {
        CGPoint location = [touch locationInView: [touch view]];
        self.touchLocation = location;
    }
}

- (void)launch:(id)sender
{
    player.velocity = ccp ( player.velocity.x, 30.5 );
    menu.visible = NO;
    self.started = TRUE;
}

- (void) restartButtonTapped:(id)sender 
{
    [self clearReadyForOrders];
    [[CCDirector sharedDirector] pushScene:[LevelScene sceneWithWorldNum:self.worldNumber LevelNum:self.levelNumber]];
}

- (void) nextLevelButtonTapped:(id)sender 
{
    [self clearReadyForOrders];
    [[CCDirector sharedDirector] pushScene:[LevelScene sceneWithWorldNum:self.worldNumber LevelNum:(++self.levelNumber)]];
}

- (void) backtoMenuButtonTapped:(id)sender 
{
    [self clearReadyForOrders];
    [[CCDirector sharedDirector] pushScene:[LevelSelectScene scene]];
}

- (void) clearReadyForOrders
{
    [self removeAllChildrenWithCleanup:YES];
}

@end