//
//  EquipScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 13/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "EquipScene.h"
#import "LevelSelectScene.h"


@implementation EquipScene

+(CCScene *) scene
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
	EquipScene *current = [EquipScene node];
    
    // Fill the scene
	[scene addChild:current];
    
    // Show the scene
	return scene;
}

-(id) init
{
    if( (self=[super init]) ) {
        
        screenSize = [CCDirector sharedDirector].winSize;
        user = [[User alloc] init];
        
        // Place the cards available for purchasing
        [self setup_cards];
        
        // Back Button
        CCMenu *menu_back = [CCMenu menuWithItems:[CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"BACK" fontName:@"Marker Felt" fontSize:18] target:self selector:@selector(tap_back)], nil];
        menu_back.position = ccp ( screenSize.width - 80, 10 );
        [self addChild:menu_back];
    }
    return self;
}

- (void) setup_cards
{
    NSString *font = @"Arial";
    int fontsize = 18;
    
    // Pull in the Cards plist
    NSArray *contentArray = [[NSDictionary 
                              dictionaryWithContentsOfFile:[[NSBundle mainBundle] 
                                                            pathForResource:@"Cards" 
                                                            ofType:@"plist"]
                              ] objectForKey:@"Powerups"];
    
    NSMutableArray *cards = [NSMutableArray arrayWithCapacity:[contentArray count]];
    
    for (int i = 0; i <[contentArray count]; i++ )
    {
        // Grab the powerup contents
        NSDictionary *dict = [contentArray objectAtIndex:i]; //name, description, cost, unlocked, image
        
        // Set up a new layer for the card
        CCLayer *card = [CCLayer node];
        
        // Set up the background image for the card
        CCSprite *image = [CCSprite spriteWithFile:@"card.png"];
        image.position = ccp ( screenSize.width/2, screenSize.height/2 );
        [card addChild:image];
        
        // Show title
        CCLabelTTF *label_name = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@",[dict valueForKey:@"Name"]] fontName:font fontSize:fontsize];
        [label_name setPosition:ccp ( 320/2,480/2 )];
        [card addChild:label_name];
        
        // buttons for equip or purchase
        CCMenuItem *btn_equip = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"Equip" fontName:font fontSize:fontsize] target:self selector:@selector(tap_equip:)];
        CCMenuItem *btn_buy = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"Purchase" fontName:font fontSize:fontsize] target:self selector:@selector(tap_buy:)];    
        CCMenuItem *btn_demo = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"Demo" fontName:font fontSize:fontsize] target:self selector:@selector(tap_demob:)];    
        btn_equip.tag = i;
        btn_buy.tag = i;
        btn_buy.userObject = [NSNumber numberWithInt:100];
        btn_demo.tag = i;
        
        if ( [[user.items objectAtIndex:i] intValue] == 1 )
        {
            btn_buy.visible = FALSE;
            btn_equip.visible = TRUE;
            btn_demo.visible = FALSE;
            
            btn_equip.visible = (user.powerup == i ? FALSE : TRUE );
        }
        else 
        {
            btn_buy.visible = TRUE;
            btn_equip.visible = FALSE;
            btn_demo.visible = TRUE;
        }
        
        if ( i == 0 )
        {
            btn_buy.visible = FALSE;
            btn_demo.visible = FALSE;
            btn_equip.visible = (user.powerup == i ? FALSE : TRUE );
        }
        
        // Place the menu on the screen
        CCMenu *menu = [CCMenu menuWithItems:btn_equip, btn_buy, btn_demo, nil];
        [menu alignItemsHorizontallyWithPadding:20];
        menu.position = ccp ( screenSize.width/2, 80 );
        [card addChild:menu];
        
        // Add the card object to the array
        [cards addObject:card];
    }

    // Place the scroller
    CCScrollLayer *scroller = [[CCScrollLayer alloc] initWithLayers:cards widthOffset: 20];
    [self addChild:scroller];
}

- (void) tap_equip:(CCMenuItem*)sender
{
    user.powerup = sender.tag;
    [user sync];
}

- (void) tap_buy:(CCMenuItem*)sender
{
    CCLOG(@"TAPPED BUY | TODO: SET UP BUY");    
    int cost = [sender.userObject intValue];
    if ( user.collected >= cost )
    {
        user.collected -= cost;
        [user buyItem:sender.tag];
        [user sync];
    }
    else 
    {
        CCLOG(@"NOT ENOUGH MONEY");
    }
}

- (void) tap_demo:(id)sender
{
    CCLOG(@"PLAY A DEMO VIDEO OF THE POWERUP IN ACTION");
}

@end