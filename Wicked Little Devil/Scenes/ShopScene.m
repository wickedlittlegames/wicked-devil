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

-(void)buttonTapped:(id)sender
{
	NSLog(@"buttonTapped");
}


-(id) init
{
    if( (self=[super init]) ) {
        CCLOG(@"DOING");
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        appDelegate                 = (AppController*)[[UIApplication sharedApplication] delegate];
        
        view  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 480)];
        table = [[UITableView alloc] initWithFrame:CGRectMake(100, 100, 300, 300)];
        data = [NSArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];        
        table.dataSource = self;
        table.delegate   = self;
        [view addSubview:table];
        [appDelegate.window addSubview:view];
        
        
        //User *user = [User alloc];
        CCMenuItem *back = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"BACK" fontName:@"Marker Felt" fontSize:20] target:self selector:@selector(tap_back)];
        CCMenu *menu = [CCMenu menuWithItems:back, nil];
        menu.position = ccp ( screenSize.width - 80, 10 );
        [self addChild:menu];
        
        CCLOG(@"DOING");        
    }
    return self;
}

- (void) tap_back
{
    [view removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];
}

#pragma mark UITableView code

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [data count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
	if(cell == nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    
    cell.textLabel.text = [data objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"platform-normal.png"];
    
    return cell;
}


@end
