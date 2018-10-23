//
//  GDPublicManager.m
//  WristCentralPos
//
//  Created by tao tao on 20/8/14.
//  Copyright (c) 2014 tao tao. All rights reserved.
//

#import "GDPublicManager.h"
#import <CommonCrypto/CommonDigest.h> 

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "UIActionSheet+Blocks.h"

#import "CustomIOSAlertView.h"

#define kairprint       @"airprint"
#define kprinterID      @"printerID"

@implementation GDPublicManager

@synthesize username;
@synthesize cid;
@synthesize token;
@synthesize push_token;

@synthesize email;
@synthesize emailDomain;
@synthesize point;
@synthesize memberRank;
@synthesize receive_notice;
@synthesize password;
@synthesize phonenumber;
@synthesize phoneCountry;
@synthesize loginstauts;
@synthesize app_version;
@synthesize app_date;

@synthesize user_avatar;

@synthesize currency;
@synthesize cartsItem;
@synthesize countDownPay;
@synthesize defaultCount;

@synthesize _reachability;

@synthesize screenScale;
@synthesize screenWidth;

@synthesize buy_section_show;

@synthesize workPhone;
@synthesize nonworkPhone;

+ (GDPublicManager *)instance
{
    static GDPublicManager *_sharedObject = nil;
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedObject = [[GDPublicManager alloc] init];
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        loginstauts = UNLOGIN;
        
        buy_section_show = NO;
        
        username=@"";
        token=@"";
        push_token=@"";
        
        workPhone = @"+97145511614,+97145511589";
        
        cid=-1;
        point=0;
        receive_notice=0;
        memberRank = 0;  //0non member 1 blud 2 gold 3 platinum
        
        emailDomain=@"";
        email=@"";
        
        password=@"";
        phonenumber=@"";
        phoneCountry=@"";
        
        cartsItem     = [[NSMutableArray alloc] init];
        availableMaps = [[NSMutableArray alloc] init];
        
        currency = @"AED";
        defaultCount = 0;
        
        countDownPay = [[MZTimerLabel alloc] init];
        countDownPay.timerType = MZTimerLabelTypeTimer;
        countDownPay.timeFormat = @"mm:ss";
        countDownPay.timeLabel.backgroundColor = [UIColor clearColor];
        countDownPay.timeLabel.font = MOLightFont(15);
        countDownPay.timeLabel.textAlignment = NSTextAlignmentCenter;
        countDownPay.delegate = self;
        
        _reachability = [Reachability reachabilityForInternetConnection];
        [_reachability startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
        
        
        CGRect r = [[UIScreen mainScreen] bounds];
        screenWidth = r.size.width;
        screenScale = r.size.width / 320.0; //width 320
    }
    return self;
}

- (void)handleNetworkChange:(NSNotification *)notice
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    NetworkStatus remoteHostStatus = [_reachability currentReachabilityStatus];
    
    if (state == UIApplicationStateActive)
    {
        if (remoteHostStatus == NotReachable)
        {
            //if (appState == kMOApplicationStateSingup)
            {
                [UIAlertView showWithTitle:NSLocalizedString(@"No Network", @"没有网络")
                                   message:NSLocalizedString(@"Plese check your network or WIFI", @"请检查您的网络连接.")
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      if (buttonIndex == [alertView cancelButtonIndex]) {
                                          LOG(@"Cancelled");
                                      }
                                  }];
            }
        }
        else
        {
            //reconnection
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (NSString*)getMobileCountryCode
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    
    NSString *countryCode = carrier.isoCountryCode;
    countryCode=[countryCode uppercaseString];
    
    NSDictionary *dictCodes = [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
                               @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                               @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                               @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                               @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                               @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                               @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                               @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                               @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                               @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                               @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                               @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                               @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                               @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                               @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                               @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                               @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                               @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                               @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                               @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                               @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                               @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                               @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                               @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                               @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                               @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                               @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                               @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                               @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                               @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                               @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                               @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                               @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                               @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                               @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                               @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                               @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                               @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                               @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                               @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                               @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                               @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                               @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                               @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                               @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                               @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                               @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                               @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                               @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                               @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                               @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                               @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                               @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                               @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                               @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                               @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                               @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                               @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                               @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                               @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                               @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
    
    NSString *mobileCountryCode = dictCodes[countryCode];
    if (mobileCountryCode.length<=0)
        mobileCountryCode = @"971";
    
    return mobileCountryCode;
}

- (BOOL)getAirPrintStatus
{
    NSString *key = kairprint;
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return value.boolValue;
}

- (void)setAirPrintStatus:(BOOL)use
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = kairprint;
    [defaults setObject:[NSNumber numberWithBool:use] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)getAirPrintID
{
    NSString *key = kprinterID;
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return value;
}

- (void)setAirPrintID:(NSString*)printID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = kprinterID;
    [defaults setObject:printID forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)getCartData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGetCacheCart object:nil userInfo:nil];
}

