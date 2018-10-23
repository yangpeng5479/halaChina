//
//  TimeoutAFHTTPRequestSerializer.m
//  Greadeal
//
//  Created by Elsa on 15/8/19.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "TimeoutAFHTTPRequestSerializer.h"

@implementation TimeoutAFHTTPRequestSerializer

- (id)initWithTimeout:(NSTimeInterval)timeout {
    
    self = [super init];
    if (self) {
        self.timeout = timeout;
    }
    return self;
    
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
                                     error:(NSError *__autoreleasing *)error
{
    NSMutableURLRequest *request = [super requestWithMethod:method URLString:URLString parameters:parameters error:error];
    
    if (self.timeout > 0) {
        [request setTimeoutInterval:self.timeout];
    }
    return request;
}


@end
