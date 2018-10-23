//
//  GDReturnsViewController.m
//  Greadeal
//
//  Created by Elsa on 15/7/18.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDReturnsViewController.h"
#import "RDVTabBarController.h"

@interface GDReturnsViewController ()

@end

@implementation GDReturnsViewController

- (id)init:(NSString*)url
{
    self = [super init];
    if (self)
    {
        webUrl   = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect r = self.view.bounds;
    r.size.height=r.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height-self.navigationController.navigationBar.frame.size.height;
    
    _webView = [[UIWebView alloc]initWithFrame:r];
    [self.view addSubview:_webView];
    MODebugLayer(_webView, 1.f, [UIColor redColor].CGColor);
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self loadPage];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    [self.navigationController.navigationBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
     [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
}


-(void)loadPage
{
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:webUrl]];
    [_webView loadRequest:req];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
