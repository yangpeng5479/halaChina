//
//  MODayViewController.m
//  Mozat
//
//  Created by taotao on 7/13/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import "MODayViewController.h"
#import "RDVTabBarController.h"

@interface MODayViewController ()

@end

@implementation MODayViewController

- (void)saveEdit
{
    if ([target respondsToSelector:callback])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *destDateString = [dateFormatter stringFromDate:datePicker.date];
        
        //check select date is unavailable
        BOOL isGood = YES;
        if (date_unavailable.count>0)
        {
            for (NSString* undate in date_unavailable)
            {
                if ([undate isEqualToString:destDateString])
                {
                    isGood = NO;
                    break;
                }
            }
        }
        
        if (isGood)
        {
            [target performSelector:callback withObject:destDateString afterDelay:0];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Note",@"注意")
                               message:NSLocalizedString(@"Oops! The hotel is fully booked for the date you selected, please choose another date!", @"您选择的日期，酒店已经没有空房间，请选择其他日期!")
                     cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
             {
                }];

        }
    }
	
}

- (void)exit
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (NSDate *)logicalOneYearAgo:(NSDate *)from withYear:(int)subYear {
	
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear:-subYear];
	
    return [gregorian dateByAddingComponents:offsetComponents toDate:from options:0];
	
}

- (id)init:(id)aTarget action:(SEL)action withUnavailable:(NSMutableArray*)dateunavailable withEnddate:(NSString*)endDate
{
    self = [super init];
    if (self) {
        // Custom initialization
		self.title = NSLocalizedString(@"Choose Date",@"选择日期");
        self.view.backgroundColor = MOColorAppBackgroundColor();
		target = aTarget;
		callback = action;
		
        date_unavailable  = dateunavailable;
        enddate =  endDate;
        
		datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
		datePicker.datePickerMode = UIDatePickerModeDate;
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd"];
		
		datePicker.maximumDate=[dateFormatter dateFromString:enddate];
		datePicker.minimumDate=[self logicalOneYearAgo:[NSDate date] withYear:0];
    	
        [datePicker setDate:[NSDate date]];
		
		[self.view addSubview:datePicker];
		self.hidesBottomBarWhenPushed = YES;
        
        
        ACPButton *editBut = [ACPButton buttonWithType:UIButtonTypeCustom];
        editBut.frame = CGRectMake(10, 250, self.view.bounds.size.width-20, 40);
        [editBut setStyleRedButton];
        [editBut setTitle: NSLocalizedString(@"Save", @"保存") forState:UIControlStateNormal];
        [editBut addTarget:self action:@selector(saveEdit) forControlEvents:UIControlEventTouchUpInside];
        [editBut setLabelFont:MOLightFont(16)];
        [self.view addSubview:editBut];

		
	}
    return self;
}

- (void)dealloc
{
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    [self configureBackBarButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [ProgressHUD dismiss];
    [super viewWillDisappear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