- (void)startupUpload
{
//    device_id
//    设备uuid
//    device_name
//    设备名称
//    device_version
//    设备版本
//    device_language
//    设备语言
//    app_version
//    app版本信息
//    app_bundle_id
//    app_type
//    app 类型（ipad | iphone | android | ios | androidpad）
      NSString *device_id = @"UUID apple";
    
      NSString *device_name = [[UIDevice currentDevice] systemName];
      NSString *device_version =  [[UIDevice currentDevice] systemVersion];
    
      NSArray  *languageArray = [NSLocale preferredLanguages];
      NSString *device_language = [languageArray objectAtIndex:0];
  
      NSDictionary *dicInfo = [[NSBundle mainBundle] infoDictionary];
      app_version = [dicInfo objectForKey:@"CFBundleShortVersionString"];
      app_date = [dicInfo objectForKey:@"CFBundleVersion"];
      NSString* app_bundle_id =  [[NSBundle mainBundle] bundleIdentifier];
      NSString* app_type = @"iphone"; //[[UIDevice currentDevice] model];
    
      NSString* url = [NSString stringWithFormat:@"%@%@",self.APIBaseUrl,@"rest2/v1/startup/init"];
    
      AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
      manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
      NSDictionary *parameters = @{@"device_id":device_id,@"device_name":device_name,@"device_version":device_version,@"device_language":device_language,@"app_version":app_version,@"app_bundle_id":app_bundle_id,@"app_type":app_type};
    
      [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
      {
         LOG(@"JSON: %@", responseObject);
         
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             NSDictionary *dictData = responseObject[@"data"];
             //NSString* newCreated = dictData[@"created"];
             emailDomain = dictData[@"email_domain_name"];
             
             SET_IF_NOT_NULL(app_share_link, dictData[@"app_share_link"]);
           
             if (app_share_link.length<=0)
                 app_share_link = MainWebPage;
             
             //defaultCount = [dictData[@"cart_countdown"] intValue];
//             defaultCount = 0;   //default 0
//             if (defaultCount>60)
//                 countDownPay.timeFormat = @"HH:mm:ss";
  
             workPhone = dictData[@"contact_phones"][@"worktime"];
             nonworkPhone = dictData[@"contact_phones"][@"nonworktime"];
             
             NSString* newVersion = dictData[@"version"];
             NSString* newInfo =    dictData[@"info"];
             NSString* newAppLink = dictData[@"app_link"];
   
             if ([newVersion compare:app_version options:NSCaseInsensitiveSearch|NSNumericSearch]==NSOrderedDescending || [newVersion compare:app_version options:NSCaseInsensitiveSearch|NSNumericSearch]==NSOrderedSame)
             {
                 //buy_section_show = YES;  can not buy member
                 
                 if ([newVersion compare:app_version options:NSCaseInsensitiveSearch|NSNumericSearch]==NSOrderedDescending)
                 {
                     [UIAlertView showWithTitle:NSLocalizedString(@"New Version", @"更新版本")
                                                     message:newInfo
                                           cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                           otherButtonTitles:@[NSLocalizedString(@"Upgarde", @"升级")]
                                                    tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                        if (buttonIndex == 0){
                                                                                                                  }
                                                       else if (buttonIndex == 1) {
                                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:newAppLink]];
                                                        }
                                                    }];
                 }

             }
             else
             {
                 buy_section_show = NO;
             }
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
     }];
}

- (NSString*)getShareUrl
{
//    if (redeem_url.length>0) {
//        return redeem_url;
//    }
    return app_share_link;
}

- (NSString *)getSha1String:(NSString *)srcString{
    const char *cstr = [srcString cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:srcString.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* result = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}

- (void)logoutEvent
{
    NSString* url = [NSString stringWithFormat:@"%@%@",self.APIBaseUrl,@"rest2/v1/customer/logout"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    NSDictionary *parameters = @{@"token":[GDPublicManager instance].token};
    
    [ProgressHUD show:NSLocalizedString(@"Logout...", @"登出...")];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         LOG(@"JSON: %@", responseObject);
         [ProgressHUD dismiss];
        
         [GDPublicManager instance].memberRank = 0;
         cid = -1;
         token = @"";
         [[GDPublicManager instance] getCartData];
         
         [GDPublicManager instance].loginstauts = UNLOGIN;
         [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidLogout object:nil userInfo:nil];
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [ProgressHUD showError:error.localizedDescription];
     }];
   
    
    
}

-(void)timerLabel:(MZTimerLabel*)timerLabel countingTo:(NSTimeInterval)time timertype:(MZTimerLabelType)timerType
{
    if (defaultCount>0)
    {
        if (time<=600 && time>=599)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGetRemindCart object:nil userInfo:nil];
        }
    }
}

