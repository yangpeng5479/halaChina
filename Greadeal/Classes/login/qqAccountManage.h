//
//  qqAccountManage.h
//  haomama
//
//  Created by tao tao on 01/06/13.
//  Copyright (c) 2013年 tao tao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/TencentApiInterface.h>

@interface qqAccountManage : NSObject <TencentSessionDelegate>
{
    TencentOAuth* tencentOAuth;
    NSDictionary* paras;
}

+ (qqAccountManage*)sharedInstance;
- (TencentOAuth*)getTencent;

- (NSString*)getAppid;

- (BOOL)qqAuthValid;
- (void)loginQQ;
- (void)Logout;

- (void)clickQQGetUserInfo;
- (void)clickAddShare:(NSDictionary*)parameters;
- (void)setShareContent:(NSDictionary*)parameters;

- (BOOL)isInstalled;

@end
