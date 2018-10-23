//
//  facebookAccountManage.h
//  Greadeal
//
//  Created by Elsa on 15/5/22.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface facebookAccountManage : NSObject<FBSDKSharingDelegate>
{
    NSDictionary* userInfo;
}

@property (nonatomic, strong,readonly) NSDictionary* userInfo;

+(facebookAccountManage*)sharedInstance;

-(void)login;
-(void)logout;
-(void)getPublishPermissions;
-(void)getUserInfo;

- (void)shareWithoutDialog:(FBSDKShareLinkContent*)content;
- (void)shareWithDialog:(FBSDKShareLinkContent*)content;

@end