-(void)timerLabel:(MZTimerLabel*)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime
{
    if (defaultCount>0)
    {
        LOG(@"kNotificationDidDeleteCart");
        //add to wish list before delete
        @synchronized(cartsItem)
        {
            [cartsItem removeAllObjects];
            [[WCDatabaseManager instance] deleteCartOfAll];
        }

        //post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidClearCart object:nil userInfo:nil];
    }
}

- (void)clearCart
{
    @synchronized(cartsItem)
    {
        [cartsItem removeAllObjects];
    }
}

- (int)getOrderQtyOfVendor:(int)vendor_id
{
    int order_qty=0;
    for (NSMutableDictionary* dict in cartsItem)
    {
        //check option_value_id and product_id the same
        int exist_vendor_id = [dict[@"vendor_id"] intValue];
        
        if (exist_vendor_id == vendor_id)
        {
            NSMutableArray* tempArrar = dict[@"Items"];
            
            for (NSDictionary* obj in tempArrar)
            {
                order_qty += [obj[@"order_qty"] intValue];
            }
        }
    }
    
    return order_qty;
}

- (int)getOrderQtyOfProudct:(int)product_id withoption:(int)option_value_id
{
    int order_qty=0;
    for (NSMutableDictionary* dict in cartsItem)
    {
        NSMutableArray* tempArrar = dict[@"Items"];
            
        for (NSDictionary* obj in tempArrar)
        {
            int exist_product_id = [obj[@"product_id"] intValue];
            //int exist_option_value_id = [obj[@"option_value_id"] intValue];
            //不在针对选项
            // if (product_id == exist_product_id && option_value_id == exist_option_value_id)
            if (product_id == exist_product_id)
            {
                order_qty += [obj[@"order_qty"] intValue];
                //break;
            }
        }
    }
    
    return order_qty;
}

- (int)getOrderQtyOfAll
{
    int order_qty = 0;
    for (NSMutableDictionary* dict in [GDPublicManager instance].cartsItem)
    {
        if (dict!=nil)
        {
            NSArray* tempArrar = dict[@"Items"];
            for (NSDictionary* obj in tempArrar)
            {
                //check option_value_id and product_id the same
                order_qty  += [obj[@"order_qty"] intValue];
            }
        }
    }
    return order_qty;
}

- (NSMutableDictionary*)getVendorOfCart:(int)vendor_id
{
    NSMutableDictionary* returnDict=nil;
    
    for (NSMutableDictionary* dict in [GDPublicManager instance].cartsItem)
    {
        //check option_value_id and product_id the same
        if (dict!=nil)
        {
            int temp_vendor_id = [dict[@"vendor_id"] intValue];
            if (temp_vendor_id == vendor_id)
            {
                returnDict = dict;
            }
        }
    }
    return returnDict;
}

- (void)deleteVendor:(int)vendor_id
{
    for (NSMutableDictionary* dict in [GDPublicManager instance].cartsItem)
    {
        //check option_value_id and product_id the same
        if (dict!=nil)
        {
             int temp_vendor_id = [dict[@"vendor_id"] intValue];
             if (temp_vendor_id == vendor_id)
             {
                 //delete category
                 @synchronized([GDPublicManager instance].cartsItem)
                 {
                     [[GDPublicManager instance].cartsItem removeObject:dict];
                     break;
                 }
             }
        }
    }
}

- (void)deleteProduct:(int)vendor_id withproduct:(int)product_id withoption:(int)option_value_id
{
    for (NSMutableDictionary* dict in [GDPublicManager instance].cartsItem)
    {
        //check option_value_id and product_id the same
        if (dict!=nil)
        {
            NSMutableArray* tempArrar = dict[@"Items"];
            for (NSMutableDictionary* obj in tempArrar)
            {
                int temp_option_value_id = [obj[@"option_value_id"] intValue];
                int temp_product_id      = [obj[@"product_id"] intValue];
                
                if (option_value_id == temp_option_value_id && product_id == temp_product_id)
                {
                    
                    int temp_order_qty  = [obj[@"order_qty"] intValue];
                    if  (temp_order_qty>=1)
                    {
                        temp_order_qty--;
                        [obj setObject:@(temp_order_qty) forKey:@"order_qty"];
                        
                        [[WCDatabaseManager instance] updateCartQty:temp_order_qty withID:product_id withOption:option_value_id];
                        
                        ///check if order qty is 0, need delete this product form carts
                        if (temp_order_qty==0)
                        {
                            [[WCDatabaseManager instance] deleteCart:product_id withOption:option_value_id];
                            
                            [tempArrar removeObject:obj];
                            
                            if (tempArrar.count<=0)
                            {
                                [self deleteVendor:vendor_id];
                            }

                        }
                        
                        break;
                    }
                }
            }
        }
    }
}

