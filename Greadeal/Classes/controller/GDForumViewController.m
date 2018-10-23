//
//  GDForumViewController.m
//  Greadeal
//
//  Created by Elsa on 16/6/11.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDForumViewController.h"
#import "RDVTabBarController.h"

#import "GDLoginViewController.h"
#import "GDRegsiterViewController.h"

#import "UIActionSheet+Blocks.h"

#define kRefreshkShowAll        60

@interface GDForumViewController ()

@end

@implementation GDForumViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.title = NSLocalizedString(@"Explore", @"发现");
        
        reloading = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPage) name:kNotificationJoinActivity object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPage) name:kNotificationDidLogout object:nil];

    CGRect r = self.view.bounds;
    r.size.height=r.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height-44;
    
    r.origin.y = [[UIApplication sharedApplication] statusBarFrame].size.height;
   
    
    _webView = [[UIWebView alloc]initWithFrame:r];
    [self.view addSubview:_webView];
     MODebugLayer(_webView, 1.f, [UIColor blueColor].CGColor);
    self.view.backgroundColor = [UIColor blackColor];
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _webView.scrollView.delegate = self;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPage) name:kNotificationDidLoginSuccess object:nil];
    
    [self addRefreshUI];
    
    [self loadPage];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // Remove progress view
    [ProgressHUD dismiss];
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
}


-(void)loadPage
{
    webUrl = [NSString stringWithFormat:@"%@/index.php?s=/mob/app/index&token=%@",SNSWebPage,[GDPublicManager instance].token];
    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:webUrl]];
    [_webView loadRequest:req];
}

#pragma mark - NJKWebViewProgressDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (!reloading)
    {
        reloading = YES;
        [ProgressHUD show:nil];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (reloading)
    {
        [self stopLoad];
        [ProgressHUD dismiss];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:( NSError *)error;
{
    if (reloading)
    {
        [self stopLoad];
        [ProgressHUD dismiss];
    }
}

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    //self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL* url = request.URL;
    LOG(@"%@,%@,%@,%@,%@,",url.scheme,url.host,url.port,url.parameterString,url.query);
    
    if (url.query!=nil)
    {
    NSRange findsuccess = [url.query rangeOfString:@"s=/mob/app/login.html"];
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
    }
    return YES;
}

- (void)addRefreshUI
{
    refreshHeaderView = [[MORefreshTableHeaderView alloc] init];
    [refreshHeaderView setLastUpdatedDate:[NSDate date]];
    [_webView addSubview:refreshHeaderView];
    
}

- (void)stopLoad
{
    if (reloading)
    {
        reloading = NO;
        [refreshHeaderView  flipImageAnimated:NO];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        [_webView.scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [UIView commitAnimations];
        [refreshHeaderView setStatus:kMOPullToReloadStatus];
        [refreshHeaderView toggleActivityView:NO];
        [refreshHeaderView setLastUpdatedDate:[NSDate date]];
        
        refreshHeaderView.frame = CGRectMake(0.0,-kRefreshkShowAll-[[UIApplication sharedApplication] statusBarFrame].size.height,self.view.frame.size.width, kRefreshkShowAll);
    }
}


#pragma mark scrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
        if (reloading) return;
        
        if (checkForRefresh)
        {
            if (refreshHeaderView.isFlipped
                && scrollView.contentOffset.y > -kRefreshkShowAll-5
                && scrollView.contentOffset.y < 0.0f
                && !reloading) {
                [refreshHeaderView flipImageAnimated:YES];
                [refreshHeaderView setStatus:kMOPullToReloadStatus];
                
            } else if (!refreshHeaderView.isFlipped
                       && scrollView.contentOffset.y < -kRefreshkShowAll-5) {
                [refreshHeaderView flipImageAnimated:YES];
                [refreshHeaderView setStatus:kMOReleaseToReloadStatus];
            }
        }
        
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
        if (!reloading)
        {
            checkForRefresh = YES;  //only check offset when dragging
        }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
        if (!reloading)
        {
            if (scrollView.contentOffset.y <= -kRefreshkShowAll + 10)
            {
                reloading = YES;
                [refreshHeaderView toggleActivityView:YES];
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.2];
                _webView.scrollView.contentInset = UIEdgeInsetsMake(kRefreshkShowAll, 0.0f, 0.0f,0.0f);
                [UIView commitAnimations];
                
                _webView.scrollView.contentOffset=scrollView.contentOffset;
                
                refreshHeaderView.frame = CGRectMake(0.0,0,self.view.frame.size.width, kRefreshkShowAll);
 
                
                [self loadPage];
                
            }
            checkForRefresh = NO;
        }
    
}

@end
