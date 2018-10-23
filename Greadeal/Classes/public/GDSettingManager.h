//
//  GDSettingManager.h
//  Greadeal
//
//  Created by Elsa on 15/5/11.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTTAttributedLabel.h"

@interface GDSettingManager : NSObject
{
    NSDictionary* languageCodeToLocalizedName;
    NSDictionary* languageCodeToEnglishName;
    NSSet* rightToLeftLanguageCodes;
    
    BOOL      isRightToLeft;
    NSString* languageCode;
    NSString* englishLanguageName;
    NSString* localizedLanguageName;
    NSLocale* locale;

    int       nTabSale;
    int       nTabCategory;
    int       nTabCarts;
    int       nTabLive;
    int       nTabMe;

    NSUserDefaults* defaults;
    int             nIntroPageVersion;
    NSDate*         nLastAddToCartDate;
    
    NSDictionary*   nUserCity;
    NSDictionary*   cityLocation;
    
    NSMutableDictionary*   userDeliveryInfo;
    
    NSArray*        nAllAddress;
    NSString*       md5Address;

    NSArray*        nDeliveryCity;
    NSString*       md5DeliveryCity;
    
    ////一共5种列表，所有商家，优惠商家， blue gold platinum
    NSArray*        nAllStoreCategory;
    NSString*       md5AllStoreCategory;
    
    NSArray*        nDiscountStoreCategory;
    NSString*       md5DiscountStoreCategory;
    
    NSArray*        nBlueCategory;
    NSString*       md5BlueCategory;
    
    NSArray*        nGoldCategory;
    NSString*       md5GoldCategory;
    
    NSArray*        nPlatinumCategory;
    NSString*       md5PlatinumCategory;
    
    NSString*       areaAddress;
}

@property(nonatomic,readonly) int  nTabSale;
@property(nonatomic,readonly) int  nTabCategory;
@property(nonatomic,readonly) int  nTabCarts;
@property(nonatomic,readonly) int  nTabLive;
@property(nonatomic,readonly) int  nTabMe;
@property(nonatomic,readonly) BOOL isRightToLeft;

@property(nonatomic,retain)   NSString* areaAddress;

@property(nonatomic,readonly) int nIntroPageVersion;
@property(nonatomic,readonly) NSDate* nLastAddToCartDate;

@property(nonatomic,readonly) NSDictionary* nUserCity;
@property(nonatomic,readonly) NSDictionary* cityLocation;

@property(nonatomic,readonly) NSMutableDictionary* userDeliveryInfo;

@property(nonatomic,readonly) NSArray*  nAllAddress;
@property(nonatomic,readonly) NSString* md5Address;

@property(nonatomic,readonly) NSArray*  nDeliveryCity;
@property(nonatomic,readonly) NSString* md5DeliveryCity;

@property(nonatomic,readonly) NSArray*  nAllStoreCategory;
@property(nonatomic,readonly) NSString* md5AllStoreCategory;

@property(nonatomic,readonly) NSArray*  nDiscountStoreCategory;
@property(nonatomic,readonly) NSString* md5DiscountStoreCategory;

@property(nonatomic,readonly) NSArray*  nBlueCategory;
@property(nonatomic,readonly) NSString* md5BlueCategory;
@property(nonatomic,readonly) NSArray*  nGoldCategory;
@property(nonatomic,readonly) NSString* md5GoldCategory;
@property(nonatomic,readonly) NSArray*  nPlatinumCategory;
@property(nonatomic,readonly) NSString* md5PlatinumCategory;

@property(nonatomic,assign)   int       currentCountryId;
@property(nonatomic,retain)   NSString* currentCountry;

@property(nonatomic,assign)   int       switchLanguage;

+ (GDSettingManager *)instance;

-(void)setIntroPageVersion:(int)aIntroPageVersion;
-(void)setLastAddToCartDate;

-(void)saveUserCity:(NSDictionary*)userAddress;

-(void)saveCityLocation:(NSDictionary*)userLocation;
-(double)getCityLongitude;
-(double)getCityLatitude;

-(void)setAllAddress:(NSArray*)nArrar;
-(void)setMD5Address:(NSString*)nMd5;

-(void)setDeliveryCity:(NSArray*)nArrar;
-(void)setMD5DeliveryCity:(NSString*)nMd5;

-(void)setStoreCategory:(NSArray*)nArrar withType:(categoryType)cateType;
-(void)setMD5StoreCategory:(NSString*)nMd5 withType:(categoryType)cateType;

-(int)language_id:(BOOL)forceEN;
-(BOOL)isChinese;
-(BOOL)isSwitchChinese;

-(void)setTitleAttr:(TTTAttributedLabel*)label withTitle:(NSString*)aTitle withSale:(int)salePrice withOrigin:(int)originPrice;

-(int)checkCity:(NSString*)cityName;
-(int)checkArea:(NSString*)areaName withCityID:(int)selCityId;
-(NSString*)searchAarea:(int)areaId withCityID:(int)selCityId;

-(NSString*)getCountryShort;

@end