- (BOOL)checkCityChange
{
    NSString* url = [NSString stringWithFormat:@"%@%@",self.APIBaseUrl,@"rest2/v1/address/get_open_address_by_md5"];
    
    NSDictionary *parameters=nil;
    if ([GDSettingManager instance].md5Address.length>0)
    {
        parameters = @{@"md5":[GDSettingManager instance].md5Address};
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             if(responseObject[@"data"] != [NSNull null] && responseObject[@"data"] != nil)
             {
                 //got new address
                 NSString* tempMD5;
                 SET_IF_NOT_NULL(tempMD5, responseObject[@"data"][@"address_md5"]);
                 [[GDSettingManager instance] setMD5Address:tempMD5];
                 
                 NSArray* shippingAddress = responseObject[@"data"][@"country_list"];
                 if (shippingAddress.count>0)
                 {
                     LOG(@"Got address from server!");
                     [[GDSettingManager instance] setAllAddress:shippingAddress];
                 }
                 
             }
             else
             {
                LOG(@"Got address from cache!");
             }
             
             [[GDPublicManager instance] getCityID];
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         LOG(@"error: %@", error.localizedDescription);
     }];
    
    return NO;
}

- (BOOL)checkDeliveryAddressChange
{
    NSString* url = [NSString stringWithFormat:@"%@%@",self.APIBaseUrl,@"takeout/v1/TakeoutAddress/get_all_shipping_address_by_md5"];
    
    NSDictionary *parameters=nil;
    if ([GDSettingManager instance].md5DeliveryCity.length>0)
    {
        parameters = @{@"md5":[GDSettingManager instance].md5DeliveryCity};
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             if(responseObject[@"data"] != [NSNull null] && responseObject[@"data"] != nil)
             {
                 //got new address
                 NSString* tempMD5;
                 SET_IF_NOT_NULL(tempMD5, responseObject[@"data"][@"address_md5"]);
                 [[GDSettingManager instance] setMD5DeliveryCity:tempMD5];
                 
                 NSArray* shippingAddress = responseObject[@"data"][@"country_list"];
                 if (shippingAddress.count>0)
                 {
                     LOG(@"Got Delivery From Server!");
                     [[GDSettingManager instance] setDeliveryCity:shippingAddress];
                 }
                 
             }
             else
             {
                 LOG(@"Got Delivery From Cache!");
             }
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         LOG(@"error: %@", error.localizedDescription);
     }];
    
    return NO;
}

- (void)makeCall:(NSString *)number withView:(UIView*)showView
{
    if (number.length>0)
    {
        NSArray *phoneSplit = [number componentsSeparatedByString:@","];
        
        if (phoneSplit.count>0)
        {
            [UIActionSheet showInView:showView
                            withTitle:NSLocalizedString(@"Call", @"拨号")
                    cancelButtonTitle:NSLocalizedString(@"Cancel",@"取消")
               destructiveButtonTitle:nil
                    otherButtonTitles:phoneSplit
                             tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                                 if (buttonIndex < phoneSplit.count)
                                 {
                                     NSString* phoneNumber = [phoneSplit objectAtIndex:buttonIndex];
                                     NSString *escapedPhoneNumber = [phoneNumber stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                     NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", escapedPhoneNumber]];
                                     [[UIApplication sharedApplication] openURL:telURL];
                                 }
                             }];
        }
    }
    
  }


- (void)makeHelp
{
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    [alertView setUseMotionEffects:true];
    // And launch the dialog
    [alertView show];

}

#define NUMBERS @"0123456789"
- (BOOL)validateNumber:(NSString*)string
{
       NSCharacterSet*cs;
       cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
       NSString*filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
       BOOL basicTest = [string isEqualToString:filtered];
       if(!basicTest) {
           [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                              message:NSLocalizedString(@"Please enter a number", @"请输入数字")
                    cancelButtonTitle:NSLocalizedString(@"OK", nil)
                    otherButtonTitles:nil
                             tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                 if (buttonIndex == [alertView cancelButtonIndex]) {
                                     
                                 }
                             }];
           return NO;

      }
    return YES;
}


