//
//  StartScreen.m
//  Wicked Little Devil
//
//  This SCENE is the Angry Birds-style "Start" button that takes you to the world selector
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

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
        // Set up and start a user
        user = [[User alloc] init];
        
        CCMenuItem *startButton = [CCMenuItemImage itemWithNormalImage:@"Icon.png" selectedImage:@"Icon.png" target:self selector:@selector(startButtonTapped:)];
        CCMenu *menu = [CCMenu menuWithItems:startButton, nil];
        menu.position = ccp ( 150, 10 );
        [self addChild:menu];
        
        NSString *highscore = [NSString stringWithFormat:@"%d", user.highscore];
        CCLabelTTF *score_label = [CCLabelTTF labelWithString:highscore fontName:@"Arial" fontSize:14];
		score_label.color = ccc3(255,255,255);
		score_label.position = ccp(100, 300);
		[self addChild:score_label];
    }
	return self;    
}

- (void)startButtonTapped:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];
}

@end
