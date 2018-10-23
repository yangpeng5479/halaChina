//
//  MOConvention.m
//  Morange
//
//  Created by Yixiang Lu on 1/31/10.
//  Copyright 2010 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOUtilities.h"

UINavigationController* MONavigationController(UIViewController *root, BOOL flat, BOOL translucent)
{
	UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:root];
	//!!!XCode5+iOS7 Trick: MUST set to NO, otherwise the screen will be offset towards the top!!!
	nav.navigationBar.translucent = translucent;
//	if(flat)
//		[nav.navigationBar configureFlatNavigationBarWithColor:MOColorMediaButton() borderColor:MOColorAlto()];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        nav.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)nav;
    }
	return nav;
}

UITableView* MOCreateTableView(CGRect frame, UITableViewStyle style, Class c)
{
	UITableView *tableView = [[c alloc] initWithFrame:frame style:style];

	MOInitTableView(tableView);

	return tableView;
}

void MOInitTableView(UITableView *tableView)
{
    tableView.backgroundColor = MOColorAppBackgroundColor();
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    tableView.separatorColor = [UIColor colorWithRed:246/255.0f green:246/255.0f blue:246/255.0f alpha:1];
    
	if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
	{
		if(tableView.style == UITableViewStyleGrouped)
		{
			tableView.sectionHeaderHeight = 4;
			tableView.sectionFooterHeight = 4;
            
            tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,tableView.bounds.size.width, 8)];
            tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,tableView.bounds.size.width, 4)];
            //MODebugLayer(tableView.tableFooterView, 1.f, [UIColor redColor].CGColor);
           
            //tableView.backgroundColor = MOColorSaleProductBackgroundColor();
			//tableView.contentInset = UIEdgeInsetsMake(-15, 0, 0, 0);
		}
		//For non-grouped style, avoid the separator offset.
		else
		{
			//To avoid offsetting the line-start in separator in iOS7.
			[tableView setSeparatorInset:UIEdgeInsetsZero];
            
            UIView *view =[ [UIView alloc]init];
            view.backgroundColor = [UIColor clearColor];
            tableView.tableFooterView = view;
		}
	}
}

UILabel* MOCreateLabelAutoRTL()
{
	UILabel *tableSectionTitle = [[UILabel alloc] init];
	if([GDSettingManager instance].isRightToLeft)
	{
		tableSectionTitle.textAlignment = NSTextAlignmentRight;
	}
	else
	{
		tableSectionTitle.textAlignment = NSTextAlignmentLeft;
	}
	return tableSectionTitle;
}

UIFont* MOLightFont(CGFloat flontSize)
{
    return [UIFont fontWithName:@"ArialMT" size:flontSize];
}

UIFont* MOBlodFont(CGFloat flontSize)
{
    return [UIFont fontWithName:@"Arial-BoldMT" size:flontSize];
}
