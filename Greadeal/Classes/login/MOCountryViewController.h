//
//  MOCountryViewController.h
//  Mozat
//
//  Created by tao tao on 8/2/12.
//  Copyright (c) 2012 MOZAT Pte Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOCountryViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *mainTableView;
    
    NSString *countryCallingCode;
    NSString *mobileCountryCode;
    NSString *phoneNumberLength;
    
    NSMutableDictionary *countryDict;
    NSArray *countryCodeArray;
    NSMutableArray *countryNameArray;
}

@property(assign) id  target;
@property(assign) SEL callback;

@property(nonatomic,retain) NSString*    previousCountryName;
@property(nonatomic,retain) NSString*    countryCallingCode;
@property(nonatomic,retain) NSString*    mobileCountryCode;
@property(nonatomic,retain) NSString*    phoneNumberLength;

-(void)checkLocalCountry;
//-(void)configureInitialCountryCode:(NSString *)cc;

@end
