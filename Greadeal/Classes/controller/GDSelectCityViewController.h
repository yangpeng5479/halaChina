//
//  GDSelectCityViewController.h
//  Greadeal
//
//  Created by Elsa on 15/10/10.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDSelectCityViewController : UITableViewController
{
    NSString* selCountry;
    int selCountryId;
//    NSString* selCity;
//    int selCityId;
    
    NSDictionary* info;
    
    NSMutableDictionary *countryDict;
//    NSMutableDictionary *cityDict;
      
}

@property (assign) id  target;
@property (assign) SEL callback;

@end
