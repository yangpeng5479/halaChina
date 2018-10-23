//
//  GDEtisalatWebViewController.m
//  Greadeal
//
//  Created by Elsa on 16/1/25.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDEtisalatWebViewController.h"
#import "RDVTabBarController.h"

@interface GDEtisalatWebViewController ()

@end

@implementation GDEtisalatWebViewController

@synthesize delegate;

- (id)init:(NSString*)url withPOST:(NSString*)TransactionID
{
    self = [super init];
    if (self)
    {
        webUrl = url;
        transID= TransactionID;
        firstLoading = YES;
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
    [ProgressHUD dismiss];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
}


-(void)loadPage
{
    if (transID.length>0)
    {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: [NSURL URLWithString:webUrl]];
        if (transID.length>0)
        {
            NSString *body = [NSString stringWithFormat: @"TransactionID=%@", transID];
            [request setHTTPMethod: @"POST"];
            [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
        }
        [_webView loadRequest:request];
    }
    else
    {
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:webUrl]];
        [_webView loadRequest:req];
    }
    
}

#pragma mark - NJKWebViewProgressDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (!firstLoading)
    {
        firstLoading = YES;
        [ProgressHUD show:nil];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (firstLoading)
    {
        [ProgressHUD dismiss];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:( NSError *)error;
{
    [ProgressHUD dismiss];
}

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL* url = request.URL;
    LOG(@"%@,%@,%@,%@,%@,",url.scheme,url.host,url.port,url.parameterString,url.query);

    if ([url.scheme isEqualToString:@"http"] && [url.host isEqualToString:@"www.greadeal.com"])
    {
        if ([url.query isEqualToString:@"route=checkout/app_pay_failed"])
        {
            [delegate etisalatCompleted:NO];
            return NO;
        }
        else if ([url.query isEqualToString:@"route=checkout/app_pay_success"])
        {
            [delegate etisalatCompleted:YES];
            return NO;
        }
    }
    return YES;
}

@end
