//
//  AppDelegate.m
//  Greadeal
//
//  Created by Elsa on 15/5/8.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "AppDelegate.h"

#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"

//#import "GDSaleViewController.h"
//#import "GDSuperViewController.h"
#import "GDLiveViewController.h"
#import "GDCartViewController.h"
#import "GDMeViewController.h"
//#import "GDMemberViewController.h"

//#import "GDForumViewController.h"

#import "GDIntroViewController.h"

#import "WXApi.h"
#import "PayPalMobile.h"

#import "UMessage.h"

#import "GDProductDetailsViewController.h"
#import "GDLiveVendorViewController.h"

#import "GAI.h"

/******* Set your tracking ID here *******/
static NSString *const kTrackingId = @"UA-84594937-2";

#define UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define _IPHONE80_ 80000


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /////////////////////////////////////////////////////////////////////////////
    [[GAI sharedInstance] trackerWithTrackingId:kTrackingId];
    // Provide unhandled exceptions reports.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    /////////////////////////////////////////////////////////////////////////////
    
    [FBSDKLoginButton class];
    
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSDictionary* configDict = [mainBundle objectForInfoDictionaryKey:@"GDAppConfig"];
    NSString* paypalsandbox =  [configDict objectForKey:@"paypalsandbox"];
    NSString* paypallive =  [configDict objectForKey:@"paypallive"];
    NSString* UMeng =  [configDict objectForKey:@"UMeng"];
    
#if defined MO_DEBUG
    NSString* APIBaseUrl =  [configDict objectForKey:@"APIBaseUrlTest"];
#else
    NSString* APIBaseUrl =  [configDict objectForKey:@"APIBaseUrlLive"];
#endif
    [GDPublicManager instance].APIBaseUrl = APIBaseUrl;
    [GDPublicManager instance].domainUrl =  [configDict objectForKey:@"webUrl"];
    
    [self customizeInterface];
    
    [[GDPublicManager instance] checkCityChange];
    [[GDPublicManager instance] checkDeliveryAddressChange];
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self showWho];
    [self.window makeKeyAndVisible];
  
    [[GDPublicManager instance] getCartData];
    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : paypallive,
                                                           PayPalEnvironmentSandbox : paypalsandbox}];
    
    //set AppKey and LaunchOptions
    [UMessage startWithAppkey:UMeng launchOptions:launchOptions];
    
    UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
    action1.identifier = @"action1_identifier";
    action1.title=@"Accept";
    action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
    
    UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init]; // 第钮
    action2.identifier = @"action2_identifier";
    action2.title=@"Reject";
    action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
    action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
    action2.destructive = YES;
    
    UIMutableUserNotificationCategory *actionCategory = [[UIMutableUserNotificationCategory alloc] init];
    actionCategory.identifier = @"category1";//这组动作的唯一标示
    [actionCategory setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
    
    NSSet *categories = [NSSet setWithObject:actionCategory];
    
    //如果默认使用角标，文字和声音全部打开，请用下面的方法
    [UMessage registerForRemoteNotifications:categories];
    
    // 如果对角标，文字和声音的取舍，请用下面的方法
    UIRemoteNotificationType types7 = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
    UIUserNotificationType types8 = UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge;
    [UMessage registerForRemoteNotifications:categories withTypesForIos7:types7 withTypesForIos8:types8];
    
    //for log
    [UMessage setLogEnabled:NO];
    
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
  
    //[self autoLogin];

    [GDSettingManager instance].switchLanguage = [[GDSettingManager instance] language_id:NO];
    
    pushNotifi = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    ////////////////////////////GOOGLE ANALYTICS//////////////////////////////
    ///////////////////////////////////////////////////////////////////////////
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    //return YES;
}
#pragma mark - Intro

