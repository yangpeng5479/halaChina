//
//  GDForumViewController.h
//  Greadeal
//
//  Created by Elsa on 16/6/11.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

#import "MORefreshTableHeaderView.h"

@interface GDForumViewController : UIViewController<UIWebViewDelegate, NJKWebViewProgressDelegate,UIScrollViewDelegate>

{
    UIWebView              *_webView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress     *_progressProxy;
    
    MORefreshTableHeaderView *refreshHeaderView;
    
    NSString* webUrl;
    
    BOOL     reloading;
    BOOL     checkForRefresh;
}

- (id)init;


@end
