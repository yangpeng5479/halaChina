//
//  AlipayProduct.h
//  Greadeal
//
//  Created by Elsa on 15/12/29.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlipayProduct : NSObject
{
    float     price;
    NSString *subject;
    NSString *body;
    NSString *orderId;
}

@property(nonatomic, assign) float price;
@property(nonatomic, strong) NSString *subject;
@property(nonatomic, strong) NSString *body;
@property(nonatomic, strong) NSString *orderId;

@end
