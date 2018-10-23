//
//  qqAccountManage.m
//  haomama
//
//  Created by tao tao on 01/06/13.
//  Copyright (c) 2013年 tao tao. All rights reserved.
//

#import "qqAccountManage.h"
#import <TencentOpenAPI/TencentOAuthObject.h>
#import "TencentOpenAPI/QQApiInterface.h"

static NSString *appId = @"1104682307";
static NSString *appkey = @"54llLVQrnwPNEpYu";

@implementation qqAccountManage

+ (qqAccountManage*)sharedInstance;
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (id) init {
	if (self = [super init]) {
		LOG(@"init qqAccountManage");
        ///////////////////////////////////sina weibo///////////////////////////////////////////////////////////////
        tencentOAuth = [[TencentOAuth alloc] initWithAppId:appId
                                                andDelegate:self];
	}
	return self;
}

- (TencentOAuth*)getTencent
{
    return tencentOAuth;
}

- (BOOL)qqAuthValid
{
    LOG(@"tencentOAuth.expirationDate=%@",tencentOAuth.expirationDate);
    if (tencentOAuth.isSessionValid)
        return YES;
    else
    {
        //[self Logout];
        return NO;
    }
    
//    if (tencentOAuth.accessToken
//        && [tencentOAuth.accessToken length]>0)
//        return YES;
//    return NO;
}

- (NSString*)getAppid
{
    return appId;
}

- (void)loginQQ
{
    NSArray* _permissions;
    _permissions = [NSArray arrayWithObjects:
                    kOPEN_PERMISSION_GET_USER_INFO,
                    kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                //    kOPEN_PERMISSION_ADD_ALBUM,
                 //   kOPEN_PERMISSION_ADD_IDOL,
                    kOPEN_PERMISSION_ADD_ONE_BLOG,
                    kOPEN_PERMISSION_ADD_PIC_T,
                    kOPEN_PERMISSION_ADD_SHARE,
                    kOPEN_PERMISSION_ADD_TOPIC,
                  //  kOPEN_PERMISSION_CHECK_PAGE_FANS,
                  //  kOPEN_PERMISSION_DEL_IDOL,
                  //  kOPEN_PERMISSION_DEL_T,
                  //  kOPEN_PERMISSION_GET_FANSLIST,
                  //  kOPEN_PERMISSION_GET_IDOLLIST,
                    kOPEN_PERMISSION_GET_INFO,
                  //  kOPEN_PERMISSION_GET_OTHER_INFO,
                  //  kOPEN_PERMISSION_GET_REPOST_LIST,
                  //  kOPEN_PERMISSION_LIST_ALBUM,
                   // kOPEN_PERMISSION_UPLOAD_PIC,
                   // kOPEN_PERMISSION_GET_VIP_INFO,
                   // kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                   // kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                   // kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO,
                    nil];
    
    [tencentOAuth authorize:_permissions inSafari:NO];
    
}

- (void)Logout
{
    [tencentOAuth logout:self];
}

- (BOOL)isInstalled
{
    return [TencentOAuth iphoneQQInstalled];
}

- (void)showInvalidTokenOrOpenIDMessage
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"failed to call QQ API", @"QQ API 调用失败") message:NSLocalizedString(@"The OAuth expired, please try again",@"可能授权已过期，请重新获取") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"确定") otherButtonTitles:nil, nil];
    [alert show];
}

- (void)clickQQGetUserInfo {
	if(![tencentOAuth getUserInfo]){
        [self showInvalidTokenOrOpenIDMessage];
    }
}

- (void)setShareContent:(NSDictionary*)parameters
{
    paras = parameters;
}

- (void)clickAddShare:(NSDictionary*)parameters {
    
    NSURL *previewURL = [NSURL URLWithString:parameters[@"paramImages"]];
    
    NSURL* url;
    if (parameters[@"paramUrl"]!=nil)
    {
        url = [NSURL URLWithString:parameters[@"paramUrl"]];
    }
    else
    {
        url = [NSURL URLWithString:MainWebPage];
    }
    
    
    QQApiNewsObject* imgObj = [QQApiNewsObject objectWithURL:url title:parameters[@"paramTitle"] description:parameters[@"paramSummary"]previewImageURL:previewURL];
    
    [imgObj setCflag:kQQAPICtrlFlagQQShare];
    
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:imgObj];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    
    [self handleSendResult:sent];

    
