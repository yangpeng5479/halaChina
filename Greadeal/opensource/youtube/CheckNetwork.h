//
//  CheckNetwork.h
//  CheckNetwork
//
//  Created by Rajesh on 04/06/14.
//  Copyright (c) 2014 Rajesh. All rights reserved.
//

//--**********
//-- Check whether network connection available or not
//--**********

#import <Foundation/Foundation.h>

@interface CheckNetwork : NSObject
{
    
}

//--Check whether network connection available or not
+ (BOOL) isNetwork;

//-- Throw alert when network not available
+ (void) NoNetworkAlert;

//-- Throw alert when exception occurs
+ (void) ExceptionAlert:(NSString *)OccuredString;

@end
