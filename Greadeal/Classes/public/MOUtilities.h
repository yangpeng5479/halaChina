//
//  MOConvention.h
//  Morange
//
//  Created by Yixiang Lu on 1/31/10.
//  Copyright 2010 Mozat. All rights reserved.
//

#import <UIKit/UIKit.h>

UINavigationController* MONavigationController(UIViewController *root, BOOL flat, BOOL translucent);
UITableView* MOCreateTableView(CGRect frame, UITableViewStyle style, Class c);
void MOInitTableView(UITableView* tableView);
UILabel* MOCreateLabelAutoRTL();

UIFont* MOLightFont(CGFloat flontSize);
UIFont* MOBlodFont(CGFloat flontSize);

//!!!Note: Better use macro to avoid str being released while being used.
#define isEmptyString(str) (!str || [str isEqualToString:@""])
