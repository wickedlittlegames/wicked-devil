//
//  StartScreen.m
//  Wicked Little Devil
//
//  This SCENE is the Angry Birds-style "Start" button that takes you to the world selector
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "AppDelegate.h"
#import "UILayer.h"
#import "StartScene.h"
#import "LevelSelectScene.h"


@implementation StartScene

+(CCScene *) scene
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
    UILayer *ui = [UILayer node];
	StartScene *current = [StartScene node];
    
    // Fill the scene
    [scene addChild:ui z:100];
	[scene addChild:current z:10];
    
    // Show the scene
	return scene;
}

-(id) init
{
	if( (self=[super init]) ) {

        user = [[User alloc] init];
        
        CCMenuItem *startButton = [CCMenuItemImage itemWithNormalImage:@"Icon.png" selectedImage:@"Icon.png" target:self selector:@selector(startButtonTapped:)];
        CCMenu *menu = [CCMenu menuWithItems:startButton, nil];
        menu.position = ccp ( 120, 300 );
        [self addChild:menu];
        
        NSString *highscore = [NSString stringWithFormat:@"Highscore: %d", user.highscore];
        CCLabelTTF *score_label = [CCLabelTTF labelWithString:highscore fontName:@"Arial" fontSize:14];
		score_label.color = ccc3(255,255,255);
		score_label.position = ccp(250, 470);
		[self addChild:score_label];
        
        NSString *collectedscore = [NSString stringWithFormat:@"Collected: %d", user.collected];
        CCLabelTTF *collectedscore_label = [CCLabelTTF labelWithString:collectedscore fontName:@"Arial" fontSize:14];
		collectedscore_label.color = ccc3(255,255,255);
		collectedscore_label.position = ccp(100, 470);
		[self addChild:collectedscore_label];     
        
        // Default font size will be 28 points.
		[CCMenuItemFont setFontSize:28];
		CGSize size = [[CCDirector sharedDirector] winSize];
        
		// Achievement Menu Item using blocks
		CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
			GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
			achivementViewController.achievementDelegate = self;
			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			[[app navController] presentModalViewController:achivementViewController animated:YES];
		}];
        
		// Leaderboard Menu Item using blocks
		CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
			GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
			leaderboardViewController.leaderboardDelegate = self;
			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			[[app navController] presentModalViewController:leaderboardViewController animated:YES];
        }];
		
		CCMenu *menu_gamecenter = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, nil];
		
		[menu_gamecenter alignItemsHorizontallyWithPadding:20];
		[menu_gamecenter setPosition:ccp( size.width/2, size.height/2 - 50)];
        
		// Add the menu to the layer
		[self addChild:menu_gamecenter];
        
    }
	return self;    
}

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


- (void)startButtonTapped:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];
}

@end
