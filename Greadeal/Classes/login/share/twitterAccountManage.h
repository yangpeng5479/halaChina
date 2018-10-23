//
//  twitterAccountManage.h
//  Greadeal
//
//  Created by Elsa on 15/5/22.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EasyTwitter.h"

@interface twitterAccountManage : NSObject<EasyTwitterDelegate>

+(twitterAccountManage*)sharedInstance;

- (void)login;
- (void)sendTweetWithImage:(NSString*)message withImage:(NSURL*)url;

@end


