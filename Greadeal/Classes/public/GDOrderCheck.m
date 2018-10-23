//
//  GDOrderCheck.m
//  Greadeal
//
//  Created by Elsa on 15/7/8.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDOrderCheck.h"

@implementation GDOrderCheck

+ (GDOrderCheck *)instance
{
    static GDOrderCheck *_sharedObject = nil;
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedObject = [[GDOrderCheck alloc] init];
    });
    return _sharedObject;
}

- (NSString *)removeSpaceAndNewline:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}


- (NSString*)genJsonStr:(NSArray*)orderArrar
{
    NSMutableArray* checkData = [[NSMutableArray alloc] init];
    NSString *jsonStr = @"";
    
    if (orderArrar!=nil)
    {
        for (NSDictionary* obj in orderArrar)
        {
            NSDictionary* objData  = nil;
            
            int product_id = [obj[@"product_id"] intValue];
            int option_value_id = [obj[@"option_value_id"] intValue];
            int order_qty = [obj[@"order_qty"] intValue];
            
            if (option_value_id>0)
            {
                //"options": [{"option_value_id":"73"},{"option_value_id":"75"}]}]
                //format changed

                NSDictionary* option_values  = @{@"option_value_id":@(option_value_id)};
                NSArray *options = [[NSArray alloc] initWithObjects:
                                    option_values,nil];
               
                
                objData = @{@"product_id":@(product_id),@"options":options,@"count":@(order_qty)};
            }
            else
            {
                objData = @{@"product_id":@(product_id),@"count":@(order_qty)};
            }
            
            [checkData addObject:objData];
        }
        
        if (checkData.count>0)
        {
            NSData *data = [NSJSONSerialization dataWithJSONObject:checkData options:NSJSONWritingPrettyPrinted error:nil];
            jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            //jsonStr = [self removeSpaceAndNewline:jsonStr];
        }
    }
    return jsonStr;
}

