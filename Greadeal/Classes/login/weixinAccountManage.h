//
//  weixinAccountManage.h
//  haomama
//
//  Created by tao tao on 02/06/13.
//  Copyright (c) 2013年 tao tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

@protocol wechatPayDelegate

- (void)wechatPayCompleted:(BOOL)success;

@end

@interface weixinAccountManage : NSObject <WXApiDelegate>
{
    NSString* access_token;
    NSString* openid;
    NSString* nickname;
}

+ (weixinAccountManage*)sharedInstance;
- (NSString*)getAppid;

//获取预支付订单信息（核心是一个prepayID）
- (void)getPrepayWithOrderName:(NSString*)name
                                         price:(NSString*)price
                                        withNo:(NSString*)TradeNo
                                    withUrl:(NSString*)notifyURL;

- (void)sendMessageToFriend:(NSDictionary*)parameters;
- (void)sendMessageToCycle:(NSDictionary*)parameters;

- (BOOL)isWXInstalled;

- (void)login;

@property (nonatomic, weak) id<wechatPayDelegate>delegate;


@end
