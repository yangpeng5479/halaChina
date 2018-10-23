//
//  GDPaypal.h
//  Greadeal
//
//  Created by Elsa on 15/7/18.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayPalMobile.h"
#import "PayPalConfiguration.h"


@interface GDPaypal : NSObject
{
    id  superNav;
    //paypal
    PayPalConfiguration *payPalConfig;
}
@property(nonatomic, strong, readwrite) NSString *environment;

- (void)callPaypal:(NSMutableArray*)items withShipFee:(NSDecimalNumber*)shipping withSuper:(id)aSuper withCard:(BOOL)acceptCreditCards;

@end
