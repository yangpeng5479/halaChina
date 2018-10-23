//
//  GDJoinViewController.h
//  Greadeal
//
//  Created by Elsa on 16/6/11.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

@interface GDJoinViewController : UIViewController<UIWebViewDelegate, NJKWebViewProgressDelegate>

{
    UIWebView *_webView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    
    NSString* originWebUrl;
    
    BOOL  firstLoading;
}

- (id)init:(NSString*)url;


@end
