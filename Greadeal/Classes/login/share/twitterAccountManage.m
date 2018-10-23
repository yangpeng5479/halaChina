//
//  twitterAccountManage.m
//  Greadeal
//
//  Created by Elsa on 15/5/22.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "twitterAccountManage.h"

@implementation twitterAccountManage

+ (twitterAccountManage*)sharedInstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (id) init {
    if (self = [super init]) {
        LOG(@"init twitterAccountManage");
    }
    return self;
}

- (void)login
{
    [EasyTwitter sharedEasyTwitterClient].delegate = self;
    [[EasyTwitter sharedEasyTwitterClient] requestPermissionForAppToUseTwitterSuccess:^(BOOL granted, BOOL accountsFound, NSArray *accounts) {
        if (granted)
            NSLog(@"granted!");
        
        if (accountsFound)
        {
            /*
             accountsFound represents an array filled with ACAccount objects.
             This assumes that the user gave permission to the app to access the twitter accounts
             registered with the system (iOS built-in Settings App->Twitter section).
             It also assumes that there are twitter accounts registered with iOS.
             If not, remind the user to set up a twitter account.
             
             You can search through all the ACAccount objects in the array to find the desired account.
             ACAccount contains two properties that are useful:
             .username (Type:string i.e finkd)
             .accountDescription (Type:string i.e. @finkd)
             */
            
            [EasyTwitter sharedEasyTwitterClient].account = [accounts firstObject];
        }
        
        
        
    } failure:^(NSError *error) {
        LOG(@"error: %@", error);
    }];

}
- (void)sendTweetWithImage:(NSString*)message withImage:(NSURL*)url
{
    [[EasyTwitter sharedEasyTwitterClient] sendTweetWithMessage:message imageURL:[NSURL URLWithString:@"https://www.google.com/images/srpr/logo11w.png"] twitterResponse:^(id responseJSON, NSDictionary *JSONError, NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        if (JSONError == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tweet Sent!"
                                                            message:nil
                                                           delegate:self cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            //Twitter error codes can be found here: https://dev.twitter.com/overview/api/response-codes
            //JSON error code 187 - Tweet is duplicate
            //JSON error code 186 - Tweet is too long (over 140 characters)
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error code: %d", [[JSONError objectForKey:@"code"] intValue]]
                                                            message:[JSONError objectForKey:@"message"]
                                                           delegate:self cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    } failure:^(EasyTwitterIssues issue) {
        if (issue == EasyTwitterNoAccountSet)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tweet not sent"
                                                            message:[NSString stringWithFormat:@"No Account set"]
                                                           delegate:self cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)showLoadingScreen:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //Show Load Screen
//        [self.loadScreen removeFromSuperview];
 //       self.loadScreen = [[DBCameraLoadingView alloc] initWithFrame:(CGRect){ 0, 0, 100, 100 }];
//        [self.loadScreen setCenter:self.view.center];
//        [self.view addSubview:self.loadScreen];
    });
}

- (void)hideLoadingScreen:(id)sender
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //Remove Load Screen
//        [self.loadScreen removeFromSuperview];
//        self.loadScreen = nil;
//    });
}


@end
