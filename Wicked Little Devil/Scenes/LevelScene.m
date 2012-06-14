//
//  LevelScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "LevelScene.h"

CCTexture2D *platform_toggle1, *platform_toggle2;

@implementation LevelScene
@synthesize started, player, worldNumber, levelNumber, touchLocation, levelTimer;

#pragma mark === Initialization ===

- (id) init
{
	if( (self=[super init]) ) {
        
        user = [[User alloc] init];
        
        platform_toggle1 = [[CCTextureCache sharedTextureCache] addImage:@"platform-toggle1.png"];
        platform_toggle2 = [[CCTextureCache sharedTextureCache] addImage:@"platform-toggle2.png"];        
        
        self.started = FALSE;
        self.levelTimer = 0;
                
        floor = [CCSprite spriteWithFile:@"floor.png"];
        floor.position = ccp ( 320 / 2, 80 );
        [self addChild:floor];
        
        CCMenuItem *launchButton = [CCMenuItemImage itemWithNormalImage:@"Start-button.png" selectedImage:@"Start-button.png" target:self selector:@selector(launch:)];
        menu = [CCMenu menuWithItems:launchButton, nil];
        menu.position = ccp ( 320/2, 30 );
        [self addChild:menu];

    }
	return self;
}

+(CCScene *) sceneWithWorldNum:(int)worldNum LevelNum:(int)levelNum
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
    CCLayer  *world             = [CCLayer node];
    CCLayer *playerlayer        = [CCLayer node];
    LevelScene *objectLayer     = (LevelScene*)[CCBReader 
                                        nodeGraphFromFile:[NSString stringWithFormat:@"world-%d-level-%d.ccbi",worldNum,levelNum]
                                        owner:NULL];
    
    Player *_player = [Player spriteWithFile:@"player.png"];
    _player.scale = _player.scale/2;
    _player.position = ccp( 320/2 , 110 );
    [playerlayer addChild:_player];
    
    // Add objects and players to world
    [world addChild:objectLayer];
    [objectLayer setPlayer:_player];
    [objectLayer setTouchLocation:_player.position];

    // Build up a collection of arrays of the objects
    [objectLayer createWorldWithObjects:[objectLayer children]];
    
    // Capture the player for the main layer
    [objectLayer setWorldNumber:worldNum];
    [objectLayer setLevelNumber:levelNum];
    
    // Add layers to the scene
    [scene addChild:world z:50];
    [scene addChild:playerlayer z:51];

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
            
            if ( levelThreshold < 0 )
            {
                self.position = ccp (self.position.x, self.position.y + levelThreshold);
            }
            
            if ( levelThreshold < 0 && floor.visible == TRUE )
            {
                floor.position = ccp(floor.position.x, floor.position.y + levelThreshold);
                floor.visible = (floor.position.y < -300 ? FALSE : TRUE);
            }

            for (Platform *platform in platforms)
            {       
                if ( platform.isAlive && platform.active )
                {
                    if ( [platform isIntersectingPlayer:player] ) 
                    {
                        switch (platform.tag)
                        {
                            // 0: Vertical Moving
                            // 1: Horizontal Moving
                            // 2: Big Jump
                            // 3: Breakable Platform
                            // 4: Toggle (1)
                            // 5: Toggle (2)
                                
                            case 0: 
                                [self.player jump:player.jumpspeed];
                                break;
                            case 1:
                                [self.player jump:player.jumpspeed];
                                break;                                
                            case 2:
                                [self.player jump:player.jumpspeed*2];
                                break; 
                            case 3:
                                [platform takeDamagefromPlayer:player];
                                [self.player jump:player.jumpspeed];
                                break;
                            case 4:
                                [self.player jump:player.jumpspeed];
                                platform.active = !platform.active;
                                [platform setTexture:platform_toggle2];
                                for (Platform *pf in platforms)
                                {
                                    if (pf.tag == 5)
                                    {
                                        pf.active = !platform.active;
                                        [pf setTexture:platform_toggle1];
                                    }
                                }
                                break;
                            case 5:
                                [self.player jump:player.jumpspeed];
                                platform.active = !platform.active;
                                [platform setTexture:platform_toggle2];
                                for (Platform *pf in platforms)
                                {
                                    if (pf.tag == 4)
                                    {
                                        pf.active = !platform.active;
                                        [pf setTexture:platform_toggle1];
                                    }
                                }
                                break;
                            default:
                                [self.player jump:player.jumpspeed];
                                break;
                        }
                    }
                    if (platform.tag == 0)
                    {
                        if ( platform.animating == FALSE )
                        {
                            id verticalmove = [CCMoveBy actionWithDuration:2 position:ccp(0,-100)];
                            id verticalmove_opposite = [CCMoveBy actionWithDuration:2 position:ccp(0,100)];
                            
                            CCAction *repeater = [CCRepeatForever actionWithAction:[CCSequence actions:verticalmove,verticalmove_opposite,nil]];
                            [platform runAction:repeater];
                            
                            platform.animating = TRUE;
                        }
                    }
                    if (platform.tag == 1)
                    {
                        if ( platform.animating == FALSE )
                        {
                            id horizontalmove = [CCMoveBy actionWithDuration:2 position:ccp(-100,0)];
                            id horizontalmove_opposite = [CCMoveBy actionWithDuration:2 position:ccp(100,0)];
                            
                            CCAction *repeater = [CCRepeatForever actionWithAction:[CCSequence actions:horizontalmove,horizontalmove_opposite,nil]];
                            [platform runAction:repeater];
                            
                            platform.animating = TRUE;
                        }
                    }

                }
            }
            
            for (Collectable *collectable in collectables)
            {
                if ( [collectable isIntersectingPlayer:player] ) 
                {
                    player.collected++;
                }
            }
            
            for (BigCollectable *bigcollectable in bigcollectables)
            {
                if ( [bigcollectable isIntersectingPlayer:player] )
                {
                    player.bigcollected++;
                }
            }
            
            for (Trigger *trigger in triggers)
            {
                if ( [trigger isIntersectingPlayer:player] )
                {
                    switch (trigger.tag)
                    {
                        case 0:
                            // Platform toggle
                            break;
                        case 10:
                            [self gameover];
                            break;
                        default:
                            [self gameover];
                            break;
                    }
                }  
            }
            
            for (Enemy *enemy in enemies)
            {
                if ( enemy.isAlive )
                {
                    [enemy isIntersectingPlayer:player];
                }
            }
            
            [self playerMovementChecks];
            [player movement:levelThreshold withGravity:0.25];
        }
        else 
        {
            NSLog(@"Dead");
        }
    }
}

