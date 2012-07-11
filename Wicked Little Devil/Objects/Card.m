//
//  Card.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 11/07/2012.
//  Copyright (c) 2012 Wicked Little Websites. All rights reserved.
//

#import "Card.h"

@implementation Card

-(id) initWithName:(NSString*)_name Description:(NSString*)_desc Cost:(int)_cost Unlocked:(bool)_unlocked Image:(NSString*)_image
{
	if( (self=[super init]) )
    {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        NSString *font = @"Arial";
        int fontsize = 18;
        
        image = [CCSprite spriteWithFile:@"card.png"];
        image.position = ccp ( screenSize.width/2, screenSize.height/2 );
        [self addChild:image];
        
        CCMenuItem *btn_equip = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"Equip" fontName:font fontSize:fontsize] target:self selector:@selector(tap_equip:)];
        CCMenuItem *btn_purchase = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"Purchase" fontName:font fontSize:fontsize] target:self selector:@selector(tap_equip:)];    
        btn_equip.tag = 1;
        btn_purchase.tag = 1;
        
        menu = [CCMenu menuWithItems:btn_equip, btn_purchase, nil];
        [menu alignItemsHorizontallyWithPadding:20];
        menu.position = ccp ( screenSize.width/2, 80 );
        [self addChild:menu];
    }
    
    return self;
}

@end