- (void)autoLogin
{
if ([GDPublicManager instance].token.length<=0)
{
    NSMutableDictionary* userdata = [[WCDatabaseManager instance] getUserInfo];
    //NSString* email = [userdata objectForKey:@"useremail"];
    NSString* sha1 = [userdata objectForKey:@"userpass"];
    NSString* phoneCode   = [userdata objectForKey:@"phonecountry"];
    NSString* phoneNumber = [userdata objectForKey:@"userphone"];
   
    int cacheLoginStatus = [[userdata objectForKey:@"loginstatus"] intValue];
    
    if ([FBSDKAccessToken currentAccessToken])//facebook
    {
        [[facebookAccountManage sharedInstance] getUserInfo];
    }
    else if ([[qqAccountManage sharedInstance] qqAuthValid])
    {
        [[qqAccountManage sharedInstance] clickQQGetUserInfo];
    }
    else if (cacheLoginStatus==1)
    {
        //auto login in background
        NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/customer/login"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
        
        NSDictionary *parameters=nil;
//        if (email.length>0)
//        {
//            parameters = @{@"email":email,@"pwdsha1":sha1};
//        }
//        else
//        {
            parameters = @{@"phone":[NSString stringWithFormat:@"%@-%@",phoneCode,phoneNumber],@"pwdsha1":sha1};
//        }
        
        [manager POST:url
           parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             LOG(@"JSON: %@", responseObject);
           
             int status = [responseObject[@"status"] intValue];
             if (status==1)
             {
                 NSDictionary *dictData = responseObject[@"data"];
                 
                 int customer_id = [dictData[@"customer_id"] intValue];
                 NSString* fname = dictData[@"fname"];
                 NSString* token = dictData[@"token"];
                 
                 NSDictionary* setting = dictData[@"setting"];
                 int receive_notice = [setting[@"receive_notice"] intValue];
                 
                 [GDPublicManager instance].cid = customer_id;
                 
                 int point = [dictData[@"score"] intValue];
                 [GDPublicManager instance].point = point;
                 
                 [GDPublicManager instance].receive_notice = receive_notice;
                 
                 [GDPublicManager instance].username = fname;
                 [GDPublicManager instance].token    = token;
                 
                 [GDPublicManager instance].password = sha1;
                 
                 [GDPublicManager instance].loginstauts = GREADEAL;
                 
                 NSString* phonecode   = @"";
                 SET_IF_NOT_NULL(phonecode, dictData[@"telephone"]);
                 
                 NSString*  strCountry=@"";
                 NSString*  strPhoneNumber=@"";
                 
                 NSString*  strEmail=@"";
                 strEmail = [NSString stringWithFormat:@"%@@greadeal.com",phonecode];
                 
                 NSRange findslash = [phonecode rangeOfString:@"-"];
                 if (findslash.location != NSNotFound)
                 {
                     strCountry= [phonecode substringToIndex:findslash.location];
                     strPhoneNumber = [phonecode substringFromIndex:findslash.location+1];
                     
                     [GDPublicManager instance].phoneCountry = strCountry;
                     [GDPublicManager instance].phonenumber = strPhoneNumber;
                 }
                 
                 [[WCDatabaseManager instance] Login:strEmail withid:customer_id withCountry:strCountry withPhone:strPhoneNumber withpass:sha1];
                 
                 [[GDPublicManager instance] getMemberInfo];
                 [[GDPublicManager instance] getCartData];
                 [[GDPublicManager instance] updateToken];
             }
             else
             {
                 NSString *errorInfo =@"";
                 SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
                 LOG(@"errorInfo: %@", errorInfo);
                 //[ProgressHUD showError:errorInfo];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             LOG(@"error: %@", error.localizedDescription);
            [ProgressHUD showError:error.localizedDescription];
         }];
    }
}
}

- (void)showWho
{
    if ([GDSettingManager instance].nIntroPageVersion < currentIntroVersion)
    {
        [self showIntroView];
    }
    else
    {
        [self finishedIntro];
    }
}

- (void)finishedIntro
{
    [self setupViewControllers];
    [self.window setRootViewController:self.viewController];
}

- (void)showIntroView
{
    GDIntroViewController* introView = [[GDIntroViewController alloc] init];
    introView.target     = self;
    introView.callback   = @selector(finishedIntro);
    
    [self.window setRootViewController:introView];
    [self.window makeKeyAndVisible];
}

