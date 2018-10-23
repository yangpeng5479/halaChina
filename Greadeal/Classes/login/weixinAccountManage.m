//
//  weixinAccountManage.m
//  haomama
//
//  Created by tao tao on 02/06/13.
//  Copyright (c) 2013年 tao tao. All rights reserved.
//

#import "weixinAccountManage.h"
#import "NSString+Addtional.h"
#import "XMLDictionary.h"

static NSString *appkey = @"wx13c46f62674c7fe0";
static NSString *appSecret = @"6c3a0421cc95705ae0cdce20909a4a8f";

//商户号，填写商户对应参数
#define MCH_ID          @"1358729402"
#define MCH_API_PASS    @"wtgyf86h2j8wy8b3rz7e0gc1fwo2n4ah"
//支付结果回调页面
//#define NOTIFY_URL      @"http://wxpay.weixin.qq.com/pub_v2/pay/notify.v2.php"


#import <ifaddrs.h>
#import <arpa/inet.h>


@implementation weixinAccountManage

@synthesize delegate;

+ (weixinAccountManage*)sharedInstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (id) init {
	if (self = [super init]) {
		LOG(@"init weixinAccountManage version %@:",[WXApi getApiVersion]);
         //向微信注册
        
        BOOL successful=[WXApi registerApp:appkey withDescription:@"162"];
        LOG(@"register successful = %d",successful);
	}
	return self;
}

- (NSString*)getAppid
{
    return appkey;
}

// Get IP Address
- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}


//创建package签名
//-(NSString*)createMd5Sign:(NSMutableDictionary*)dict
-(NSString*)createMd5Sign:(NSMutableDictionary*)dict
{
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray)
    {
        if (![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
        
    }
//    //添加key字段 商户的密钥
    [contentString appendFormat:@"key=%@",MCH_API_PASS];
    //得到MD5 sign签名
    NSString *md5Sign =[contentString MD5String];
    
    //输出Debug Info
    LOG(@"MD5签名字符串：%@",contentString);
    
    return md5Sign;
}

//获取package带参数的签名包
-(NSString *)genPackage:(NSMutableDictionary*)packageParams
{
    NSString *sign;
    NSMutableString *reqPars=[NSMutableString string];
    //生成签名
    sign        = [self createMd5Sign:packageParams];
    //生成xml的package
    NSArray *keys = [packageParams allKeys];
    [reqPars appendString:@"<xml>\n"];
    for (NSString *categoryId in keys) {
        [reqPars appendFormat:@"<%@>%@</%@>\n", categoryId, [packageParams objectForKey:categoryId],categoryId];
    }
    [reqPars appendFormat:@"<sign>%@</sign>\n</xml>",[sign uppercaseString]];
    
    return [NSString stringWithString:reqPars];
}


- (NSString*)convertXMLParserToDictionary:(NSXMLParser *)parser {
    //dictionaryWithXMLParser: 是第三方框架 XMLDictionary 的方法
    NSDictionary *resParams = [NSDictionary dictionaryWithXMLParser:parser];
    NSString*    prepayid = @"";
    //判断返回
    NSString *return_code   = [resParams objectForKey:@"return_code"];
    NSString *result_code   = [resParams objectForKey:@"result_code"];
   
    if ( [return_code isEqualToString:@"SUCCESS"] && [result_code isEqualToString:@"SUCCESS"])
    {
        //生成返回数据的签名
        prepayid =[resParams objectForKey:@"prepay_id"] ;
    }else{
        LOG(@"接口返回错误！！！\n");
    }
    return prepayid;
}

//提交预支付
-(void)sendPrepay:(NSMutableDictionary *)prePayParams
{
    //获取提交支付
    NSString *xmlRequestString  = [self genPackage:prePayParams];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.mch.weixin.qq.com/pay/unifiedorder"]];
    [request setHTTPBody:[xmlRequestString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Accept"];

    
    NSOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
       
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:responseObject];

        //这里使用了第三方框架 XMLDictionary，他本身继承并实现 NSXMLParserDelegate 委托代理协议，对数据进行遍历处理
        NSString* prePayid = [self convertXMLParserToDictionary:parser];
        
        if(prePayid.length<=0)
        {
            LOG(@"获取prepayid失败");
        }
        
        //获取到prepayid后进行第二次签名
        NSString *package, *time_stamp, *nonce_str;
        //设置支付参数
        time_t now;
        time(&now);
        time_stamp = [NSString stringWithFormat:@"%ld",now];
        nonce_str = [time_stamp MD5String];
        //重新按提交格式组包，微信客户端暂只支持package=Sign=WXPay格式，须考虑升级后支持携带package具体参数的情况
        package = @"Sign=WXPay";
        //第二次签名参数列表
        NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
        [signParams setObject: appkey forKey:@"appid"];
        [signParams setObject: MCH_ID forKey:@"partnerid"];
        [signParams setObject: nonce_str forKey:@"noncestr"];
        [signParams setObject: package forKey:@"package"];
        [signParams setObject: time_stamp forKey:@"timestamp"];
        [signParams setObject: prePayid forKey:@"prepayid"];
        
        //生成签名
        NSString *sign = [self createMd5Sign:signParams];
        
        //添加签名
        [signParams setObject: sign forKey:@"sign"];
        
        LOG(@"第二步签名成功，sign＝%@",sign);

        //============================================================
        // V3&V4支付流程实现
        // 注意:参数配置请查看服务器端Demo
        // 更新时间：2015年11月20日
        //============================================================
      
        NSMutableString *stamp  = [signParams objectForKey:@"timestamp"];
        
        //调起微信支付
        PayReq* req      = [[PayReq alloc] init];
        req.openID       = [signParams objectForKey:@"appid"];
        req.partnerId    = [signParams objectForKey:@"partnerid"];
        req.prepayId     = [signParams objectForKey:@"prepayid"];
        req.nonceStr     = [signParams objectForKey:@"noncestr"];
        req.timeStamp    = stamp.intValue;
        req.package      = [signParams objectForKey:@"package"];
        req.sign         = [signParams objectForKey:@"sign"];
        
        BOOL successful =  [WXApi sendReq:req];
        if (!successful)
        {
            if (![self isWXInstalled])
            {
                [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"错误")
                                   message:NSLocalizedString(@"Not installed wechat!", @"没有安装微信!")
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      if (buttonIndex == [alertView cancelButtonIndex]) {
                                         
                                      }
                                  }];
            }
            
            if (delegate!=nil)
            {
                [delegate wechatPayCompleted:NO];
            }
        }

    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         LOG(@"%@",operation.responseObject);
    }];
    
    [manager.operationQueue addOperation:operation];

}

