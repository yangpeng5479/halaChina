//
//  TimeoutAFHTTPRequestSerializer.h
//  Greadeal
//
//  Created by Elsa on 15/8/19.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "AFURLRequestSerialization.h"

@interface TimeoutAFHTTPRequestSerializer : AFHTTPRequestSerializer

@property (nonatomic, assign) NSTimeInterval timeout;

- (id)initWithTimeout:(NSTimeInterval)timeout;

@end
