//
//  StatsScene.m
//  Wicked Little Devil
//
//  Created by Andrew Girvan on 13/07/2012.
//  Copyright 2012 Wicked Little Websites. All rights reserved.
//

#import "StatsScene.h"


@implementation StatsScene

+(CCScene *) scene
{
    // Create a Scene
	CCScene *scene = [CCScene node];
    
    // Grab the layers
	StatsScene *current = [StatsScene node];
    
    // Fill the scene
	[scene addChild:current];
    
    // Show the scene
	return scene;
}

-(id) init
{
    if( (self=[super init]) ) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        NSString *font = @"Marker Felt";
        int fontsize = 18;
        
        user = [[User alloc] init];
        
        app = (AppController*)[[UIApplication sharedApplication] delegate];
        view  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 450)];
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 450)];
        data = [NSArray arrayWithObjects:@"Stat 1", @"Stat 2", nil];
        
        table.dataSource = self;
        table.delegate   = self;
        [view addSubview:table];
        [app.window addSubview:view];
        
        CCMenuItem *back = [CCMenuItemFont itemWithLabel:[CCLabelTTF labelWithString:@"BACK" fontName:font fontSize:fontsize] target:self selector:@selector(tap_back)];
        CCMenu *menu_back = [CCMenu menuWithItems:back, nil];
        menu_back.position = ccp ( screenSize.width - 80, 10 );
        [self addChild:menu_back z:100]; 
    }
    return self;
}

- (void) tap_back
{
    [view removeFromSuperview];
    [[CCDirector sharedDirector] replaceScene:[LevelSelectScene scene]];
}


#pragma mark UITableView code

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Stats";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [data count];
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) 
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SimpleTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;    
    cell.textLabel.text = [data objectAtIndex:indexPath.row];
    
    return cell;
}



@end