///Get City ID
- (void)getCityID
{
    //  Get FTLocationManager singleton instance
    FTLocationManager *locationManager = [FTLocationManager sharedManager];
    //  Optionaly you can change properties like error timeout and errors count threshold
    //  Ask the location manager to get current location and get notified using
    //  provided handler block
    [locationManager updateLocationWithCompletionHandler:^(CLLocation *location, NSDictionary*userplace,NSError *error, BOOL locationServicesDisabled)
     { 
             if (userplace!=nil)
             {
                // NSString* localCity = userplace[@"city"];
                 NSString* localCountry = userplace[@"country"];
                 
                 NSArray* tempArrar = [GDSettingManager instance].nAllAddress;
                 if (tempArrar.count>0)
                 {
                     NSDictionary* info = [tempArrar objectAtIndex:0];
                     //NSArray* tempArray = nil;
                     //SET_IF_NOT_NULL(tempArray,info[@"zone_list"]);
                     
                     NSString*  countryName = @"";
                     SET_IF_NOT_NULL(countryName, info[@"name"]);
                     
                     int countryId = [info[@"country_id"] intValue];
                     
                     if ([localCountry compare:countryName options:NSCaseInsensitiveSearch]==NSOrderedSame)
                     {
                         NSDictionary* parameters = @{@"selCountryId":@(countryId),@"selCountry":countryName};
                         
                         [[GDSettingManager instance] saveUserCity:parameters];
                         
                         // country changed
                         if (countryId != [GDSettingManager instance].currentCountryId)
                         {
                             [GDSettingManager instance].currentCountryId = countryId;
                             [GDSettingManager instance].currentCountry   = countryName;
                             
                             [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGetCountryID object:nil userInfo:nil];
                         }
                     }
                     
                     //int  countryId = [info[@"country_id"] intValue];
                     
//                     for (NSDictionary* dict in tempArray)
//                     {
//                         NSString*  cityName = @"";
//                         SET_IF_NOT_NULL(cityName, dict[@"name"]);
//                         
//                         if ([localCity compare:cityName options:NSCaseInsensitiveSearch]==NSOrderedSame)
//                         {
//                                int   cityId = [dict[@"zone_id"] intValue];
//                                NSDictionary* parameters = @{@"selCity":cityName,@"selCityId":@(cityId),@"selCountryId":@(countryId),@"selCountry":countryName};
//                             
//                                [[GDSettingManager instance] saveUserCity:parameters];
//                             
//                                // city changed
//                                if (cityId != [GDSettingManager instance].currentCountryId)
//                                {
//                                    [GDSettingManager instance].currentCountryId = cityId;
//                                    [GDSettingManager instance].currentCountry   = cityName;
//                                 
//                                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGetCountryID object:nil userInfo:nil];
//                             }
//                             break;
//                         }
//                     }
                 }
             }
    }];

}

///Get Category
-(void)getCategory:(categoryType)selType success:(void(^)(NSError *error))block
{
    NSString* url = [NSString stringWithFormat:@"%@%@",self.APIBaseUrl,@"rest2/v1/Category/get_category_list_by_md5"];
    NSDictionary *parameters=nil;
    
    switch (selType) {
        case CATEGORY_DISCOUNT_STORE:
        {
            if ([GDSettingManager instance].md5DiscountStoreCategory.length>0)
            {
                parameters = @{@"md5":[GDSettingManager instance].md5DiscountStoreCategory,@"language_id":@([[GDSettingManager instance] language_id:NO]),@"country_id":@([GDSettingManager instance].currentCountryId),@"product_filter":@(1)};
            }
            else
            {
                parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"country_id":@([GDSettingManager instance].currentCountryId),@"product_filter":@(1)};
            }
        }
            break;
        case CATEGORY_ALL_STORE:
        {
            if ([GDSettingManager instance].md5AllStoreCategory.length>0)
            {
                parameters = @{@"md5":[GDSettingManager instance].md5AllStoreCategory,@"language_id":@([[GDSettingManager instance] language_id:NO]),@"country_id":@([GDSettingManager instance].currentCountryId)};
            }
            else
            {
                parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"country_id":@([GDSettingManager instance].currentCountryId)};
            }

        }
            break;
        case CATEGORY_BLUE_STORE:
        {
            if ([GDSettingManager instance].md5BlueCategory.length>0)
            {
                parameters = @{@"md5":[GDSettingManager instance].md5AllStoreCategory,@"language_id":@([[GDSettingManager instance] language_id:NO]),@"country_id":@([GDSettingManager instance].currentCountryId),@"product_filter":@(1),@"membership_level":@(1)};
            }
            else
            {
                parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"country_id":@([GDSettingManager instance].currentCountryId),@"product_filter":@(1),@"membership_level":@(1)};
            }
        }
            break;
        case CATEGORY_GOLD_STORE:
        {
            if ([GDSettingManager instance].md5GoldCategory.length>0)
            {
                parameters = @{@"md5":[GDSettingManager instance].md5AllStoreCategory,@"language_id":@([[GDSettingManager instance] language_id:NO]),@"country_id":@([GDSettingManager instance].currentCountryId),@"product_filter":@(1),@"membership_level":@(2)};
            }
            else
            {
                parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"country_id":@([GDSettingManager instance].currentCountryId),@"product_filter":@(1),@"membership_level":@(2)};
            }
        }
            break;
        case CATEGORY_PLATINUM_STORE:
        {
            if ([GDSettingManager instance].md5PlatinumCategory.length>0)
            {
                parameters = @{@"md5":[GDSettingManager instance].md5AllStoreCategory,@"language_id":@([[GDSettingManager instance] language_id:NO]),@"country_id":@([GDSettingManager instance].currentCountryId),@"product_filter":@(1),@"membership_level":@(3)};
            }
            else
            {
                parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO]),@"country_id":@([GDSettingManager instance].currentCountryId),@"product_filter":@(1),@"membership_level":@(3)};
            }
        }
            break;
        default:
            break;
    }
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             if(responseObject[@"data"] != [NSNull null] && responseObject[@"data"] != nil)
             {
                 //got new category
                 LOG(@"Got category from server!");
                 
                 NSString* tempMD5;
                 SET_IF_NOT_NULL(tempMD5, responseObject[@"data"][@"category_md5"]);
                 
                 NSArray* allCategory = responseObject[@"data"][@"category_list"];
                 
                 [[GDSettingManager instance] setMD5StoreCategory:tempMD5 withType:selType];
                 [[GDSettingManager instance] setStoreCategory:allCategory withType:selType];
                 
             }
             else
             {
                 LOG(@"Got category from cache!");
             }
             
             block(nil);
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         LOG(@"error: %@", error.localizedDescription);
         switch (selType) {
             case CATEGORY_DISCOUNT_STORE:
             {
                 if ([GDSettingManager instance].nDiscountStoreCategory.count>0)
                     block(nil);
                 else
                     block(error);
             }
                 break;
             case CATEGORY_ALL_STORE:
             {
                 if ([GDSettingManager instance].nAllStoreCategory.count>0)
                     block(nil);
                 else
                     block(error);
             }
                 break;
             case CATEGORY_BLUE_STORE:
             {
                 if ([GDSettingManager instance].nBlueCategory.count>0)
                     block(nil);
                 else
                     block(error);
             }
                 break;
             case CATEGORY_GOLD_STORE:
             {
                 if ([GDSettingManager instance].nGoldCategory.count>0)
                     block(nil);
                 else
                     block(error);
             }
                 break;
             case CATEGORY_PLATINUM_STORE:
             {
                 if ([GDSettingManager instance].nPlatinumCategory.count>0)
                     block(nil);
                 else
                     block(error);
             }
                 break;
             default:
                 break;
         }
        
         
     }];
}

