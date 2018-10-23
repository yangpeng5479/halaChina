//
//  GDDeliveryEditAddressViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/5.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDDeliveryEditAddressViewController : UITableViewController<UITextFieldDelegate>
{
    UITextField* name;
    ACPButton*   countryBut;
    UITextField* phoneNumber;
    UITextField* address;
    
    NSString* selCountry;
    int selCountryId;
    NSString* selCity;
    int selCityId;
    NSString* selCommunity;
    int selCommunityId;
    
    NSDictionary* info;
    
    NSMutableDictionary *countryDict;
    NSMutableDictionary *cityDict;
    NSMutableDictionary *areaDict;

    BOOL  isLoadData;
    int   setDefault; // 1：选择；0：没有选择
}

@property (nonatomic,assign) BOOL canBeChangeArea;
@property (nonatomic,assign) BOOL addNew;
@property (nonatomic,strong) NSDictionary* addressDict;

@end