- (void)getOrderPrice:(NSArray*)orderArrar withReturn:(int)nSection
{
    if (orderArrar!=nil)
    {
         NSString *jsonStr = [self genJsonStr:orderArrar];
        
         NSString* url;
            url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/billing/get_product_list_total"];
            
            NSDictionary *parameters=@{@"product_list_json":jsonStr};
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            [manager POST:url
               parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 int status = [responseObject[@"status"] intValue];
                 if (status==1)
                 {
                     float dataPrice = [responseObject[@"data"][@"total"] floatValue];
                  
                     if (self.callback!=nil)
                     {
                        NSDictionary *para=@{@"sprice":@(dataPrice),@"section":@(nSection)};
                             
                        [self.target performSelector:self.callback withObject:para afterDelay:0];
                             
                        self.callback = nil;
                         
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
                 LOG(@"%@",operation.responseObject);
                 [ProgressHUD showError:error.localizedDescription];
             }];
    }
}

- (void)checkVaild:(NSArray*)orderArrar withReturn:(int)nSection
{
    __block BOOL isNormal = YES;
    NSMutableArray* checkData = [[NSMutableArray alloc] init];
    if (orderArrar!=nil)
    {
        for (NSDictionary* obj in orderArrar)
        {
            NSDictionary* objData  = nil;
            
            int product_id = [obj[@"product_id"] intValue];
            int option_value_id = [obj[@"option_value_id"] intValue];
            if (option_value_id>0)
            {
                objData = @{@"product_id":@(product_id),@"option_value_id":@(option_value_id)};
            }
            else
            {
                objData = @{@"product_id":@(product_id)};
            }
            
            [checkData addObject:objData];
        }
        
        if (checkData.count>0)
        {
            NSData *data = [NSJSONSerialization dataWithJSONObject:checkData options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonStr = [[NSString alloc] initWithData:data
                                                      encoding:NSUTF8StringEncoding];
            
            NSString* url;
            url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/product/check_products_quantity"];
            
            NSDictionary *parameters=@{@"product_json":jsonStr};
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            [manager POST:url
               parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 int status = [responseObject[@"status"] intValue];
                 if (status==1)
                 {
                     NSArray* result = responseObject[@"data"];
                     for (NSDictionary* obj in result)
                     {
                         int product_id = [obj[@"product_id"] intValue];
                         int option_value_id = [obj[@"option_value_id"] intValue];
                         int quantity = 0;
                         if(obj[@"quantity"] != [NSNull null] && obj[@"quantity"] != nil)
                         {
                            quantity = [obj[@"quantity"] intValue];
                         }
                         
                         for (NSDictionary* orderObj in orderArrar)
                         {
                             int order_product_id = [orderObj[@"product_id"] intValue];
                             int order_option_value_id = [orderObj[@"option_value_id"] intValue];
                             int order_qty = [orderObj[@"order_qty"] intValue];
                             NSString* name = orderObj[@"name"];
                             if (option_value_id>0)
                             {
                                 if (product_id == order_product_id && option_value_id == order_option_value_id)
                                 {
                                     if (quantity<order_qty)
                                     {
                                         isNormal = NO;
                                         
                                         NSString* strInfo = [NSString stringWithFormat:NSLocalizedString(@"Oops,%@ Order quantity over inventory!", @"%@ 订购数量,超过库存数量!"),name];
                                         
                                         [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                                                            message:strInfo
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil
                                                           tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                               if (buttonIndex == [alertView cancelButtonIndex]) {
                                                                   
                                                               }
                                                           }];
                                     }
                                 }
                             }
                             else
                             {
                                 if (product_id == order_product_id)
                                 {
                                     if (quantity<order_qty)
                                     {
                                         isNormal = NO;
                                         
                                         NSString* strInfo = [NSString stringWithFormat:NSLocalizedString(@"Oops,%@ Order quantity over inventory!", @"%@ 订购数量,超过库存数量!"),name];
                                         
                                         [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                                                            message:strInfo
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil
                                                           tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                               if (buttonIndex == [alertView cancelButtonIndex]) {
                                                                   
                                                               }
                                                           }];
                                     }
                                 }
                             }
                         }
                     }
                     
                     if (isNormal)
                     {
                         if (self.callback!=nil)
                         {
                             if ([self.target respondsToSelector:self.callback])
                             {
                                 NSDictionary *para=@{@"section":@(nSection)};
                                 
                                 [self.target performSelector:self.callback withObject:para afterDelay:0];
                                 self.callback = nil;
                             }
                         }
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
                 LOG(@"%@",operation.responseObject);
                 [ProgressHUD showError:error.localizedDescription];
             }];
            
        }
    }

}

-(void)checkRepeatVoucher:(int)vendor_id withProuct:(NSArray*)productData success:(void(^)(BOOL noRepeat))block
{
    NSString *jsonStr = [self genJsonStr:productData];
    
    NSString* url;
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/order/membership_could_order"];
    
    NSDictionary *parameters=@{@"product_list_json":jsonStr,@"vendor_id":@(vendor_id),@"token":[GDPublicManager instance].token,@"payment_code":@"membership_card",@"language_id":@([[GDSettingManager instance] language_id:NO])};
       
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             int could_order = [responseObject[@"data"][@"could_order"] intValue];
             if (could_order == 1)
                 block(YES);
             else
                 block(NO);
         }
         else
         {
             //ERROR_MEMBERSHIP_CARD_LOWER'=>'40002 #会员等级不够',
             //ERROR_MEMBERSHIP_CARD_MORE'=>'40003  #会员不能重复购买优惠劵',
             if (status == 40003)
             {
                 [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                                    message:NSLocalizedString(@"You have already purchased this coupon, please check it at Me->Coupons. Welcome to purchase again after use.", @"您已经购买了这个优惠券,请在我的->优惠券 中查看.请使用后,继续购买")
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil
                                   tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       if (buttonIndex == [alertView cancelButtonIndex]) {
                                           
                                       }
                                   }];
             }
             block(NO);
        }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         LOG(@"%@",operation.responseObject);
         [ProgressHUD showError:error.localizedDescription];
         
         block(NO);
     }];

}

@end