//    TCAddShareDic *params = [TCAddShareDic dictionary];
//    params.paramTitle = parameters[@"paramTitle"];
//    params.paramComment = parameters[@"paramComment"];
//    params.paramSummary =  parameters[@"paramSummary"];
//    params.paramImages = parameters[@"paramImages"];
//
//    if (parameters[@"url"]!=nil)
//    {
//        params.paramUrl = parameters[@"paramUrl"];
//    }
//    else
//    {
//        params.paramUrl = MainWebPage;
//    }

//	if(![tencentOAuth addShareWithParams:params]){
//        [self showInvalidTokenOrOpenIDMessage];
//    }
}

#pragma mark - qq delegate
- (void)tencentDidLogin {
	// 登录成功
    if (tencentOAuth.isSessionValid)
    {
        LOG(@"qq token= %@",tencentOAuth.accessToken);
        [tencentOAuth getUserInfo];
    }
    else
    {
        [ProgressHUD showError:NSLocalizedString(@"QQ Login Failed!",@"QQ登录失败!")];
    }
}


/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)tencentDidNotLogin:(BOOL)cancelled
{
	if (cancelled){
		LOG(@"用户取消登录");
	}
	else {
		LOG(@"登录失败");
	}
	
}

/**
 * Called when the notNewWork.
 */
-(void)tencentDidNotNetWork
{
	LOG(@"无网络连接，请设置网络");
}

/**
 * Called when the logout.
 */
-(void)tencentDidLogout
{
	LOG(@"退出登录成功，请重新登录");
}

/**
 * Called when the get_user_info has response.
 */

- (void)getUserInfoResponse:(APIResponse*) response {
	if (response.retCode == URLREQUEST_SUCCEED)
	{
//		NSMutableString *str=[NSMutableString stringWithFormat:@""];
//		for (id key in response.jsonResponse) {
//			[str appendString: [NSString stringWithFormat:@"%@:%@\n",key,[response.jsonResponse objectForKey:key]]];
//		}
        LOG(@"%@",response.jsonResponse);
        
        NSString* open_id = tencentOAuth.openId;
        NSString* open_token = tencentOAuth.accessToken;
        NSString* nickname = response.jsonResponse[@"nickname"];
        
        [GDPublicManager instance].username = nickname;
        [GDPublicManager instance].loginstauts = QQ;
        
        NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/customer/login_from_open_platform"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
        
        NSDictionary *parameters = @{@"open_platform":@"qq",@"open_id":open_id,@"open_name":nickname,@"open_token":open_token};
        
        [ProgressHUD show:nil];
        
        [manager POST:url
           parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             [ProgressHUD dismiss];
             LOG(@"JSON: %@", responseObject);
             int status = [responseObject[@"status"] intValue];
             if (status==1)
             {
                 NSDictionary *dictData = responseObject[@"data"];
                 
                 int customer_id = [dictData[@"customer_id"] intValue];
                
                 int point = [dictData[@"point"] intValue];
                 NSString* phonecode   = @"";
                 SET_IF_NOT_NULL(phonecode, dictData[@"telephone_area_code"]);
                 NSString* phone = dictData[@"telephone"];
                 NSString* token = dictData[@"token"];
                 [GDPublicManager instance].email = dictData[@"email"];
                 NSDictionary* setting = dictData[@"setting"];
                 int receive_notice = [setting[@"receive_notice"] intValue];
                 
                 [GDPublicManager instance].cid   = customer_id;
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
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             LOG(@"error: %@", error.localizedDescription);
             [ProgressHUD dismiss];
         }];

	}
	else
    {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"操作失败") message:[NSString stringWithFormat:@"%@", response.errorMsg]
							  
													   delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"确定") otherButtonTitles: nil];
		[alert show];
        
	}
}

/**
 * Called when the add_share has response.
 */
- (void)addShareResponse:(APIResponse*) response {
	if (response.retCode == URLREQUEST_SUCCEED)
	{
		NSMutableString *str=[NSMutableString stringWithFormat:@""];
		for (id key in response.jsonResponse) {
			[str appendString: [NSString stringWithFormat:@"%@:%@\n",key,[response.jsonResponse objectForKey:key]]];
		}
        [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"操作失败") message:[NSString stringWithFormat:@"%@", response.errorMsg]
							  
													   delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"确定")otherButtonTitles: nil];
		[alert show];
        
	}
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        case EQQAPIQQNOTINSTALLED:
        case EQQAPIQQNOTSUPPORTAPI:
        case EQQAPISENDFAILD:
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"QQ API call failured", @"QQ API 调用失败") message:NSLocalizedString(@"The OAuth expired, please try again",@"可能授权已过期，请重新获取") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"确定") otherButtonTitles:nil, nil];
            [alert show];
            
            break;
        }
        default:
        {
            break;
        }
    }
}

@end
