//
//  LevelSelectScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 25/05/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "DetectiveLevelSelectScene.h"
#import "AdventureSelectScene.h"
#import "ShopScene.h"
#import "GameScene.h"
#import "User.h"

@implementation DetectiveLevelSelectScene

+(CCScene *) sceneWithWorld:(int)world
{
	CCScene *scene              = [CCScene node];
	DetectiveLevelSelectScene *current   = [[DetectiveLevelSelectScene alloc] initWithWorld:world];
	[scene addChild:current];
	return scene;
}

- (id) initWithWorld:(int)world
{
    if( (self=[super init]) )
    {
        // Used variables throughout
        User *user = [[User alloc] init];
        CGSize screenSize       = [CCDirector sharedDirector].winSize;
        NSString *font          = @"CrashLanding BB";
        NSNumber *itemsPerRow   = [NSNumber numberWithInt:4];
        NSNumber *itemsPerRow2   = [NSNumber numberWithInt:2];
        int fontsize            = 36;
        float menu_x            = (screenSize.width/2);
        float menu_y            = screenSize.height - 212;
        int world_score              = [user getHighscoreforWorld:world];
        int big_collectables_total   = (12 * 3);
        int big_collectables_player  = 0;
        
        // Object sprite creation
        CCMenu  *menu                   = [CCMenu menuWithItems:nil];
        
        // Loop to show the levels
        for (int lvl = 1; lvl <= 10; lvl++)
        {
            CCMenuItemImage *button = [CCMenuItemImage itemWithNormalImage:@"btn-level-bw.png" selectedImage:@"btn-level-bw.png" disabledImage:@"btn-level-locked.png" target:self selector:@selector(tap_level:)];
            button.tag = lvl; button.userData = (int*)world; button.isEnabled = TRUE;
            
            int souls = [user getSoulsforWorld:world level:lvl];
            big_collectables_player += souls;
            
            int soul_x = 13;
            for (int s = 1; s <= souls; s++ )
            {
                CCSprite *soul = [CCSprite spriteWithFile:@"icon-level-bigcollectable-bw.png"];
                
                soul.position = ccp(button.position.x + soul_x, button.position.y - 2);
                [button addChild:soul];
                soul_x += 17;
            }
            
            CCLabelTTF *lbl_level_name = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i",lvl] fontName:font fontSize:fontsize];
            lbl_level_name.position = ccp (lbl_level_name.position.x + 29, button.position.y + 29);
            lbl_level_name.color = ccc3(255,255,255);
            
            [button addChild:lbl_level_name];
            lbl_level_name.visible = button.isEnabled;
            
            [menu addChild:button];
        }
        [menu alignItemsInColumns:itemsPerRow, itemsPerRow, itemsPerRow2,nil];
        
        CCSprite *bg                    = [CCSprite spriteWithFile:@"bg_20.png"];
        CCMenu *menu_back               = [CCMenu menuWithItems:[CCMenuItemImage itemWithNormalImage:@"btn-back-bw.png"    selectedImage:@"btn-back-bw.png"       target:self selector:@selector(tap_back:)], nil];
        CCSprite *icon_bigcollectable   = [CCSprite spriteWithFile:@"icon-bigcollectable-med-bw.png"];
        CCSprite *icon_collectable      = [CCSprite spriteWithFile:@"ui-collectable-bw.png"];
        CCLabelTTF *label_world_score   = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %d",world_score] dimensions:CGSizeMake(screenSize.width - 20, 25) hAlignment:kCCTextAlignmentRight fontName:font fontSize:32];
        CCLabelTTF *label_bigcollected  = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i/%i", big_collectables_player, big_collectables_total] dimensions:CGSizeMake(screenSize.width - 80, 30) hAlignment:kCCTextAlignmentRight fontName:font fontSize:32];
        CCLabelTTF *label_collected     = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", user.collected] dimensions:CGSizeMake(screenSize.width - 80, 30) hAlignment:kCCTextAlignmentRight fontName:font fontSize:32];
        
        [bg                     setPosition:ccp(screenSize.width/2, screenSize.height/2 )];
        [menu                   setPosition:ccp(menu_x, menu_y)];
        [menu_back              setPosition:ccp(25, 25)];
        [icon_bigcollectable    setPosition:ccp(screenSize.width - 20, screenSize.height - 20)];
        [label_bigcollected     setPosition:ccp(screenSize.width/2, screenSize.height - 22)];
        [icon_collectable       setPosition:ccp(screenSize.width - 20, icon_bigcollectable.position.y - 26)];
        [label_world_score      setPosition:ccp(screenSize.width/2, 22 )];
        [label_collected        setPosition:ccp(screenSize.width/2, label_bigcollected.position.y - 24)];
        
        [self addChild:bg];
        [self addChild:menu];
        [self addChild:menu_back];
        [self addChild:icon_bigcollectable];
        [self addChild:label_bigcollected];
        [self addChild:label_world_score];
        [self addChild:icon_collectable];
        [self addChild:label_collected];
    }
    return self;
}

#pragma mark TAPS

- (void) tap_level:(CCMenuItem*)sender
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[GameScene sceneWithWorld:(int)sender.userData andLevel:sender.tag isRestart:FALSE restartMusic:YES]]];
}

- (void) tap_back:(CCMenuItem*)sender
{
    if ( ![SimpleAudioEngine sharedEngine].mute ) {[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];}
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[AdventureSelectScene scene]]];
}

@end