-(void)getPrepayWithOrderName:(NSString*)name
                                         price:(NSString*)price
                                         withNo:(NSString*)TradeNo
                                         withUrl:(NSString*)notifyURL
{
    //订单标题，展示给用户
    NSString* orderName = name;
    //订单金额,单位（分）
    NSString* orderPrice = price;//以分为单位的整数
    //支付类型，固定为APP
    NSString* orderType = @"APP";
    //发器支付的机器ip,暂时没有发现其作用
    NSString* orderIP = [self getIPAddress];
    
    //随机数串
    srand( (unsigned)time(0) );
    NSString *noncestr = [NSString stringWithFormat:@"%d", rand()];
    //NSString *orderNO  = [NSString stringWithFormat:@"%ld",time(0)];
    
    //================================
    //预付单参数订单设置
    //================================
    NSMutableDictionary *packageParams = [NSMutableDictionary dictionary];
    
    [packageParams setObject: appkey forKey:@"appid"];//开放平台appid
    [packageParams setObject: MCH_ID forKey:@"mch_id"];//商户号
    [packageParams setObject: noncestr forKey:@"nonce_str"];//随机串
    [packageParams setObject: orderType forKey:@"trade_type"];//支付类型，固定为APP
    [packageParams setObject: orderName forKey:@"body"];//订单描述，展示给用户
    [packageParams setObject: notifyURL forKey:@"notify_url"];//支付结果异步通知
    [packageParams setObject: TradeNo forKey:@"out_trade_no"];//商户订单号
    [packageParams setObject: orderIP forKey:@"spbill_create_ip"];//发器支付的机器ip
    [packageParams setObject: orderPrice forKey:@"total_fee"];//订单金额，单位为分
    
    NSString *md5Attach =[NSString stringWithFormat:@"order_id=%@%@",TradeNo,MCH_API_PASS];
    [packageParams setObject: [md5Attach MD5String] forKey:@"attach"];//order_id+appkey
    
    //获取prepayId（预支付交易会话标识）
    [self sendPrepay:packageParams];

}

