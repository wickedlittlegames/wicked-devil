//
//  PlayerEquipmentLayer.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 11/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "PlayerEquipmentLayer.h"
#import "CCScrollLayer.h"

@implementation PlayerEquipmentLayer

-(id) init
{
	if( (self=[super init]) ) 
    {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];    
        user = [[User alloc] init]; 
        NSArray *contentArray = [[NSDictionary 
                                    dictionaryWithContentsOfFile:[[NSBundle mainBundle] 
                                                                    pathForResource:@"Powerups" 
                                                                    ofType:@"plist"]
                                    ] objectForKey:@"Powerups"];
        
        NSMutableArray *cards = [NSMutableArray arrayWithCapacity:[contentArray count]];
        
        for (int i = 0; i <[contentArray count]; i++ )
        {
            NSDictionary *dict = [contentArray objectAtIndex:i];
            
            NSString *name = [dict valueForKey:@"Name"];
            NSString *desc = [dict valueForKey:@"Description"];
            NSString *image = [dict valueForKey:@"Image"];
            int cost = [[dict valueForKey:@"Cost"] intValue];            
            bool unlocked = [[dict valueForKey:@"Unlocked"] boolValue];
            CCLOG(@"CREATING CARDS");
            Card *card = [[Card alloc] initWithName:name Description:desc Cost:cost Unlocked:unlocked Image:image];
            [cards addObject:card];
        }
        CCLOG(@"CREATED CARDS");            
        
        CCScrollLayer *scroller2 = [[CCScrollLayer alloc] initWithLayers:cards widthOffset: 20];
        [self addChild:scroller2];
        
        CCMenuItem *back = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"BACK" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_back)];
        CCMenu *menu = [CCMenu menuWithItems:back, nil];
        menu.position = ccp ( screenSize.width - 80, 10 );
        [self addChild:menu z:100];

        [self appear];
    }
	return self;    
}

- (void) tap_purchase:(id)sender
{
    
}

- (void) tap_equip:(CCMenuItem*)sender
{
    user.powerup = sender.tag;
    [user sync];
}

- (void) tap_back
{
    [self disappear];
}

- (void) appear
{
    id moveAction = [CCScaleTo actionWithDuration:0.2 scale:1.0];
    [self runAction:[CCSequence actions:moveAction,nil]];
}

- (void) disappear
{
    id moveAction = [CCScaleTo actionWithDuration:0.2 scale:0];
    [self runAction:[CCSequence actions:moveAction,nil]];
    [self removeFromParentAndCleanup:YES];
}

@end
