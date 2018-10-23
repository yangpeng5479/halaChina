//
//  GDBuyGetFreeViewController.m
//  Greadeal
//
//  Created by Elsa on 16/4/7.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDBuyGetFreeViewController.h"
#import "RDVTabBarController.h"

#import "GDProductDetailsViewController.h"
#import "GDLiveDiscountViewController.h"
#import "GDLiveVendorViewController.h"

#import "UIActionSheet+Blocks.h"

@interface GDBuyGetFreeViewController ()

@end

@implementation GDBuyGetFreeViewController

- (id)init:(NSString*)url
{
    self = [super init];
    if (self)
    {
        webUrl = url;
        
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
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:webUrl]];
    [_webView loadRequest:req];
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

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
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
    
    if (url.query!=nil)
    {
    NSRange   findsuccess = [url.query rangeOfString:@"route=product/"];
        if (findsuccess.location != NSNotFound)
        {
            int productId = [[url.query substringFromIndex:findsuccess.length] intValue];
            
            GDProductDetailsViewController *viewController = [[GDProductDetailsViewController alloc] init:productId withOrder:YES];
            [self.navigationController pushViewController:viewController animated:YES];
        
            return NO;

        }
        else
        {
            findsuccess = [url.query rangeOfString:@"route=category/"];
            if (findsuccess.location != NSNotFound)
            {
                int categoryId = [[url.query substringFromIndex:findsuccess.length] intValue];
            
                GDLiveDiscountViewController* discountVC = [[GDLiveDiscountViewController alloc] init:categoryId  withDrop:YES isDiscount:YES];
                [self.navigationController pushViewController:discountVC animated:YES];

                return NO;
            }
            else
            {
            findsuccess = [url.query rangeOfString:@"route=vendor/"];
            if (findsuccess.location != NSNotFound)
            {
                int vendorId = [[url.query substringFromIndex:findsuccess.length] intValue];
                
                GDLiveVendorViewController * vc = [[GDLiveVendorViewController alloc] init:vendorId withName:@"" withUrl:@"" withImage:@""];
                [self.navigationController pushViewController:vc animated:YES];
                
                return NO;
            }

            }
        }
    }
    return YES;
}



@end
