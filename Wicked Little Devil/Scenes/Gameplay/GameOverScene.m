//
//  GameOverScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 13/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "GameOverScene.h"


@implementation GameOverScene
@synthesize score, timebonus, bigs, world, level;

#pragma mark === Initialization ===

+(CCScene *) sceneWithScore:(int)_score timebonus:(int)_timebonus bigs:(int)_bigs forWorld:(int)_world andLevel:(int)_level
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
	GameOverScene *current = [GameOverScene node];
    [current setScore:_score];
    [current setTimebonus:_timebonus];
    [current setBigs:_bigs];
    [current setWorld:_world];
    [current setLevel:_level];
    
    // Fill the scene
	[scene addChild:current];
    [current do_scores];
    
    // Show the scene
	return scene;
}

-(id) init
{
    if( (self=[super init]) ) 
    {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        NSString *font = @"Marker Felt";
        int fontsize = 18;
        
        user = [[User alloc] init];
        
        CCMenuItem *back = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"BACK" fontName:font fontSize:fontsize] target:self selector:@selector(tap_back)];
        CCMenu *menu_back = [CCMenu menuWithItems:back, nil];
        menu_back.position = ccp ( screenSize.width - 80, 10 );
        [self addChild:menu_back z:100];
        
        label_score = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i",score] fontName:font fontSize:fontsize];
        [label_score setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        [self addChild:label_score];
        
        label_score_type = [CCLabelTTF labelWithString:@"SCORE:" fontName:font fontSize:fontsize];
        [label_score_type setPosition:ccp(screenSize.width/2, screenSize.height/2 + 40)];
        [self addChild:label_score_type];
        
        if ( user.isConnectedToFacebook ) [self check_facebook_scores];
    }
    return self;
}

#pragma mark === Taps ===

- (void) tap_back
{
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];
}

#pragma mark === Score Animation Steps ===

- (void) do_scores
{
    if ( bigs >= 1 )
    {
        int facebook_bonus = ( user.isConnectedToFacebook ? 200 : 0 );
        
        total = (score * bigs) + timebonus + facebook_bonus;
        
        CCLOG(@"SCORE IS: %i (basic: %i, bigs: %i, timebonus: %i, fb: %i)", total, score, bigs, timebonus, facebook_bonus);
        
        // Step through the animations for the scores
        [self anim_start];
    }
    else 
    {
        CCLOG(@"NO BIGS");
    }
}

- (void) anim_start
{
    CCLOG(@"ANIM START");
    [self anim_1];
}

- (void) anim_1
{
    CCLOG(@"ANIM 1");
    [self anim_2];
}

- (void) anim_2
{
    CCLOG(@"ANIM 2");    
    [self anim_3];
}

- (void) anim_3
{
    CCLOG(@"ANIM 3");
    [self anim_end];
}

- (void) anim_end
{
    CCLOG(@"ANIM END");
//    if (total > [user getHighscoreforWorld:world level:level])
//    {
//        // Show the highscore animation
//        [self anim_highscore];
//    }
    
    [self anim_menufade];
}

- (void) anim_highscore
{
    CCLOG(@"ANIM HIGHSCORE");
}

- (void) anim_menufade
{
    CCLOG(@"ANIM MENUFADE");
}

#pragma mark === Facebook Integration ===

- (void) check_facebook_scores
{
    [[PFFacebookUtils facebook] requestWithGraphPath:@"me/friends" andDelegate:self];
}

- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    // Assuming no errors, result will be an NSDictionary of your user's friends
    NSArray *friendObjects = [result objectForKey:@"data"];
    friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
    // Create a list of friends' Facebook IDs
    for (NSDictionary *friendObject in friendObjects) {
        [friendIds addObject:[friendObject objectForKey:@"id"]];
    }
    
    // Construct a PFUser query that will find friends whose facebook ids are contained
    // in the current user's friend list.
    PFQuery *friendQuery = [PFUser query];
    [friendQuery whereKey:@"fbId" containedIn:friendIds];
    
    // findObjects will return a list of PFUsers that are friends with the current user
    friendUsers = [friendQuery findObjects];
    
    CCLOG(@"FRIENDS: %@", friendIds);
    CCLOG(@"FRIEND USERS: %@", friendUsers);

    NSMutableArray *scoreUsers = [NSMutableArray arrayWithCapacity:[friendUsers count]];
    
    for (int i = 0; i < [friendUsers count]; i++ )
    {
        PFQuery *scoreQuery = [PFQuery queryWithClassName:@"Highscore"];
        [scoreQuery whereKey:@"world" equalTo:[NSNumber numberWithInt:world]];
        [scoreQuery whereKey:@"level" equalTo:[NSNumber numberWithInt:level]];
        [scoreQuery whereKey:@"fbId" equalTo:[[friendUsers objectAtIndex:i] valueForKey:@"fbId"]];
        CCLOG(@"SCORE QUERY RESULT:%@",[scoreQuery findObjects]);
        [scoreUsers addObject:[scoreQuery findObjects]];
    }
}

@end