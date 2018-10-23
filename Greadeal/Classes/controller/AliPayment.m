//
//  AliPayment.m
//  Greadeal
//
//  Created by Elsa on 15/12/29.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import "AliPayment.h"

@implementation AliPayment

@synthesize delegate;

+ (AliPayment *)instance
{
    static AliPayment *_sharedObject = nil;
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedObject = [[AliPayment alloc] init];
    });
    return _sharedObject;
}

- (void)callAli:(AlipayProduct*)product withNo:(NSString*)TradeNo withUrl:(NSString*)notifyURL
{
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"2088121301455215";
    NSString *seller  = @"business@greadeal.com";
    NSString *privateKey = @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAOxoI5Kzf9iw6lM+pWLjgWiZKh0X6uLXKETpsGRzJH6c6Qr9rhOEhoA0R3Tr3aK+dJ2rOC6lyltaohUZhrjQWl4Ux8FohUsJNVa2oVDAMyvMt4Exl8CxewAGA8hxGDkfyb6iKT2bTu9s5e/Qjak8aNDCr0mikixOFWYJT8qHNbrJAgMBAAECgYEAkyzB+LKHBQAe4XQ+wjGgft3bugEJ2e7Yww45IlAMiEZnTtBfbwcyNN5XHhM5B/hJ4V6Wu3O7ZuQlw70Agk4z8uuy4BgaFHNQL0aMVQjJw6V6dKaYnNtCdUGKBjXYYgv8gAngfshMeAdoXa3ljvyfo9pHYLYBFYD/5ajMOsgUA4ECQQD/un/J4u89isvW27gyBpQXROIcs3hioC8kB5vffQsVWmNsaXx6n66EgYTyTK0bCAs2P4IEZkAD+trPf3Z55hX/AkEA7Khje7v67vmin/MzoQ4yN5Fg1PWHOsfWri/thfgxoKF6Fzn6S8hZesL0d26VHUVC4EtEuRC+ssdgmuGSxSL/NwJAJsJQjfvMQOqhfH4uy749gc1Z6/mznFck7fQNRvE/1cuuWAcg68D6BXFQAh1m+zrb4Cv9+8a3myLROTPbdBxQZwJAUK6L1BhfUW/MEKnyVRso5abrk07tvo141EPEv6LBEJlcrWR3v7RbRS4H+Fu7/JGrXhprIIjj6sFsXwE+b3Uh+wJBAO+qBMe0kK6iax4R99DgxK37htS1Fl2cjygRCon+lpCugIdCF50Etveg6pe2v1zP5zs+odfM6ylxqBypn8zLezg=";
    /*============================================================================*/
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller  = seller;
    order.tradeNO = TradeNo; //订单ID（由商家自行制定）
    order.productName = product.subject; //商品标题
    order.productDescription = product.body; //商品描述
    order.amount = [NSString stringWithFormat:@"%.2f",product.price]; //商品价格
    order.notifyURL = notifyURL; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    order.currency = PaypalCurrency;
    order.forex_biz = @"FP";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"Greadeal";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
//            返回结果需要通过 resultStatus 以及 result 字段的值来综合判断并确定支付结果。 在 resultStatus=9000,并且 success="true"以及 sign="xxx"校验通过的情况下,证￼￼￼明支付成功。
            LOG(@"reslut = %@",resultDic);
            //delegate callback
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
                if (delegate!=nil)
                {
                    [delegate aliPayCompleted:YES];
                }
            }
            else
            {
                if (delegate!=nil)
                {
                    [delegate aliPayCompleted:NO];
                }
            }
        }];
    }

}

@end
