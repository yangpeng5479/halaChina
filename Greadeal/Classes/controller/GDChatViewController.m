//
//  GDChatViewController.m
//  Greadeal
//
//  Created by Elsa on 15/7/4.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDChatViewController.h"
#import "RDVTabBarController.h"

@interface GDChatViewController ()

@end

@implementation GDChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = NSLocalizedString(@"Chat", @"对话");
    
    CGRect r = self.view.bounds;
    r.size.height -= 64;
    mainWebview = [[UIWebView alloc] initWithFrame:r];
    [self.view addSubview:mainWebview];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://chat16.live800.com/live800/chatClient/chatbox.jsp?companyID=528997&configID=73398&jid=7850899617"]]; // 定义请求地址
    [mainWebview loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}


@end
