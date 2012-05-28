//
//  LevelSelectScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//
#import "CCScrollLayer.h"
#import "UILayer.h"
#import "LevelScene.h"
#import "LevelSelectScene.h"

@implementation LevelSelectScene

+(CCScene *) scene
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
    UILayer *ui = [UILayer node];
	LevelSelectScene *current = [LevelSelectScene node];
    
    // Fill the scene
    [scene addChild:ui z:100];
	[scene addChild:current z:10];
    
    // Show the scene
	return scene;
}

-(id) init
{
	if( (self=[super init]) ) {
        // get screen size
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        CCLayer *pageOne = [CCLayer node];
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Page 1" fontName:@"Arial Rounded MT Bold" fontSize:20];
        label.position =  ccp( screenSize.width /2 , screenSize.height/2 );
        [pageOne addChild:label];

        CCLayer *pageTwo = [CCLayer node];
        CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Page 2" fontName:@"Arial Rounded MT Bold" fontSize:20];
        label2.position =  ccp( screenSize.width /2 , screenSize.height/2 );
        CCSprite *bg = [CCSprite spriteWithFile:@"bg0.png"];
        bg.position = ccp ( (320/2), (480/2));
        [pageTwo addChild:bg];
        [pageTwo addChild:label2];
        
        CCLayer *pageThree = [CCLayer node];
        CCLabelTTF *label3 = [CCLabelTTF labelWithString:@"Page 3" fontName:@"Arial Rounded MT Bold" fontSize:20];
        label3.position =  ccp( screenSize.width /2 , screenSize.height/2 );
        CCSprite *bg2 = [CCSprite spriteWithFile:@"bg4.png"];
        bg2.position = ccp ( (320/2), (480/2));
        [pageThree addChild:bg2];
        [pageThree addChild:label3];
        
        CCScrollLayer *scroller = [[CCScrollLayer alloc] initWithLayers:[NSMutableArray arrayWithObjects: pageOne,pageTwo,pageThree,nil] widthOffset: 0];
        
        [self addChild:scroller];

    }
	return self;    
}

- (void)levelButtonTapped:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[LevelScene sceneWithLevelNum:1]];
}

@end
