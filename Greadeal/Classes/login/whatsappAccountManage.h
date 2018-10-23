//
//  whatsappAccountManage.h
//  Greadeal
//
//  Created by Elsa on 16/3/10.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface whatsappAccountManage : NSObject

+ (whatsappAccountManage*)sharedInstance;
- (BOOL)isInstalled;

- (void)sendMessageToFriend:(NSString*)text withUrl:(NSString*)url;

@end
