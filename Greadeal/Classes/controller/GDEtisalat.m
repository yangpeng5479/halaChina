//
//  GDEtisalat.m
//  Greadeal
//
//  Created by Elsa on 16/1/25.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDEtisalat.h"
#import "GDEtisalatWebViewController.h"
#import "GDReturnsViewController.h"

@implementation GDEtisalat

+ (GDEtisalat *)instance
{
    static GDEtisalat *_sharedObject = nil;
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedObject = [[GDEtisalat alloc] init];
    });
    return _sharedObject;
}

- (void)callEtisalat:(NSString*)orderId withName:(NSString*)orderName withPrice:(float)price  withType:(NSString*)type withNav:(id)superNav  withId:(id)superId
{
    //first get payment url
    
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Etisalat/register"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    NSDictionary *parameters;
    
    parameters = @{@"order_id":orderId,@"order_name":orderName,@"amount":@(price),@"type":type};
    
    [ProgressHUD show:NSLocalizedString(@"Waiting Payment...",@"等待支付...")];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [ProgressHUD dismiss];
         LOG(@"JSON: %@", responseObject);
         
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             NSDictionary* dict = responseObject[@"data"];
             
             NSString* PaymentPortal=@"";
             NSString* TransactionID=@"";
             
             SET_IF_NOT_NULL(PaymentPortal, dict[@"PaymentPortal"]);
             SET_IF_NOT_NULL(TransactionID, dict[@"TransactionID"]);
             
             if (PaymentPortal.length>0 && TransactionID.length>0)
             {
                 GDEtisalatWebViewController* nv = [[GDEtisalatWebViewController alloc] init:PaymentPortal withPOST:TransactionID];
                 nv.delegate = superId;
                 [superNav pushViewController:nv animated:YES];
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
         [ProgressHUD showError:error.localizedDescription];
     }];
}

@end

