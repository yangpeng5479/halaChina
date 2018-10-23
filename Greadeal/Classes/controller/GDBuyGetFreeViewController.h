//
//  GDBuyGetFreeViewController.h
//  Greadeal
//
//  Created by Elsa on 16/4/7.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

@interface GDBuyGetFreeViewController : UIViewController<UIWebViewDelegate, NJKWebViewProgressDelegate>

{
    UIWebView *_webView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    
    NSString* webUrl;
    
    BOOL  firstLoading;
}

- (id)init:(NSString*)url;

@end