///Open Hours
- (NSDictionary*)getDateFormat:(NSString*)startTime withEnd:(NSString*)endTime withDay:(int)day
{
    NSString* sTime = [NSString stringWithFormat:@"%@",[startTime substringToIndex:5]];
    NSString* eTime = [NSString stringWithFormat:@"%@",[endTime substringToIndex:5]];
//    NSString* sTime = [NSString stringWithFormat:@"%@ AM",[startTime substringToIndex:5]];
//    NSString* eTime = [NSString stringWithFormat:@"%@ PM",[endTime substringToIndex:5]];
    NSString* days=@"";
  
    switch (day) {
        case 0:
            days = NSLocalizedString(@"SUN", @"星期天");
            break;
        case 1:
            days = NSLocalizedString(@"MON", @"星期一");
            break;
        case 2:
            days = NSLocalizedString(@"TUE", @"星期二");
            break;
        case 3:
            days = NSLocalizedString(@"WED", @"星期三");
            break;
        case 4:
            days = NSLocalizedString(@"THU", @"星期四");
            break;
        case 5:
            days = NSLocalizedString(@"FRI", @"星期五");
            break;
        case 6:
            days = NSLocalizedString(@"SAT", @"星期六");
            break;
        default:
            break;
    }
    
    NSDictionary* dict  = @{@"days":days,@"time":[NSString stringWithFormat:@"%@ - %@",sTime,eTime]};
    return dict;
}

- (float)caluArabicTextWidth
{
    
//    CGSize onlineStatusSize = [descriptionText moSizeWithFont:onlineStatusFont];
//    CGFloat bottomLineWidth;
//
//    while (bottomLineWidth > self.bounds.size.width) {
//    onlineStatusFontSize -= 1.f;
//    if([descriptionText isEqualToString:MOLocalizedString(@"Typing...", @"")]){
//        onlineStatusFont = [UIFont boldSystemFontOfSize:onlineStatusFontSize];
//        onlineStatusSize = [descriptionText moSizeWithFont:onlineStatusFont];
//    }else{
//        onlineStatusFont = MOLightFont(onlineStatusFontSize];
//        onlineStatusSize = [descriptionText moSizeWithFont:onlineStatusFont];
//    }
//    if (image) {
//        bottomLineWidth = image.size.width + imageTextSpacing + onlineStatusSize.width;
//    } else {
//        bottomLineWidth = onlineStatusSize.width;
//    }
    return 12;
}

