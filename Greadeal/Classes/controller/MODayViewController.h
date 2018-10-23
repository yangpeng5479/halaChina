//
//  MODayViewController.h
//  Mozat
//
//  Created by taotao on 7/13/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MODayViewController : UIViewController
{
	id			 target;
	SEL			 callback;
	
	UIDatePicker *datePicker;
    
    NSMutableArray *date_unavailable;
    NSString*   enddate;
}

- (id)init:(id)aTarget action:(SEL)action withUnavailable:(NSMutableArray*)dateunavailable withEnddate:(NSString*)endDate;

@end