- (void)sendMessageToFriend:(NSDictionary*)parameters
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = parameters[@"title"];
    message.description = parameters[@"description"];
    if (parameters[@"image"]!=nil)
        [message setThumbImage:parameters[@"image"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    if (parameters[@"url"]!=nil)
    {
        ext.webpageUrl = parameters[@"url"];
    }
    else
    {
        ext.webpageUrl = MainWebPage;
    }
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession; //friend cycle WXSceneTimeline
    
    BOOL successful=[WXApi sendReq:req];
    LOG(@"sent successful = %d",successful);

}

- (void)sendMessageToCycle:(NSDictionary*)parameters
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = parameters[@"title"];
    message.description = parameters[@"description"];
    if (parameters[@"image"]!=nil)
        [message setThumbImage:parameters[@"image"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    if (parameters[@"url"]!=nil)
    {
        ext.webpageUrl = parameters[@"url"];
    }
    else
    {
        ext.webpageUrl = MainWebPage;
    }
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    
    BOOL successful=[WXApi sendReq:req];
    LOG(@"sent successful = %d",successful);
}

- (BOOL)isWXInstalled
{
    return [WXApi isWXAppInstalled];
}

#pragma mark -
#pragma mark  weixin
-(void) onResp:(BaseResp*)resp
{
    //注意没有安装weixin的返回 isWXAppInstalled
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
//        NSString *strTitle = [NSString stringWithFormat:@"发送结果"];
//        NSString *strMsg = [NSString stringWithFormat:@"发送媒体消息结果:%d", resp.errCode];
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
    }
    else if([resp isKindOfClass:[SendAuthResp class]])
    {
//        NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
//        NSString *strMsg = [NSString stringWithFormat:@"Auth结果:%d", resp.errCode];
//        
//        [self getAccess_token:resp.errCode];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
    }
    else if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        NSString *strMsg;
        
        switch (resp.errCode) {
            case WXSuccess:
                strMsg = NSLocalizedString(@"Payment Successful", @"支付成功");
                LOG(@"%@",strMsg);
                if (delegate!=nil)
                {
                    [delegate wechatPayCompleted:YES];
                }
                break;
                
            default:
                strMsg = [NSString stringWithFormat:NSLocalizedString(@"Payment Failed retcode = %d, retstr = %@",@"支付失败 代号 = %d, 原因 = %@"), resp.errCode,resp.errStr];
                LOG(@"%@",strMsg);
                if (delegate!=nil)
                {
                    [delegate wechatPayCompleted:NO];
                }
                break;
        }
    }
}

- (void)login
{
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    //req.scope = @"snsapi_userinfo,snsapi_base";
    req.scope = @"snsapi_userinfo";
    req.state = @"0744" ;
    [WXApi sendReq:req];
}

-(void)getAccess_token:(int)returnCode
{
    //https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%d&grant_type=authorization_code",appkey,@"kWXAPP_SECRET",returnCode];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//
    /*
                {
                 "access_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWiusJMZwzQU8kXcnT1hNs_ykAFDfDEuNp6waj-bDdepEzooL_k1vb7EQzhP8plTbD0AgR8zCRi1It3eNS7yRyd5A";
                 "expires_in" = 7200;
                 openid = oyAaTjsDx7pl4Q42O3sDzDtA7gZs;
                 "refresh_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWi2ZzH_XfVVxZbmha9oSFnKAhFsS0iyARkXCa7zPu4MqVRdwyb8J16V8cWw7oNIff0l-5F-4-GJwD8MopmjHXKiA";
                 scope = "snsapi_userinfo,snsapi_base";
                 }
*/
                
                access_token = [dic objectForKey:@"access_token"];
                openid       = [dic objectForKey:@"openid"];
                [self getUserInfo];
            }
        });
    });
}

-(void)getUserInfo
{
    // https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",access_token,openid];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    /*
                 {
                 city = Haidian;
                 country = CN;
                 headimgurl = "http://wx.qlogo.cn/mmopen/FrdAUicrPIibcpGzxuD0kjfnvc2klwzQ62a1brlWq1sjNfWREia6W8Cf8kNCbErowsSUcGSIltXTqrhQgPEibYakpl5EokGMibMPU/0";
                 language = "zh_CN";
                 nickname = "xxx";
                 openid = oyAaTjsDx7pl4xxxxxxx;
                 privilege =     (
                 );
                 province = Beijing;
                 sex = 1;
                 unionid = oyAaTjsxxxxxxQ42O3xxxxxxs;
                 }
                 */
                
                nickname = [dic objectForKey:@"nickname"];
//              self.wxHeadImg.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dic objectForKey:@"headimgurl"]]]];
                
                [GDPublicManager instance].loginstauts = WECHAT;

                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidLoginSuccess object:nil userInfo:nil];
            }
        });
        
    });
}

@end
