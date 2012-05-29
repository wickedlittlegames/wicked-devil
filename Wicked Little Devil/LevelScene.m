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
@synthesize gravity, level, started;

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
        self.isTouchEnabled = YES;
        self.scaleY = -1;
        self.gravity = 0.225;
        self.level = levelNum;
        self.started = FALSE;
        
        // Get level data
        [self buildWorld:levelNum];
        
        // Instanciate Player
        player = [Player spriteWithFile:@"devil.png"];
        player.position = ccp(110,375);
        touchLocation.x = player.position.x;
        [self addChild:player];
        
        // Start button
        menu = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"launch.png" selectedImage:@"launch.png" target:self selector:@selector(launch:)], nil];
        menu.position = ccp ( 320/2, 440 );
        [self addChild:menu z:100];
        
        // Start Game loop
        [self schedule:@selector(update:)];
    }
	return self;
}

- (void)launch:(id)sender
{
    player.velocity = ccp ( player.velocity.x, -15.5 );
    menu.visible = NO;
    started = TRUE;
}

- (void) buildWorld:(int)levelNum
{    
    platforms       = [NSMutableArray arrayWithCapacity:100];
    collectables    = [NSMutableArray arrayWithCapacity:100];
    enemies         = [NSMutableArray arrayWithCapacity:100]; 

    NSString *level_string = [NSString stringWithFormat:@"level%d.plhs",levelNum];
    NSString *finalPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:level_string];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    NSMutableArray *plistSpriteArray = [NSArray arrayWithObject:[plistData objectForKey:@"SPRITES_INFO"]];
    
    for (NSDictionary *dict in plistSpriteArray)
    {
        for (NSDictionary *dict2 in dict)
        {
            NSDictionary *object_properties = [dict2 objectForKey:@"GeneralProperties"];
            NSString *tagcheck = [NSString stringWithFormat:@"%@", [object_properties valueForKey:@"TagName"]];
            NSString *image = [NSString stringWithFormat:@"%@.png",[object_properties valueForKey:@"SHName"]];            
            NSArray *stringArray = [[object_properties valueForKey:@"Position"] componentsSeparatedByString:@","];
            float x = [[[stringArray objectAtIndex:0] stringByReplacingOccurrencesOfString:@"{" withString:@""] floatValue];
            float y = [[[stringArray objectAtIndex:1] stringByReplacingOccurrencesOfString:@"}" withString:@""] floatValue];
            
            if ( [tagcheck isEqualToString:@"PLATFORM"] )
            {
                Platform *platform = [Platform spriteWithFile:image];
                platform.position = ccp ( x, y );
                platform.type = [object_properties valueForKey:@"SHName"];
                platform.health = [[object_properties valueForKey:@"Opactiy"] floatValue]; // opactiy is used for health
                
                [self addChild:platform];
                [platforms addObject:platform];
            }
            else if ( [tagcheck isEqualToString:@"COLLECTABLE"] )
            {
                Collectable *collectable = [Collectable spriteWithFile:image];
                collectable.position = ccp ( x, y );
                [self addChild:collectable];
                [collectables addObject:collectable];
            }
            else if ( [tagcheck isEqualToString:@"ENEMY"] )
            {
                
            }
            else if ( [tagcheck isEqualToString:@"BACKGROUND"] )
            {
                NSString *bg_name = [NSString stringWithFormat:@"bg-%@.png",[[dict2 objectForKey:@"GeneralProperties"] valueForKey:@"SHName"]];
                
                background = [CCLayer node];
                CCSprite *bg_image = [CCSprite spriteWithFile:bg_name];
                bg_image.position = ccp ( (320/2), (480/2) );
                [background addChild:bg_image];
                
                [self addChild:background z:-1];
            }
        }
    }
    
    floor = [CCSprite spriteWithFile:@"floor.png"];
    floor.position = ccp(320/2,470);
    floor.scaleY = -1;
    [self addChild:floor];
}

- (void)update:(ccTime)dt 
{
    if ( ![[CCDirector sharedDirector] isPaused] && self.started == TRUE )
    {
        if (player.isAlive)
        {   
            levelThreshold = 50 - player.position.y;
            
            if ( levelThreshold >= 0 )
            {
                background.position = ccp(background.position.x, background.position.y + levelThreshold/40);
                floor.position = ccp(floor.position.x, floor.position.y + levelThreshold);
            }
            
            for (Platform *platform in platforms)
            {                
                if ( [platform isIntersectingPlayer:player] ) 
                {
                    [player bounce];
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
            }
            
            [self playerMovementChecks];

            [player update:levelThreshold withGravity:self.gravity];
        }
        else 
        {
            NSLog(@"Dead");
        }
    }
}

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

@end