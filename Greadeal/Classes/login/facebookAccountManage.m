//
//  facebookAccountManage.m
//  Greadeal
//
//  Created by Elsa on 15/5/22.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "facebookAccountManage.h"

@implementation facebookAccountManage

@synthesize userInfo;

+ (facebookAccountManage*)sharedInstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (id) init {
    if (self = [super init]) {
        LOG(@"init facebookAccountManage");
    }
    return self;
}

-(void)login
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"email"] fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            if (error) {
                LOG(@"Failed to login:%@", error);
                return;
            }
        } else if (result.isCancelled) {
            // Handle cancellations
            LOG(@"User was cancelled");
            return;
        } else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if ([result.grantedPermissions containsObject:@"email"]) {
                // Do work
                [self getUserInfo];
            }
            else
            {
                // Show alert
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login Failed",@"登录失败")
                                                                    message:NSLocalizedString(@"You must login and grant access to your email to use this feature",@"您必须登录才能使用这个功能.")
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
    }];
}

-(void)getPublishPermissions
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithPublishPermissions:@[@"publish_actions"] fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            if (error) {
                LOG(@"Failed to login:%@", error);
                return;
            }
        } else if (result.isCancelled) {
            // Handle cancellations
            LOG(@"User was cancelled");
            return;
        } else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if ([result.grantedPermissions containsObject:@"publish_actions"]) {
                // Do work
                [self shareWithoutDialog:nil];
            }
            else
            {
                // Show alert
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login Failed",@"登录失败")
                                                        message:NSLocalizedString(@"You must grant access to your publish actions to use this feature",@"您必须授权发贴权限才能使用这个功能.")
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
    }];

}

-(void)logout
{
    if ([FBSDKAccessToken currentAccessToken]) {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logOut];
    }
}

-(void)getUserInfo
{
    if ([FBSDKAccessToken currentAccessToken]) {
        
        //[ProgressHUD show:nil];
        
        NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
        [parameters setValue:@"id,name,email" forKey:@"fields"];
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 [ProgressHUD show:nil];
                 
                 LOG(@"fetched user:%@", result);
                 userInfo = result;
                 NSString* email = @"";
                 SET_IF_NOT_NULL(email, userInfo[@"email"]);
                 
                 [GDPublicManager instance].username = userInfo[@"name"];
                 [GDPublicManager instance].email = email!=nil?email:@"";
                 [GDPublicManager instance].loginstauts = FACEBOOK;
               
                 NSString* fbToken = [FBSDKAccessToken currentAccessToken].tokenString;
                 
                 NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/customer/login_from_open_platform"];
                 AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                 manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
                 
                 NSDictionary *parameters = @{@"open_platform":@"facebook",@"open_id":userInfo[@"id"],@"open_name":userInfo[@"name"],@"open_token":fbToken,@"open_email":email!=nil?email:@""};
                 
                [manager POST:url
                    parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
                  {
                      LOG(@"JSON: %@", responseObject);
                      int status = [responseObject[@"status"] intValue];
                      if (status==1)
                      {
                          NSDictionary *dictData = responseObject[@"data"];
                          
                          int customer_id = [dictData[@"customer_id"] intValue];
                          //NSString* useremail = dictData[@"email"];
                          //NSString* fname = dictData[@"fname"];
                          int point = [dictData[@"point"] intValue];
                          NSString* phonecode   = @"";
                          SET_IF_NOT_NULL(phonecode, dictData[@"telephone_area_code"]);
                          NSString* phone = dictData[@"telephone"];
                          NSString* token = dictData[@"token"];
                          
                          NSDictionary* setting = dictData[@"setting"];
                          int receive_notice = [setting[@"receive_notice"] intValue];
                          
                          [GDPublicManager instance].cid = customer_id;
                          [GDPublicManager instance].point = point;
                          [GDPublicManager instance].receive_notice = receive_notice;
                          
                          [GDPublicManager instance].token    = token;
                          [GDPublicManager instance].phonenumber = phone;
                          [GDPublicManager instance].phoneCountry = phonecode;
                          
                          [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidLoginSuccess object:nil userInfo:nil];
                         
                      }
                      else
                      {
                          NSString *errorInfo =@"";
                          SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
                          LOG(@"errorInfo: %@", errorInfo);
                          [ProgressHUD showError:errorInfo];
                      }
                      [ProgressHUD dismiss];
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
                  {
                      [ProgressHUD dismiss];
                      LOG(@"error: %@", error.localizedDescription);
                  }];
                
             }
         }];
    }
}

- (void)shareWithoutDialog:(FBSDKShareLinkContent*)content;
{
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"])
    {
        // TODO: publish content.
        FBSDKShareLinkContent *acontent = [[FBSDKShareLinkContent alloc] init];
        acontent.contentURL = [NSURL URLWithString:@"https://developers.facebook.com/"];
        acontent.contentTitle = @"Rock, Papers, Scissors Sample Application";
content.imageURL   = [NSURL URLWithString:@"http://media1.s-nbcnews.com/i/newscms/2014_11/252371/140314-facebook-illustration-jsw-1007a_8e6c9f0c83f147f21eafd39eb07cc0d9.JPG"];
        
         [FBSDKShareAPI shareWithContent:acontent delegate:self];
    }
    else
    {
        [self getPublishPermissions];
    }
}

- (void)shareWithDialog:(FBSDKShareLinkContent*)content
{
    FBSDKShareLinkContent *acontent = [[FBSDKShareLinkContent alloc] init];
    content.imageURL   = [NSURL URLWithString:@"http://media1.s-nbcnews.com/i/newscms/2014_11/252371/140314-facebook-illustration-jsw-1007a_8e6c9f0c83f147f21eafd39eb07cc0d9.JPG"];
    acontent.contentURL = [NSURL URLWithString:@"https://developers.facebook.com/"];
    acontent.contentTitle = @"Rock, Papers, Scissors Sample Application";

   UIViewController* currNV = [UIApplication sharedApplication].keyWindow.rootViewController;
   
    if ([FBSDKAccessToken currentAccessToken])
    {
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.fromViewController = currNV;
    dialog.shareContent = acontent;
    dialog.mode = FBSDKShareDialogModeShareSheet;
    [dialog show];
    }
}

#pragma mark - FBSDKSharingDelegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    LOG(@"Posted OG action with id: %@", results[@"postId"]);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    LOG(@"Error: %@", error.description);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    LOG(@"Canceled share");
}
@end
