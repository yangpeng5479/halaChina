//
//  GDOrderCheck.h
//  Greadeal
//
//  Created by Elsa on 15/7/8.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GDOrderCheck : NSObject

@property (assign) id  target;
@property (assign) SEL callback;

+ (GDOrderCheck *)instance;

- (NSString*)genJsonStr:(NSArray*)orderArrar;
- (void)getOrderPrice:(NSArray*)orderArrar withReturn:(int)nSection;
- (void)checkVaild:(NSArray*)orderArrar withReturn:(int)nSection;

-(void)checkRepeatVoucher:(int)vendor_id withProuct:(NSArray*)productData success:(void(^)(BOOL noRepeat))block;

@end
