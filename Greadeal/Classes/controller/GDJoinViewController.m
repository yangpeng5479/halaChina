//
//  GDJoinViewController.m
//  Greadeal
//
//  Created by Elsa on 16/6/11.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDJoinViewController.h"
#import "RDVTabBarController.h"

#import "GDLoginViewController.h"
#import "GDRegsiterViewController.h"

#import "UIActionSheet+Blocks.h"

@interface GDJoinViewController ()

@end

@implementation GDJoinViewController

- (id)init:(NSString*)url
{
    self = [super init];
    if (self)
    {
        originWebUrl = url;
        
        firstLoading = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPage) name:kNotificationJoinActivity object:nil];

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

-(void)reloadPage
{
    NSString* web_url = [NSString stringWithFormat:@"%@&token=%@&language_id=%d&app=ios",originWebUrl,[GDPublicManager instance].token,[[GDSettingManager instance] language_id:NO]];
  
    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:web_url]];
    [_webView loadRequest:req];
}

-(void)loadPage
{
    NSString* web_url = [NSString stringWithFormat:@"%@&token=%@&language_id=%d&app=ios",originWebUrl,[GDPublicManager instance].token,[[GDSettingManager instance] language_id:NO]];
    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:web_url]];
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
    
    if (url.query!=nil)
    {
    NSRange findsuccess = [url.query rangeOfString:@"route=app/login"];
    if (findsuccess.location != NSNotFound)
    {
        [UIActionSheet showInView:self.view
                        withTitle:NSLocalizedString(@"Please login first and check out", @"您还没有登录,请先登录再购买")
                cancelButtonTitle:NSLocalizedString(@"Cancel",@"取消")
           destructiveButtonTitle:nil
                otherButtonTitles:@[NSLocalizedString(@"Login", @"登录"), NSLocalizedString(@"Sign Up", @"注册")]
                         tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                             if (buttonIndex==0)
                             {
                                 GDLoginViewController* vc = [[GDLoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
                                 
                                 UINavigationController *nc = [[UINavigationController alloc]
                                                               initWithRootViewController:vc];
                                 
                                 [self presentViewController:nc animated:YES completion:^(void) {}];
                             }
                             else if (buttonIndex==1)
                             {
                                 GDRegsiterViewController* vc = [[GDRegsiterViewController alloc] initWithStyle:UITableViewStyleGrouped];
                                 UINavigationController *nc = [[UINavigationController alloc]
                                                               initWithRootViewController:vc];
                                 
                                 [self presentViewController:nc animated:YES completion:^(void) {}];
                             }
                         }];
        
         return NO;
        
    }
    else
    {
        NSRange findsuccess = [url.query rangeOfString:@"route=app/joined"];
        if (findsuccess.location != NSNotFound)
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Done", @"完成")
                               message:nil
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
             {
                 if (buttonIndex == [alertView cancelButtonIndex]) {
                     [self.navigationController popViewControllerAnimated:YES];
                 }
             }];
            return NO;
        }
        else
        {
            NSRange findsuccess = [url.query rangeOfString:@"route=app/joinexist"];
            if (findsuccess.location != NSNotFound)
            {
                [UIAlertView showWithTitle:NSLocalizedString(@"Note", @"注意")
                                   message:NSLocalizedString(@"You have already joined in.", @"您已经报名")
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
                 {
                     if (buttonIndex == [alertView cancelButtonIndex]) {
                         [self.navigationController popViewControllerAnimated:YES];
                     }
                 }];
                return NO;
            }
        }
    }
    }
    
    return YES;
}

@end
