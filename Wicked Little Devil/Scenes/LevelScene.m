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
@synthesize started, complete, player, worldNumber, levelNumber, touchLocation, ui, gameoverlayer;
@synthesize background_front, background_middle, background_middle2, background_back;

#pragma mark === Initialization ===

- (id) init
{
	if( (self=[super init]) ) {
        
        self.started = FALSE;
        self.complete = FALSE;
        self.isTouchEnabled = TRUE;

        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        user = [[User alloc] init];
        [player setupPowerup:user.powerup];
        
        platform_toggle1 = [[CCTextureCache sharedTextureCache] addImage:@"platform-toggle1.png"];
        platform_toggle2 = [[CCTextureCache sharedTextureCache] addImage:@"platform-toggle2.png"];
        
        floor = [CCSprite spriteWithFile:@"floor.png"];
        floor.position = ccp ( screenSize.width/2, 80 );
        [self addChild:floor];
        
        CCMenuItem *launchButton = [CCMenuItemImage itemWithNormalImage:@"Start-button.png" selectedImage:@"Start-button.png" target:self selector:@selector(tap_launch:)];
        menu = [CCMenu menuWithItems:launchButton, nil];
        menu.position = ccp ( screenSize.width/2, 30 );
        [self addChild:menu];
        
        
    }
	return self;
}

