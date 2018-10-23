//
//  GDReturnsViewController.h
//  Greadeal
//
//  Created by Elsa on 15/7/18.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

@interface GDReturnsViewController : UIViewController<UIWebViewDelegate, NJKWebViewProgressDelegate>

{
    UIWebView *_webView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    
    NSString* webUrl;
}

- (id)init:(NSString*)url;

@end
