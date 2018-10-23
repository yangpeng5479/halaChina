//
//  GDEtisalat.h
//  Greadeal
//
//  Created by Elsa on 16/1/25.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GDEtisalat : NSObject

+ (GDEtisalat *)instance;

- (void)callEtisalat:(NSString*)orderId withName:(NSString*)orderName withPrice:(float)price withType:(NSString*)type withNav:(id)superNav withId:(id)superId;

@end
