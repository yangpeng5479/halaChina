//
//  GDMarketAddSelectViewController.h
//  Greadeal
//
//  Created by Elsa on 15/6/16.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDMarketAddSelectViewController : UITableViewController
{
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
    
}

@property (assign) id  target;
@property (assign) SEL callback;

@end
