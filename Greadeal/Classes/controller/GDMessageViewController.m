//
//  MOEditTaglineViewController.m
//  Mozat
//
//  Created by taotao on 7/13/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import "GDMessageViewController.h"
#import "RDVTabBarController.h"

#define kCellHeight   200

@interface GDMessageViewController ()

@end

@implementation GDMessageViewController

- (void)saveEdit
{
    if ([target respondsToSelector:callback])
    {
        [target performSelector:callback withObject:inputTextView.text afterDelay:0];
    }
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [inputTextView becomeFirstResponder];
    [self configureBackBarButton];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
}

- (id)init:(id)aTarget action:(SEL)action
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Message", @"留言");
        
		self.view.backgroundColor = MOColorAppBackgroundColor();
		
		target = aTarget;
		callback = action;
		
		inputTextView = [[UICharCountingTextView alloc] initWithFrame:CGRectMake(10, 10, 300*[GDPublicManager instance].screenScale, kCellHeight)];
		inputTextView.backgroundColor = [UIColor clearColor];
		inputTextView.clipsToBounds = YES;
		inputTextView.delegate = self;
		inputTextView.placeholder = NSLocalizedString(@"Special Cooking Instructions", @"特殊烹调方式");
		inputTextView.maxNumberOfCharacter = 280;
        
	  	[self.view addSubview:inputTextView];
		
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"") style:UIBarButtonItemStylePlain
            target:self
            action:@selector(saveEdit)];
        
    }
    return self;
}

- (void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
