//
//  GDPaypal.m
//  Greadeal
//
//  Created by Elsa on 15/7/18.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDPaypal.h"

@implementation GDPaypal

- (id)init
{
    self = [super init];
    if (self)
    {
        // Set up payPalConfig
        payPalConfig = [[PayPalConfiguration alloc] init];
        payPalConfig.acceptCreditCards = NO;
        payPalConfig.merchantName = @"Greadeal";
        payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
        payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
        
        payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
        payPalConfig.rememberUser = YES;
        // Setting the payPalShippingAddressOption property is optional.
        //
        // See PayPalConfiguration.h for details.
        
        payPalConfig.payPalShippingAddressOption = PayPalShippingAddressOptionNone;
        
        // use default environment, should be Production in real life

        self.environment = PayPalEnvironmentProduction;
       
        //self.environment = PayPalEnvironmentSandbox;
        
        
        LOG(@"PayPal iOS SDK version: %@", [PayPalMobile libraryVersion]);
        
        // Preconnect to PayPal early
        [self setPayPalEnvironment:self.environment];
        
        superNav = nil;
    }
    return self;
}

- (void)setPayPalEnvironment:(NSString *)environment {
    self.environment = environment;
    [PayPalMobile preconnectWithEnvironment:environment];
}

- (void)callPaypal:(NSMutableArray*)items withShipFee:(NSDecimalNumber*)shipping withSuper:(id)aSuper  withCard:(BOOL)acceptCreditCards
{
    superNav = aSuper;
    
    NSDecimalNumber *subtotal = [PayPalItem totalPriceForItems:items];
    
    NSDecimalNumber *tax;
    tax = [[NSDecimalNumber alloc] initWithFloat:0];
    
    PayPalPaymentDetails *paymentDetails = [PayPalPaymentDetails paymentDetailsWithSubtotal:subtotal
                                                                               withShipping:shipping
                                                                                    withTax:tax];
    
    NSDecimalNumber *total = [[subtotal decimalNumberByAdding:shipping] decimalNumberByAdding:tax];
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = total;
    payment.currencyCode = PaypalCurrency;
    payment.shortDescription = @"Shopping On Greadeal";
    payment.items = items;  // if not including multiple items, then leave payment.items as nil
    payment.paymentDetails = paymentDetails; // if not including payment details, then leave payment.paymentDetails as nil
    
    if (!payment.processable) {
        // This particular payment will always be processable. If, for
        // example, the amount was negative or the shortDescription was
        // empty, this payment wouldn't be processable, and you'd want
        // to handle that here.
    }
    
    // Update payPalConfig re accepting credit cards.
   
    payPalConfig.acceptCreditCards = acceptCreditCards;
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                            configuration:payPalConfig
                                                delegate:superNav];
    [superNav presentViewController:paymentViewController animated:YES completion:nil];

}

@end