- (void) gameover
{
    self.isTouchEnabled = FALSE;
    [self unschedule:@selector(update:)];
    id horizontalmove = [CCMoveTo actionWithDuration:2 position:ccp(280,player.position.y)];
    
    CCAction *repeater = [CCSequence actions:horizontalmove,nil];
    [player runAction:repeater];

    
    
    user.collected += player.collected;
    if (self.levelNumber == user.levelprogress)
    {
        if (player.bigcollected > 0 )
        {
            user.levelprogress = user.levelprogress + 1;
            if (user.levelprogress > 9)
            {
                user.worldprogress = user.worldprogress + 1;
                user.levelprogress = 1;
            }
        }
    }
    [user syncData];

    
    CCLayer *gameover = [CCLayer node];
    CCMenuItem *restartButton = [CCMenuItemImage itemWithNormalImage:@"Icon.png" selectedImage:@"Icon.png" target:self selector:@selector(restartButtonTapped:)];
    CCMenuItem *nextLevelButton = [CCMenuItemImage itemWithNormalImage:@"Icon.png" selectedImage:@"Icon.png" target:self selector:@selector(nextLevelButtonTapped:)];
    CCMenuItem *backtoMenuButton = [CCMenuItemImage itemWithNormalImage:@"Icon.png" selectedImage:@"Icon.png" target:self selector:@selector(backToMenuButtonTapped:)];
    NSLog(@"Set up items");
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
    for( UITouch *touch in touches ) 
    {
        CGPoint location = [touch locationInView: [touch view]];
        self.touchLocation = location;
    }
}

- (void)launch:(id)sender
{
    player.velocity = ccp ( player.velocity.x, player.jumpspeed + 3 );
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
    int nextlevel = self.levelNumber + 1;
    if (nextlevel > 9)
    {
        // do a world transition
    }
    else 
    {
        [[CCDirector sharedDirector] pushScene:[LevelScene sceneWithWorldNum:self.worldNumber LevelNum:nextlevel]];
    }
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