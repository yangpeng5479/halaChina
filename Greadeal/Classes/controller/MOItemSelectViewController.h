//
//  MOItemSelectViewController.h
//  Mozat
//
//  Created by taotao on 7/13/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOItemSelectViewController : UITableViewController
{
	id			 target;
	SEL			 callback;
	
	NSDictionary *showDict;
    NSArray      *indexList;
    
	NSString     *currentKey;
	
	NSArray  *keyArray;
}

- (id)initWithStyle:(UITableViewStyle)style withDict:(NSDictionary *)aDict value:(NSString*)aKey target:(id)aTarget action:(SEL)action withTitle:(NSString*)aTitle;

@end