+(CCScene *) sceneWithWorldNum:(int)worldNum LevelNum:(int)levelNum
{
    // Create a Scene
	CCScene *scene = [CCScene node];

    // Grab the layers
    CCLayer *playerlayer        = [CCLayer node];
    GameplayUILayer *uilayer    = [GameplayUILayer node];
    GameoverUILayer *gameoverlayer = [GameoverUILayer node];

    LevelScene *objectLayer     = (LevelScene*)[CCBReader 
                                        nodeGraphFromFile:[NSString stringWithFormat:@"world-%d-level-%d.ccbi",worldNum,levelNum]
                                        owner:NULL];
    
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    
    /*
    CCSprite *_background_front = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%i-bg-front",worldNum]];
    _background_front.position = ccp ( screenSize.width/2, screenSize.height/2 );
    [scene addChild:_background_front z:4];
    
    CCSprite *_background_middle = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%i-bg-mid",worldNum]];
    _background_middle.position = ccp ( screenSize.width/2, screenSize.height/2 );
    [scene addChild:_background_middle z:3];
    
    CCSprite *_background_middle2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%i-bg-mid2",worldNum]];
    _background_middle2.position = ccp ( screenSize.width/2, screenSize.height/2 );
    [scene addChild:_background_middle2 z:2];
    
    CCSprite *_background_back = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%i-bg-back",worldNum]];
    _background_back.position = ccp ( screenSize.width/2, screenSize.height/2 );
    [scene addChild:_background_back z:1];
     */
    
    Player *_player = [Player spriteWithFile:@"player.png"];
    _player.scale = _player.scale/2;
    _player.position = ccp( screenSize.width/2 , 110 );
    [playerlayer addChild:_player];
    gameoverlayer.visible = FALSE;
        
    [objectLayer setPlayer:_player];
    [objectLayer setTouchLocation:_player.position];
    [objectLayer setWorldNumber:worldNum];
    [objectLayer setLevelNumber:levelNum];
    [objectLayer setUi:uilayer];
    [objectLayer setGameoverlayer:gameoverlayer];
    /*[objectLayer setBackground_front:_background_front];
    [objectLayer setBackground_middle:_background_middle];
    [objectLayer setBackground_middle2:_background_middle2];
    [objectLayer setBackground_back:_background_back];
     */
    [objectLayer createWorldWithObjects:[objectLayer children]];
    
    // Add layers to the scene
    [scene addChild:objectLayer z:50];
    [scene addChild:playerlayer z:51];
    [scene addChild:uilayer z:100];
    [scene addChild:gameoverlayer z:101];

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
        if (player.isAlive && player.position.y > -20)
        {   
            levelThreshold = 340 - player.position.y;
            
            if ( levelThreshold < 0 )
            {
                self.position = ccp (self.position.x, self.position.y + levelThreshold);
                self.background_front.position = ccp ( self.position.x, self.position.y + (levelThreshold/10) );
                self.background_middle.position = ccp ( self.position.x, self.position.y + (levelThreshold/10)/2 );
                self.background_middle2.position = ccp ( self.position.x, self.position.y + (levelThreshold/10)/4 );
                self.background_back.position = ccp ( self.position.x, self.position.y + (levelThreshold/10)/6 );                
            }

            for (Platform *platform in platforms)
            {       
                if ( platform.isAlive && platform.active )
                {
                    if ( [platform isIntersectingPlayer:player] ) 
                    {
                        switch (platform.tag)
                        {
                            case 0: // 0: Vertical Moving
                                [player jump:player.jumpspeed];
                                break;
                            case 1: // 1: Horizontal Moving
                                [player jump:player.jumpspeed];
                                break;                                
                            case 2: // 2: Big Jump
                                [player jump:player.jumpspeed*2];
                                break; 
                            case 3: // 3: Breakable Platform
                                [player jump:player.jumpspeed];
                                break;
                            case 4: // 4: Toggle (1)
                                [player jump:player.jumpspeed];
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
                            case 5: // 5: Toggle (2)
                                [player jump:player.jumpspeed];
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
                            case 6: // 6: Trap fire
                                [player jump:player.jumpspeed];
                                for (Trigger *trigger in triggers)
                                {
                                    if (trigger.tag == 1)
                                    {
                                        // Fire across the screen
                                        [trigger toggleEffect];
                                    }
                                }
                                break;
                            default:
                                // if the user has moneybags active
                                if ( user.powerup == 8 )
                                {
                                    [self showScorePop:200 atPosition:platform.position];
                                    player.score += 200;
                                }
                                else 
                                {
                                    [self showScorePop:100 atPosition:platform.position];
                                    player.score += 100;
                                }
                                //[platform takeDamagefromPlayer:player];
                                [player jump:player.jumpspeed];
                                break;
                        }
                    }
                    [platform setupHVMovement];
                }
            }
            
            for (Collectable *collectable in collectables)
            {
                if ( [collectable isIntersectingPlayer:player] ) 
                {
                    player.collected++;
                    player.score ++;
                }
            }
            
            for (BigCollectable *bigcollectable in bigcollectables)
            {
                if ( [bigcollectable isIntersectingPlayer:player] )
                {
                    player.bigcollected++;
                    [self showScorePop:500 atPosition:bigcollectable.position];
                    player.score += 500;
                }
            }
            
            for (Trigger *trigger in triggers)
            {
                if ( [trigger isIntersectingPlayer:player] )
                {
                    switch (trigger.tag)
                    {
                        case 1:
                            // do nothing
                            [trigger damageToPlayer:player];
                            break;
                        default:
                            self.complete = TRUE;
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
            
            [ui.lbl_collected setString:[NSString stringWithFormat:@"Collected: %d",player.collected]];
            [ui.lbl_score setString:[NSString stringWithFormat:@"Score: %d", player.score]];
        }
        else 
        {
            player.health = 0;
            [self gameover];
        }
    }
}

- (void) gameover
{
    self.started = FALSE;
    [self unschedule:@selector(update:)];
    
    if (player.isAlive && player.bigcollected > 0 && self.complete) // Won the game
    {       
        user.collected += player.collected;
        int score = player.score * player.bigcollected;
        [user updateSoulForWorld:worldNumber andLevel:levelNumber withTotal:player.bigcollected];
        [user updateHighscoreforWorld:worldNumber andLevel:levelNumber withScore:score];
        
        if (self.levelNumber == user.levelprogress)
        {
            user.levelprogress = user.levelprogress + 1;
            if (user.levelprogress > 9)
            {
                user.worldprogress = user.worldprogress + 1;
                user.levelprogress = 1;
            }
        }
        
        [user syncData];
        gameoverlayer.visible = TRUE;
        [gameoverlayer setWorld:worldNumber];
        [gameoverlayer setLevel:levelNumber];
        [gameoverlayer setNext_world:user.worldprogress];
        [gameoverlayer setNext_level:user.levelprogress];
        [gameoverlayer setScore:score];
        [gameoverlayer doFinalScoreAnimationsforUser:user andPlayer:player];
    }
    else 
    {
        gameoverlayer.visible = TRUE;
        gameoverlayer.lbl_gameover_bigcollected.visible = FALSE;
        gameoverlayer.lbl_gameover_collected.visible = FALSE;
        gameoverlayer.lbl_gameover_score.visible = FALSE;
        gameoverlayer.menu_failed.visible = TRUE;
    }
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

- (void)tap_launch:(id)sender
{
    player.velocity = ccp ( player.velocity.x, player.jumpspeed + 3 );
    menu.visible = NO;
    self.started = TRUE;
}

- (void) tap_nextlevel:(id)sender
{
    [self removeAllChildrenWithCleanup:YES]; 
    if ( self.worldNumber == user.worldprogress && self.levelNumber == user.levelprogress )
    {   
        [[CCDirector sharedDirector] replaceScene:[LevelScene sceneWithWorldNum:user.worldprogress LevelNum:user.levelprogress]];
    }
    else 
    {
        int nextlevel = self.levelNumber + 1;
        if (nextlevel > 9)
        {
            [[CCDirector sharedDirector] replaceScene:[LevelScene sceneWithWorldNum:self.worldNumber+1 LevelNum:self.levelNumber+1]];
        }
        else 
        {
            [[CCDirector sharedDirector] replaceScene:[LevelScene sceneWithWorldNum:self.worldNumber LevelNum:self.levelNumber+1]];
        }
    }
}

- (void) tap_restart:(id)sender
{
    [self removeAllChildrenWithCleanup:YES];
    [[CCDirector sharedDirector] replaceScene:[LevelScene sceneWithWorldNum:self.worldNumber LevelNum:self.levelNumber]];
}

- (void) tap_mainmenu:(id)sender
{
    [self removeAllChildrenWithCleanup:YES];
    [ui removeAllChildrenWithCleanup:YES];
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];
}

- (void) showScorePop:(int)score atPosition:(CGPoint)location
{
    CCLabelTTF *lbl_score = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",score] fontName:@"Marker Felt" fontSize:12];
    lbl_score.color = ccc3(255, 255, 255);
    [lbl_score setPosition:ccp(location.x, location.y - random()%30)];
    [lbl_score setOpacity:1.0];    
    [self addChild:lbl_score z:self.zOrder+1];
    
    CCEaseInOut *scaleUp = [CCEaseInOut actionWithAction:[CCScaleTo actionWithDuration:0.25 scale:1.8] rate:2.0f];
    CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:0.5 opacity:255];
    CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:0.25 opacity:0];
    CCSequence *pulseSequence = [CCSequence actions: fadeIn, fadeOut, nil];
    
    [lbl_score runAction:scaleUp];
    [lbl_score runAction:pulseSequence];
}

@end