//UIArabicTableViewCell *cell = nil;
//
//int  section = [indexPath section];
//
//cell = [tableView dequeueReusableCellWithIdentifier:@"CellAction"];
//if(!cell)
//{
//    cell = [UIArabicTableViewCell getFlatCellWithColor:[UIColor whiteColor] selectedColor:MOColorCellHighlightedColor() style:UITableViewCellStyleValue1  reuseIdentifier:@"CellAction" cornerRadius:3 strokeWith:2 strokeColor:MOColorTableSeparatorColor() forClass:[UIArabicTableViewCell class]];
//}

///member function
- (BOOL)isVaildFreeBuy:(int)membership_level withNote:(BOOL)showNote
{
//    if (membership_level>=MEMBER_SHOPPING)
//        return YES;
    
    BOOL validDate = [self isExpiredMember];
    if (!validDate)
    {
        if (showNote)
        {
            NSString* noteStr = NSLocalizedString(@"Your membership has expired.\n Please pay to buy or upgrade to premium membership", @"您的会员有效日期已经过期, 您可以继续付费购买, 也可以购买会员卡后免费购买");
            
            [UIAlertView showWithTitle:NSLocalizedString(@"Note", nil)
                           message:noteStr
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        }
    }
    
    if (memberRank>=membership_level)
        return YES;
    else
    {
        NSString* memberName = @"";
        switch (memberRank) {
            case MEMBER_NON:
                memberName = NSLocalizedString(@"Non Member", @"非会员");
                break;
            case MEMBER_BLUE:
                memberName = NSLocalizedString(@"Glod Member", @"金卡会员");
                break;
            case MEMBER_GOLD:
                memberName = NSLocalizedString(@"Gold Member", @"金卡会员");
                break;
            case MEMBER_PLATINUM:
                memberName = NSLocalizedString(@"Platinum Member", @"白金卡会员");
                break;
            default:
                break;
        }
        
        NSString* storeRank = @"";
        switch (membership_level) {
            case MEMBER_BLUE:
                storeRank = NSLocalizedString(@"Gold Card", @"金卡商家");
                break;
            case MEMBER_GOLD:
                storeRank = NSLocalizedString(@"Gold Card", @"金卡商家");
                break;
            case MEMBER_PLATINUM:
                storeRank = NSLocalizedString(@"Platinum Card", @"白金卡商家");
                break;
            default:
                break;
        }
        
        if (showNote)
        {
            NSString* noteStr = [NSString stringWithFormat:NSLocalizedString(@"%@ is not available for. You could continue by purchasing it or upgrading your \n account to %@.", @"%@不能免费购买 %@ 优惠券, 您可以继续付费购买, 也可以升级会员后再次免费购买"),memberName,storeRank];
        
            [UIAlertView showWithTitle:NSLocalizedString(@"Note", nil)
                           message:noteStr
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                             
                          }];
        }
        
        return NO;
    }
}

- (BOOL)isMember
{
    if (memberRank>0)
        return YES;
    else
        return NO;
}

- (BOOL)isBlueMember
{
    if (memberRank == MEMBER_BLUE)
        return YES;
    else
        return NO;
}

- (BOOL)isGoldMember
{
    if (memberRank == MEMBER_GOLD)
        return YES;
    else
        return NO;
}

- (BOOL)isPlatimunMember
{
    if (memberRank == MEMBER_PLATINUM)
        return YES;
    else
        return NO;
}

- (NSString*)memberEndDate
{
    return memberEndDate;
}

- (BOOL)isExpiredMember
{
    if ([self isMember])
    {
        if (memberIsExpired == 0)
            return YES;
        else
            return NO;
    }
    return YES;
}

- (NSString*)memberPhone
{
    return [NSString stringWithFormat:@"%@-%@",phoneCountry,phonenumber];
}

- (int)returnMemberRank
{
    return memberRank;
}

- (BOOL)nonMemberFree:(NSArray*)orderArrar
{
    int s_price = 0;
    int order_qty = 0;
    int sum_price = 0;
    for (NSDictionary* obj in orderArrar)
    {
        order_qty = [obj[@"order_qty"] intValue];
        s_price    = [obj[@"sprice"] intValue];
        sum_price += order_qty * s_price;
    }
    
    //if non member , order sum price is zero
    if (![self isMember] && sum_price<=0)
        return YES;
    else
        return NO;

}

- (BOOL)isExpiredDate:(NSString*)expireDate
{
    NSDate *  todate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    
    NSString *toString=[dateformatter stringFromDate:todate];
    
     if ([expireDate compare:toString options:NSCaseInsensitiveSearch|NSNumericSearch]==NSOrderedDescending || [expireDate compare:toString options:NSCaseInsensitiveSearch|NSNumericSearch]==NSOrderedSame)
     {
         return NO;
     }
     else
        return YES;
}