#pragma mark - jump
- (void)jumpToProduct:(int)productid withViewController:(UIViewController*)curController withMessage:(NSString*)message_show
{
    if (curController==nil)
        return;
    
    [UIAlertView showWithTitle:nil
                       message:message_show
             cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消")
             otherButtonTitles:@[NSLocalizedString(@"View", @"查看")]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex ==1) {
                              
                              UIViewController* hasPresented = curController.presentedViewController;
                              
                              if (hasPresented!=nil )
                              {
                                  [curController dismissViewControllerAnimated:NO completion:^{
                                      
                                      GDProductDetailsViewController *viewController = [[GDProductDetailsViewController alloc] init:productid withOrder:YES];
                                      [curController.navigationController pushViewController:viewController animated:YES];
                                      
                                  }];
                              }
                              else
                              {
                                  GDProductDetailsViewController *viewController = [[GDProductDetailsViewController alloc] init:productid withOrder:YES];
                                  [curController.navigationController pushViewController:viewController animated:YES];
                              }
                              
                          }
                      }];
}

- (void)jumpToVendor:(int)vendorid withViewController:(UIViewController*)curController withMessage:(NSString*)message_show
{
    if (curController==nil)
        return;
    
    [UIAlertView showWithTitle:nil
                       message:message_show
             cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消")
             otherButtonTitles:@[NSLocalizedString(@"View", @"查看")]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex ==1) {
                              
                              UIViewController* hasPresented = curController.presentedViewController;
                              
                              if (hasPresented!=nil )
                              {
                                  [curController dismissViewControllerAnimated:NO completion:^{
                                      
                                     GDLiveVendorViewController * viewController = [[GDLiveVendorViewController alloc] init:vendorid withName:@"" withUrl:@"" withImage:@""];
                                      [curController.navigationController pushViewController:viewController animated:YES];
                                      
                                  }];
                              }
                              else
                              {
                                  GDLiveVendorViewController *viewController = [[GDLiveVendorViewController alloc] init:vendorid withName:@"" withUrl:@"" withImage:@""];
                                  [curController.navigationController pushViewController:viewController animated:YES];
                              }
                              
                          }
                      }];

}


#pragma mark - Methods
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [UMessage registerDeviceToken:deviceToken];
    if (deviceToken!=nil)
    {
        [GDPublicManager instance].push_token = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]                  stringByReplacingOccurrencesOfString: @">" withString: @""]                 stringByReplacingOccurrencesOfString: @" " withString: @""];
    }
    
    NSLog(@"%@",[[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]                  stringByReplacingOccurrencesOfString: @">" withString: @""]                 stringByReplacingOccurrencesOfString: @" " withString: @""]);

}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    LOG(@"didFailToRegisterForRemoteNotificationsWithError");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //关闭友盟自带的弹出框
    [UMessage setAutoAlert:NO];
    
    [UMessage didReceiveRemoteNotification:userInfo];
    
    NSString* product_str = @"";
    NSString* vendor_str  = @"";
    
    SET_IF_NOT_NULL(product_str, userInfo[@"product_id"]);
    SET_IF_NOT_NULL(vendor_str,  userInfo[@"vendor_id"]);
    
    int   n_product = [product_str intValue];
    int   n_vendor  = [vendor_str intValue];
    
    NSString* message_show=@"";
    SET_IF_NOT_NULL(message_show, userInfo[@"aps"][@"alert"]);
    
    RDVTabBarController *tabBarController = (RDVTabBarController*)self.viewController;
    UINavigationController *navController = (UINavigationController*)tabBarController.selectedViewController;
    UIViewController *visibleController = [navController.viewControllers objectAtIndex:[navController.viewControllers count]-1];
    
    //定制自定的的弹出框
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        if (n_product!=0)
        {
            [self jumpToProduct:n_product withViewController:visibleController withMessage:message_show];
        }
        else if (n_vendor!=0)
        {
            [self jumpToVendor:n_vendor withViewController:visibleController withMessage:message_show];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:message_show
                                                               delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
                                                      otherButtonTitles:nil];
            
            [alertView show];
        }
        
    }
    else if ([UIApplication sharedApplication].applicationState ==  UIApplicationStateInactive)
    {
        if (n_product!=0)
        {
             [self jumpToProduct:n_product withViewController:visibleController withMessage:message_show];
            
        }
        else if (n_vendor!=0)
        {
             [self jumpToVendor:n_vendor withViewController:visibleController withMessage:message_show];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:message_show
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
                                                      otherButtonTitles:nil];
            
            [alertView show];
        }
    }

}

