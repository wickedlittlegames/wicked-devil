//
//  PlayerStatsScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 19/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "PlayerStatsScene.h"
#import "AppDelegate.h"

@implementation PlayerStatsScene

+(CCScene *) scene
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
	PlayerStatsScene *current = [PlayerStatsScene node];
    
    // Fill the scene
	[scene addChild:current z:10];
    
    // Show the scene
	return scene;
}

-(id) init
{
    if( (self=[super init]) ) {
        user = [[User alloc] init];
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        NSString *font = @"Arial";
        int fontsize = 18;

        CCLabelTTF *lbl_total_collected = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Total Collected:%d",user.collected] fontName:font fontSize:fontsize];
        lbl_total_collected.position = ccp (screenSize.width/2, 460);
        [self addChild:lbl_total_collected];
        
        CCLabelTTF *lbl_world_progress = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Progress:%d - %d",user.worldprogress, user.levelprogress] fontName:font fontSize:fontsize];
        lbl_world_progress.position = ccp ( screenSize.width/2, 200);
        [self addChild:lbl_world_progress];

		// Default font size will be 28 points.
		[CCMenuItemFont setFontSize:28];
		
		// Achievement Menu Item using blocks
		CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
			
			
			GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
			achivementViewController.achievementDelegate = self;
			
			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			
			[[app navController] presentModalViewController:achivementViewController animated:YES];
		}
									   ];
        
		// Leaderboard Menu Item using blocks
		CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
			
			
			GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
			leaderboardViewController.leaderboardDelegate = self;
			
			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			
			[[app navController] presentModalViewController:leaderboardViewController animated:YES];
        }
									   ];
		
		CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, nil];
		
		[menu alignItemsHorizontallyWithPadding:10];
		[menu setPosition:ccp( screenSize.width/2, 50)];
		
		// Add the menu to the layer
		[self addChild:menu];
                
        CCMenuItem *back = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"BACK" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_back)];
        CCMenu *back_menu = [CCMenu menuWithItems:back, nil];
        back_menu.position = ccp ( screenSize.width - 80, 10 );
        
        [self addChild:back_menu];
        
        CCMenuItem *resetuser = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"RESET PLAYER" fontName:@"Marker Felt" fontSize:18] target:self selector:@selector(tap_resetuser:)];
        CCMenu *resetusermenu = [CCMenu menuWithItems:resetuser, nil];
        [resetusermenu alignItemsHorizontallyWithPadding:20];
        resetusermenu.position = ccp ( screenSize.width/2, screenSize.height/2 );
        [self addChild:resetusermenu];
    }
    return self;
}

- (void) tap_resetuser:(id)sender
{
    [user resetUser];
}

- (void) tap_back
{
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];
}


#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}


@end
