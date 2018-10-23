//
//  AliPayment.h
//  Greadeal
//
//  Created by Elsa on 15/12/29.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Order.h"
#import "DataSigner.h"
#import "APAuthV2Info.h"
#import "AlipayProduct.h"

@protocol AliPayDelegate

- (void)aliPayCompleted:(BOOL)success;

@end

@interface AliPayment : NSObject

+ (AliPayment *)instance;

- (void)callAli:(AlipayProduct*)product withNo:(NSString*)TradeNo withUrl:(NSString*)notifyURL;

@property (nonatomic, weak) id<AliPayDelegate>delegate;

@end