- (void)setupViewControllers {
//    UIViewController *saleViewController = [[GDSaleViewController alloc] init];
//    UIViewController *saleNavigationController = [[UINavigationController alloc]
//                                                   initWithRootViewController:saleViewController];
    
    //UIViewController *memberViewController =  [[GDForumViewController alloc] init];
    
    //UIViewController *memberNavigationController = [[UINavigationController alloc]
    //                                                initWithRootViewController:memberViewController];
    
    UIViewController *liveViewController = [[GDLiveViewController alloc] init];
    UIViewController *liveNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:liveViewController];
    
    UIViewController *cartViewController = [[GDCartViewController alloc] init];
    UIViewController *cartNavigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:cartViewController];
    
    UIViewController *meViewController = [[GDMeViewController alloc] init];
    UIViewController *meNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:meViewController];

    
    RDVTabBarController *tabBarController = [[RDVTabBarController alloc] init];
    if ([GDSettingManager instance].isRightToLeft)
    {
        [tabBarController setViewControllers:@[meNavigationController,                                cartNavigationController,liveNavigationController
                                               ]];
    }
    else
    {
        [tabBarController setViewControllers:@[liveNavigationController,
                                           cartNavigationController,
                                           meNavigationController]];
    }
    self.viewController = tabBarController;
    
    [self customizeTabBarForController:tabBarController];
    
    [tabBarController setSelectedIndex:[GDSettingManager instance].nTabLive];
    
}

- (void)setCartBadge:(NSString*)value
{
    RDVTabBarController *tabBarController = (RDVTabBarController*)self.viewController;
    [tabBarController setTabBarBadge:[GDSettingManager instance].nTabCarts Badge:value];
}

- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController {
    //UIImage *finishedImage = [UIImage imageNamed:@"tabbar_selected_background"];
    UIImage *finishedImage = [UIImage imageNamed:@"tabbar_normal_background"];
    UIImage *unfinishedImage = [UIImage imageNamed:@"tabbar_normal_background"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabBarController tabBar] items]) {
        [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        
        UIImage *selectedimage;
        UIImage *unselectedimage;
        
        if (index==[GDSettingManager instance].nTabSale)
        {
            selectedimage   = [UIImage imageNamed:@"sale_selected"];
            unselectedimage = [UIImage imageNamed:@"sale_normal"];
        }
        else if (index==[GDSettingManager instance].nTabCategory)
        {
            selectedimage   = [UIImage imageNamed:@"member_selected"];
            unselectedimage = [UIImage imageNamed:@"member_normal"];
        }
        else if (index==[GDSettingManager instance].nTabLive)
        {
            selectedimage   = [UIImage imageNamed:@"live_selected"];
            unselectedimage = [UIImage imageNamed:@"live_normal"];
        }
        else if (index==[GDSettingManager instance].nTabCarts)
        {
            selectedimage   = [UIImage imageNamed:@"cart_selected"];
           unselectedimage = [UIImage imageNamed:@"cart_normal"];
        }
        else if (index==[GDSettingManager instance].nTabMe)
        {
            selectedimage   = [UIImage imageNamed:@"me_selected"];
            unselectedimage = [UIImage imageNamed:@"me_normal"];
        }
       
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        index++;
    }
}

- (void)customizeInterface {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    
    UIImage *backgroundImage = nil;
    NSDictionary *textAttributes = nil;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        backgroundImage = [UIImage imageNamed:@"navigationbar_background_tall"];
        
        textAttributes = @{
                           NSFontAttributeName: MOBlodFont(18),
                           NSForegroundColorAttributeName: [UIColor whiteColor],
                           };
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        backgroundImage = [UIImage imageNamed:@"navigationbar_background"];
        
        textAttributes = @{
                           UITextAttributeFont: MOBlodFont(18),
                           UITextAttributeTextColor: [UIColor blackColor],
                           UITextAttributeTextShadowColor: [UIColor clearColor],
                           UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero],
                           };