- (NSString*)minExpiredDate:(NSString*)expireDate
{
    NSComparisonResult result = [expireDate compare:memberEndDate options:NSCaseInsensitiveSearch|NSNumericSearch];
         
    if (result == NSOrderedDescending && memberEndDate!=nil)
        return memberEndDate;
    else
        return expireDate;
}

- (void)updateToken
{
    if (token.length>0 && push_token.length>0)
    {
        NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/customer/update_push_token"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
        
        NSDictionary *parameters;
        
        parameters = @{@"token":[GDPublicManager instance].token,@"push_device":@"ios",@"push_token":[GDPublicManager instance].push_token};
        
        [manager POST:url
           parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSLog(@"Update token successful");
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Update token failure");
         }];
    }
}

- (void)getMemberInfo
{
    if (token.length>0)
    {
        NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/customer/get_info"];
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
        NSDictionary *parameters = @{@"token":token};
    
        //[ProgressHUD show:NSLocalizedString(@"Get User Info...", @"获取用户信息")];
    
        [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
         LOG(@"userinfo=: %@", responseObject);
         //[ProgressHUD dismiss];
         
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             NSDictionary *dictData = responseObject[@"data"][@"customer_info"];
             
             redeem_url = dictData[@"redeem_url"];
             email = dictData[@"email"];
             NSDictionary *memberDict = dictData[@"membership_card"];
             
             if (memberDict!=nil)
             {
                 memberRank = [memberDict[@"level"] intValue];
             
                 memberStartDate = memberDict[@"date_started"];
                 memberEndDate = memberDict[@"date_end"];
                 //0没过 1过期
                 memberIsExpired = [memberDict[@"is_expired"] intValue];
             
             }
             
             user_avatar = dictData[@"header"];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidMemberInfo object:nil userInfo:nil];
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
             [ProgressHUD showError:error.localizedDescription];
         }];
    }
    
}

//trans chinese
-(void)toChinese:(NSString*)enText success:(void(^)(NSString* translated))block
{
    NSString* url;
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Translate/google"];
    
    NSDictionary *parameters=@{@"text":enText,@"to":@"zh-cn"};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             NSString *chText = responseObject[@"data"];
             block(chText);
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
             [ProgressHUD showError:errorInfo];
             block(@"");
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         LOG(@"%@",operation.responseObject);
         [ProgressHUD showError:error.localizedDescription];
         
          block(@"");
     }];
}

-(BOOL)showDiredection
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        
        return YES;
        
    }
    else
        return NO;
}

-(void)mapDiredection:(CLLocationCoordinate2D)startCoor withEnd:(CLLocationCoordinate2D)endCoor withToName:(NSString*)toName withView:(UIView*)superview
{
    [availableMaps removeAllObjects];
    
    NSMutableArray*  mapsName = [[NSMutableArray alloc] init];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
//            NSString *urlString = [NSString stringWithFormat:@"comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=driving", startCoor.latitude, startCoor.longitude,endCoor.latitude, endCoor.longitude];
            NSString *urlString = [NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f&directionsmode=driving",endCoor.latitude, endCoor.longitude];

            NSDictionary *dic = @{@"name": NSLocalizedString(@"Google Maps",@"谷歌地图"),
                              @"url": urlString};
            [availableMaps addObject:dic];
        
            [mapsName addObject:dic[@"name"]];
    }
    
//    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
//            NSString *urlString = [NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=applicationScheme&poiname=fangheng&poiid=BGVIS&lat=%f&lon=%f&dev=0&style=3",
//                               toName, endCoor.latitude, endCoor.longitude];
//        
//            NSDictionary *dic = @{@"name": @"高德地图",
//                              @"url": urlString};
//            [availableMaps addObject:dic];
//        
//            [mapsName addObject:dic[@"name"]];
//    }
    
    if (availableMaps.count>0)
    {
        [UIActionSheet showInView:superview
                    withTitle:NSLocalizedString(@"Select", @"选择")
            cancelButtonTitle:NSLocalizedString(@"Cancel",@"取消")
           destructiveButtonTitle:nil
            otherButtonTitles:mapsName
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                         if (buttonIndex!=availableMaps.count)
                         {
                             NSDictionary *mapDic = availableMaps[buttonIndex];
                             NSString *urlString = mapDic[@"url"];
                             urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                             NSURL *url = [NSURL URLWithString:urlString];
                             LOG(@"\n%@\n%@\n%@", mapDic[@"name"], mapDic[@"url"], urlString);
                             [[UIApplication sharedApplication] openURL:url];
                         }
                       
                     }];
    }
}

@end
