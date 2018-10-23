//
//  whatsappAccountManage.m
//  Greadeal
//
//  Created by Elsa on 16/3/10.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "whatsappAccountManage.h"

@implementation whatsappAccountManage

+ (whatsappAccountManage*)sharedInstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (id) init {
    if (self = [super init]) {
    }
    return self;
}

- (BOOL)isInstalled
{
    NSString* shareUrl = [NSString stringWithFormat:@"whatsapp://"];
    
    NSURL *whatsappURL = [NSURL URLWithString:shareUrl];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL])
    {
        return YES;
    }
    else
        return NO;
}

- (void)sendMessageToFriend:(NSString*)text withUrl:(NSString*)url
{
    CFStringRef originalURLString = (__bridge CFStringRef)[NSString stringWithFormat:@"%@ %@", text,url];
//    CFStringRef preprocessedURLString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, originalURLString, CFSTR(""), kCFStringEncodingUTF8);
    NSString *urlString = (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, originalURLString, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
    NSString *whatsAppURLString = [NSString stringWithFormat:@"whatsapp://send?text=%@", urlString];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:whatsAppURLString]];

}

@end