#endif
    }
    
    [navigationBarAppearance setBackgroundImage:[[UIImage imageNamed:@"navigationbarcolor.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setTintColor:[UIColor whiteColor]];
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent]; 
    //[navigationBarAppearance setBackgroundImage:backgroundImage
                                //forBarMetrics:UIBarMetricsDefault];
    //[navigationBarAppearance setTitleTextAttributes:textAttributes];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
   
    // [GAI sharedInstance].optOut = ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     [[GDPublicManager instance] startupUpload];
     [[GDPublicManager instance] getMemberInfo];
     [[GDPublicManager instance] updateToken];
    
    
     //[FBSDKAppEvents activateApp];
    
     [self autoLogin];
    
     if (pushNotifi!=nil)
     {
         NSString* product_str = @"";
         NSString* vendor_str  = @"";
         
         SET_IF_NOT_NULL(product_str, pushNotifi[@"productid"]);
         SET_IF_NOT_NULL(vendor_str,  pushNotifi[@"vendorid"]);
         
         int   n_product = [product_str intValue];
         int   n_vendor  = [vendor_str intValue];
         
         NSString* message_show=@"";
         SET_IF_NOT_NULL(message_show, pushNotifi[@"aps"][@"alert"]);
         
         RDVTabBarController *tabBarController = (RDVTabBarController*)self.viewController;
         UINavigationController *navController = (UINavigationController*)tabBarController.selectedViewController;
         UIViewController *visibleController = [navController.viewControllers objectAtIndex:[navController.viewControllers count]-1];
         
         if (n_product!=0)
         {
             [self jumpToProduct:n_product withViewController:visibleController withMessage:message_show];
         }
         else if (n_vendor!=0)
         {
             [self jumpToVendor:n_vendor withViewController:visibleController withMessage:message_show];
         }

         pushNotifi = nil;
     }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    switch ([GDPublicManager instance].loginstauts) {
//        case GREADEAL:
//        {
//            int cid = [GDPublicManager instance].cid;
//            if (cid>0)
//            {
//                [[WCDatabaseManager instance] Logout:cid];
//            }
//            [[GDPublicManager instance] logoutEvent];
//        }
//        break;
//        case FACEBOOK:
//            [[GDPublicManager instance] logoutEvent];
//            [[facebookAccountManage sharedInstance] logout];
//        break;
//        case QQ:
//            [[GDPublicManager instance] logoutEvent];
//            [[qqAccountManage sharedInstance] Logout];
//            break;
//        default:
//            break;
//    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.host isEqualToString:@"safepay"])
    {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            LOG(@"result = %@",resultDic);
            BOOL paySuccess = NO;
            NSDictionary* dict = resultDic;
            int resultStatus = [dict[@"resultStatus"] intValue];
            NSString* result = dict[@"result"];
            NSRange findsuccess = [result rangeOfString:@"success="];
            if (findsuccess.location != NSNotFound)
            {
                NSString* isture = [result substringFromIndex:findsuccess.location];
                
                NSRange findtrue = [isture rangeOfString:@"true"];
                if (findtrue.location != NSNotFound)
                {
                    paySuccess = YES;
                }
            }
            
            if (resultStatus == 9000 && paySuccess) {
                [[AliPayment instance].delegate aliPayCompleted:YES];
            }
            else
            {
                [[AliPayment instance].delegate aliPayCompleted:NO];
            }
        }];
        
    }
    else
    {
        NSString *strUrl = [url absoluteString];
    	NSRange range = [strUrl rangeOfString:[[weixinAccountManage sharedInstance] getAppid]];
    	if (range.location != NSNotFound)
        {
            return [WXApi handleOpenURL:url delegate:[weixinAccountManage sharedInstance]];
        }
    
        range = [strUrl rangeOfString:[[qqAccountManage sharedInstance] getAppid]];
    	if (range.location != NSNotFound)
        {
            return [TencentOAuth HandleOpenURL:url];
            //return [[[qqAccountManage sharedInstance] getTencent] HandleOpenURL:url];
        
        }
        else//FACEBOOK
        {
            return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation];
        }
    }
    
    return YES;
}


@end
