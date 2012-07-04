//
//  OptionsScene.m
//  Wicked Little Devil
//
//  This scene shows the store for purchasing objects (individual or pack)
//
//  Created by Andrew Girvan on 06/06/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "ShopScene.h"
#import "CCScrollLayer.h"


@implementation ShopScene

+(CCScene *) scene
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
	ShopScene *current = [ShopScene node];
    
    // Fill the scene
	[scene addChild:current z:10];
    
    // Show the scene
	return scene;
}

-(id) init
{
    if( (self=[super init]) ) {
        //User *user = [User alloc];
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        CCMenuItem *restore_purchases = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"Restore Purchases" fontName:@"Marker Felt" fontSize:18] target:self selector:@selector(tap_back)];
        CCMenu *restore_purchasesmenu = [CCMenu menuWithItems:restore_purchases, nil];
        restore_purchasesmenu.position = ccp ( 85, 10 );
        
        CCLayer *powerups_layer = [self createPowerupLayer];
        CCLayer *money_layer  = [self createMoneyLayer];
        
        CCScrollLayer *scroller = [[CCScrollLayer alloc] initWithLayers:[NSArray arrayWithObjects:powerups_layer,money_layer, nil] widthOffset: 0];
        scroller.position = ccp(0,0);
        [self addChild:scroller];
        
        [self addChild:restore_purchasesmenu];

        CCMenuItem *back = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"BACK" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_back)];
        CCMenu *menu = [CCMenu menuWithItems:back, nil];
        menu.position = ccp ( screenSize.width - 80, 10 );
        [self addChild:menu];        
    }
    return self;
}

- (CCLayer*)createPowerupLayer
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    NSNumber* itemsPerRow = [NSNumber numberWithInt:3];
    float menu_x = (screenSize.width/2);
    float menu_y = 275;
    
    CCLayer *tmp_layer = [CCLayer node];
    CCLabelTTF *powerups_label = [CCLabelTTF labelWithString:@"POWERUPS" fontName:@"Marker Felt" fontSize:20];
    powerups_label.position = ccp (screenSize.width/2,420);
    [tmp_layer addChild:powerups_label];
    
    CCMenuItem *powerup_healthboost = [CCMenuItemImage 
                                       itemWithNormalImage:@"Icon.png"
                                       selectedImage:@"Icon.png" 
                                       target:self 
                                       selector:@selector(tap_powerup:)];
    powerup_healthboost.tag = 0;
    CCLabelTTF *powerup_name_healthboost = [CCLabelTTF labelWithString:@"Health Boost ( 1000Souls )" fontName:@"Marker Felt" fontSize:12];
    powerup_name_healthboost.position = ccp (powerup_name_healthboost.position.x + 27, powerup_name_healthboost.position.y - 12);
    [powerup_healthboost addChild:powerup_name_healthboost];
    
    CCMenuItem *powerup_lightfeet = [CCMenuItemImage 
                                     itemWithNormalImage:@"Icon.png"
                                     selectedImage:@"Icon.png" 
                                     target:self 
                                     selector:@selector(tap_powerup:)];
    powerup_lightfeet.tag = 1;
    CCLabelTTF *powerup_name_lightfeet = [CCLabelTTF labelWithString:@"Light Feet ( 1000Souls )" fontName:@"Marker Felt" fontSize:12];
    powerup_name_lightfeet.position = ccp (powerup_name_lightfeet.position.x + 27, powerup_name_lightfeet.position.y - 12);
    [powerup_lightfeet addChild:powerup_name_lightfeet];
    
    CCMenuItem *powerup_moneybags = [CCMenuItemImage 
                                     itemWithNormalImage:@"Icon.png"
                                     selectedImage:@"Icon.png" 
                                     target:self 
                                     selector:@selector(tap_powerup:)];
    powerup_moneybags.tag = 2;
    CCLabelTTF *powerup_name_moneybags = [CCLabelTTF labelWithString:@"Moneybags ( 10000Souls )" fontName:@"Marker Felt" fontSize:10];
    powerup_name_moneybags.position = ccp (powerup_name_moneybags.position.x + 27, powerup_name_moneybags.position.y - 12);
    [powerup_moneybags addChild:powerup_name_moneybags];
    
    CCMenu *powerups_menu = [CCMenu menuWithItems:powerup_healthboost,powerup_lightfeet,powerup_moneybags, nil];
    powerups_menu.position = ccp (menu_x, menu_y);
    [powerups_menu alignItemsInColumns:itemsPerRow,nil];
    [tmp_layer addChild:powerups_menu];
    
    return tmp_layer;
}

- (void) update_label
{
    // do nothing
}

- (CCLayer*)createMoneyLayer
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    //NSNumber* itemsPerRow = [NSNumber numberWithInt:3];
    //float menu_x = (screenSize.width/2);
    //float menu_y = 275;
    
    CCLayer *tmp_layer = [CCLayer node];
    CCLabelTTF *money_label = [CCLabelTTF labelWithString:@"PURCHASE SIN POINTS" fontName:@"Marker Felt" fontSize:20];
    money_label.position = ccp (screenSize.width/2,420);
    [tmp_layer addChild:money_label];
    return tmp_layer;
}

- (void)tap_powerup:(CCMenuItem*)sender
{
    CCLOG(@"TAPPED POWERUP PURCHASE");
    switch (sender.tag)
    {
        case 0:
            CCLOG(@"DO POWERUP PURCHASE SCREEN");
            break;
        default:
            CCLOG(@"DEFAULT POWERUP PURCHASE");
            break;
    }
}

- (void) tap_back
{
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];
}


@end
