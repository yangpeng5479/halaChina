//
//  GDEtisalatWebViewController.h
//  Greadeal
//
//  Created by Elsa on 16/1/25.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

@protocol etisalatDelegate

- (void)etisalatCompleted:(BOOL)success;

@end

@interface GDEtisalatWebViewController : UIViewController<UIWebViewDelegate, NJKWebViewProgressDelegate>
{
    UIWebView *_webView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    
    NSString* webUrl;
    NSString* transID;
    
    BOOL  firstLoading;
}

- (id)init:(NSString*)url withPOST:(NSString*)TransactionID;

@property (nonatomic, weak) id<etisalatDelegate>delegate;

@end
