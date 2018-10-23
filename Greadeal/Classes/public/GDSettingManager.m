//
//  GDSettingManager.m
//  Greadeal
//
//  Created by Elsa on 15/5/11.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDSettingManager.h"

NSString* const kMOIntroPageVersion   = @"$:IntroViewVersion";
NSString* const kMOLastAddtoCartsDate = @"$:LastAddtoCartsDate";

NSString* const kMOUserCityAddress  = @"$:UserCityAddress";
NSString* const kMOUserCityLocation = @"$:UserCityLocation";

NSString* const kMOCityAddress = @"$:CityAddress";
NSString* const kMOMD5Address = @"$:MD5Address";

NSString* const kMODeliveryCity = @"$:DeliveryCity";
NSString* const kMOMD5DeliveryCity = @"$:MD5DeliveryCity";

NSString* const kMOAllStoreCategory = @"$:kMOAllStoreCategory";
NSString* const kMD5AllStoreCategory = @"$:kMOMD5AllStoreCategory";

NSString* const kMODiscountStoreCategory = @"$:kMODiscountStoreCategory";
NSString* const kMD5DiscountStoreCategory = @"$:kMOMD5DiscountStoreCategory";

NSString* const kMOBlueCategory = @"$:kMOBlueCategory";
NSString* const kMD5Blue = @"$:kMD5Blue";
NSString* const kMOGoldCategory = @"$:kMOGoldCategory";
NSString* const kMD5Gold = @"$:kMD5Gold";
NSString* const kMOPlatinumCategory = @"$:kMOPlatinumCategory";
NSString* const kMD5Platinum = @"$:kMD5Platinum";

@implementation GDSettingManager

@synthesize    nTabSale;
@synthesize    nTabCategory;
@synthesize    nTabCarts;
@synthesize    nTabLive;
@synthesize    nTabMe;
@synthesize    isRightToLeft;

@synthesize    nIntroPageVersion;
@synthesize    nLastAddToCartDate;

@synthesize    nUserCity;
@synthesize    cityLocation;

@synthesize    userDeliveryInfo;

@synthesize    nAllAddress;
@synthesize    md5Address;

@synthesize    nDeliveryCity;
@synthesize    md5DeliveryCity;

@synthesize    nAllStoreCategory;
@synthesize    md5AllStoreCategory;

@synthesize    nDiscountStoreCategory;
@synthesize    md5DiscountStoreCategory;

@synthesize    nBlueCategory;
@synthesize    md5BlueCategory;

@synthesize    nGoldCategory;
@synthesize    md5GoldCategory;

@synthesize    nPlatinumCategory;
@synthesize    md5PlatinumCategory;

@synthesize    areaAddress;

@synthesize    switchLanguage;

+ (GDSettingManager *)instance
{
    static GDSettingManager *_sharedObject = nil;
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedObject = [[GDSettingManager alloc] init];
    });
    return _sharedObject;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        // by default send user agent.
        languageCodeToLocalizedName = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       @"العربية", @"ar",
                                       @"Deutsch", @"de",
                                       @"English", @"en",
                                       @"Français", @"fr",
                                       @"Bahasa Indonesia", @"id",
                                       @"Italiano", @"it",
                                       @"日本語", @"ja",
                                       @"한국어", @"ko",
                                       @"русский язык", @"ru",
                                       @"Wikang Tagalog", @"tl",
                                       @"中文", @"zh",
                                       @"简体中文", @"zh-Hans",
                                       @"繁體中文", @"zh-Hant",
                                       @"Vietnamese", @"vi",
                                       nil];
        
        languageCodeToEnglishName = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     @"Arabic", @"ar",
                                     @"German", @"de",
                                     @"English", @"en",
                                     @"French", @"fr",
                                     @"Indonesian", @"id",
                                     @"Italian", @"it",
                                     @"Japanese", @"ja",
                                     @"Korean", @"ko",
                                     @"Russian", @"ru",
                                     @"Tagalog", @"tl",
                                     @"Chinese", @"zh",
                                     @"Chinese", @"zh-Hans",
                                     @"Chinese", @"zh-Hant",
                                     @"Vietnamese", @"vi",
                                     nil];
        
        rightToLeftLanguageCodes = [[NSSet alloc] initWithObjects:@"ar", @"dv", @"ha", @"he", @"fa", @"ps", @"ur", @"yi", nil];
        
        [self reinitializeLanguageSettings];
        
        userDeliveryInfo  = [NSMutableDictionary dictionary];
        
        defaults = [NSUserDefaults standardUserDefaults];
        nIntroPageVersion = MOGetIntValueFromNumber([defaults objectForKey:kMOIntroPageVersion], 0);
        nLastAddToCartDate= MOGetDateValueFromDate([defaults objectForKey:kMOLastAddtoCartsDate], [NSDate dateWithTimeIntervalSince1970:0]);
        
        nUserCity = MOGetDictValueFromDate([defaults objectForKey:kMOUserCityAddress], nil);
        cityLocation = MOGetDictValueFromDate([defaults objectForKey:kMOUserCityLocation], nil);
        
        nAllAddress = MOGetArrayValueFromDate([defaults objectForKey:kMOCityAddress], nil);
        md5Address = MOGetDictValueFromString([defaults objectForKey:kMOMD5Address], @"");
        
        nDeliveryCity = MOGetArrayValueFromDate([defaults objectForKey:kMODeliveryCity], nil);
        md5DeliveryCity = MOGetDictValueFromString([defaults objectForKey:kMOMD5DeliveryCity], @"");
        
        nAllStoreCategory = MOGetArrayValueFromDate([defaults objectForKey:kMOAllStoreCategory], nil);
        md5AllStoreCategory = MOGetDictValueFromString([defaults objectForKey:kMD5AllStoreCategory], @"");
        
        nDiscountStoreCategory = MOGetArrayValueFromDate([defaults objectForKey:kMOAllStoreCategory], nil);
        md5DiscountStoreCategory = MOGetDictValueFromString([defaults objectForKey:kMD5AllStoreCategory], @"");
        
        nBlueCategory = MOGetArrayValueFromDate([defaults objectForKey:kMOBlueCategory], nil);
        md5BlueCategory = MOGetDictValueFromString([defaults objectForKey:kMD5Blue], @"");
        
        nGoldCategory = MOGetArrayValueFromDate([defaults objectForKey:kMOGoldCategory], nil);
        md5GoldCategory = MOGetDictValueFromString([defaults objectForKey:kMD5Gold], @"");
        
        nPlatinumCategory = MOGetArrayValueFromDate([defaults objectForKey:kMOPlatinumCategory], nil);
        md5PlatinumCategory = MOGetDictValueFromString([defaults objectForKey:kMD5Platinum], @"");

        if (nUserCity!=nil)
        {
            _currentCountryId = [nUserCity[@"selCountryId"] intValue];
            _currentCountry = nUserCity[@"selCountry"];
        }
        else
        {
            _currentCountry   = NSLocalizedString(@"UAE",@"阿联酋");
            _currentCountryId = 221;
        }
        
        if (cityLocation==nil)
        {
            cityLocation=@{@"longitude":@(55.17),@"latitude":@(25.13)};
        }
        
        areaAddress = @"";
    }
    return self;
}

-(void)reinitializeLanguageSettings
{
    //below ios9
    NSArray *supportedLanguages = [[NSArray alloc] initWithObjects:
                       @"en",@"ar",@"zh",@"zh-Hans",@"zh-Hant",nil];
    
    NSString* pricipleLanguageCode = [supportedLanguages objectAtIndex:0];
    
    @synchronized(self)
    {
        languageCode = nil;
        
        NSArray* languagesTemp = [NSLocale preferredLanguages];
        
        NSMutableArray* languages = [NSMutableArray new];
        
        for (NSString* strLan in languagesTemp)
        {
            //从尾到头的顺序搜索
            NSRange range=[strLan rangeOfString:@"-" options:NSBackwardsSearch];
            if(range.location==NSNotFound)
            {
                [languages addObject:strLan];
            }
            else
            {
                NSString* strTemp= [strLan substringToIndex:range.location];
                [languages addObject:strTemp];
            }
            
        }
            
        NSString* systemLanguageCode = pricipleLanguageCode;
        
        if(languages.count > 0)
        {
            NSString* code = [languages objectAtIndex:0];
            languageCode = code;
            systemLanguageCode = languageCode;
        }
        else
        {
            languageCode = pricipleLanguageCode;
        }
        
        // must be a supported language, otherwise fallback to principle
        if(![supportedLanguages containsObject:languageCode])
        {
            languageCode = pricipleLanguageCode;
        }
        
        locale = [NSLocale currentLocale];//[[NSLocale alloc] initWithLocaleIdentifier:languageCode];
        
        NSString* name = [languageCodeToLocalizedName objectForKey:languageCode];
        if(name)
        {
            localizedLanguageName = name;
            englishLanguageName = [languageCodeToEnglishName objectForKey:languageCode];
        }
        else
        {
            languageCode = @"en";
            localizedLanguageName = [languageCodeToLocalizedName objectForKey:languageCode];
            englishLanguageName = [languageCodeToEnglishName objectForKey:languageCode];
        }
        
        if([rightToLeftLanguageCodes containsObject:languageCode])
        {
            isRightToLeft = YES;
            nTabSale = 3;
            
            nTabLive = 2;
            nTabCarts = 1;
            nTabMe = 0;
        }
        else
        {
            isRightToLeft = NO;
            nTabSale = 3;
            
            nTabLive = 0;
            nTabCarts = 1;
            nTabMe = 2;
        }

        LOG(@"Language: %@ (%@)", englishLanguageName, localizedLanguageName);
      
    }
}

-(void)setIntroPageVersion:(int)aIntroPageVersion
{
    if(nIntroPageVersion != aIntroPageVersion)
    {
        nIntroPageVersion = aIntroPageVersion;
        [defaults setObject:[NSNumber numberWithInt:nIntroPageVersion] forKey:kMOIntroPageVersion];
        [defaults synchronize];
    }
}

-(void)setLastAddToCartDate
{
    nLastAddToCartDate = [NSDate date]; // now time
    [defaults setObject:nLastAddToCartDate forKey:kMOLastAddtoCartsDate];
    [defaults synchronize];
}

-(void)saveUserCity:(NSDictionary*)userAddress
{
    if(nUserCity != userAddress)
    {
        nUserCity = userAddress;
        [defaults setObject:userAddress forKey:kMOUserCityAddress];
        [defaults synchronize];
    }
}

-(void)saveCityLocation:(NSDictionary*)userLocation
{
    if(cityLocation != userLocation)
    {
        cityLocation = userLocation;
        [defaults setObject:cityLocation forKey:kMOUserCityLocation];
        [defaults synchronize];
    }
}

-(double)getCityLongitude
{
    return [cityLocation[@"longitude"] doubleValue];
}

-(double)getCityLatitude
{
    return [cityLocation[@"latitude"] doubleValue];
}

-(void)setAllAddress:(NSArray*)nArrar
{
    if(nAllAddress != nArrar)
    {
        nAllAddress = nArrar;
        [defaults setObject:nAllAddress forKey:kMOCityAddress];
        [defaults synchronize];
    }
}

-(void)setMD5Address:(NSString*)nMd5
{
    if(md5Address != nMd5)
    {
        md5Address = nMd5;
        [defaults setObject:md5Address forKey:kMOMD5Address];
        [defaults synchronize];
    }
}

-(void)setDeliveryCity:(NSArray*)nArrar
{
    if(nDeliveryCity != nArrar)
    {
        nDeliveryCity = nArrar;
        [defaults setObject:nDeliveryCity forKey:kMODeliveryCity];
        [defaults synchronize];
    }
}

-(void)setMD5DeliveryCity:(NSString*)nMd5
{
    if(md5DeliveryCity != nMd5)
    {
        md5DeliveryCity = nMd5;
        [defaults setObject:md5DeliveryCity forKey:kMOMD5DeliveryCity];
        [defaults synchronize];
    }
}

-(void)setStoreCategory:(NSArray*)nArrar withType:(categoryType)cateType
{
    switch (cateType) {
        case CATEGORY_DISCOUNT_STORE:
            nDiscountStoreCategory = nArrar;
            [defaults setObject:nArrar forKey:kMODiscountStoreCategory];
            break;
        case CATEGORY_ALL_STORE:
            nAllStoreCategory = nArrar;
            [defaults setObject:nArrar forKey:kMOAllStoreCategory];
            break;
        case CATEGORY_BLUE_STORE:
            nBlueCategory = nArrar;
            [defaults setObject:nArrar forKey:kMOBlueCategory];
            break;
        case CATEGORY_GOLD_STORE:
            nGoldCategory = nArrar;
            [defaults setObject:nArrar forKey:kMOGoldCategory];
            break;
        case CATEGORY_PLATINUM_STORE:
            nPlatinumCategory = nArrar;
            [defaults setObject:nArrar forKey:kMOPlatinumCategory];
            break;
        default:
            break;
    }
  
    [defaults synchronize];
}

-(void)setMD5StoreCategory:(NSString*)nMd5 withType:(categoryType)cateType
{
    switch (cateType) {
        case CATEGORY_DISCOUNT_STORE:
            md5DiscountStoreCategory = nMd5;
            [defaults setObject:nMd5 forKey:kMD5DiscountStoreCategory];
            break;
        case CATEGORY_ALL_STORE:
            md5AllStoreCategory = nMd5;
            [defaults setObject:nMd5 forKey:kMD5AllStoreCategory];
            break;
        case CATEGORY_BLUE_STORE:
            md5BlueCategory = nMd5;
            [defaults setObject:nMd5 forKey:kMD5Blue];
            break;
        case CATEGORY_GOLD_STORE:
            md5GoldCategory = nMd5;
            [defaults setObject:nMd5 forKey:kMD5Gold];
            break;
        case CATEGORY_PLATINUM_STORE:
            md5PlatinumCategory = nMd5;
            [defaults setObject:nMd5 forKey:kMD5Platinum];
            break;
        default:
            break;
    }
    
    [defaults synchronize];
  
}

-(void)setTitleAttr:(TTTAttributedLabel*)label withTitle:(NSString*)aTitle withSale:(int)salePrice withOrigin:(int)originPrice
{
     NSString* titleSale = @"";
     NSString* titleOrigin=@"";
    
     if (salePrice>0 && originPrice>0)
     {
         titleSale = [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, salePrice];
    
         titleOrigin = [NSString stringWithFormat:@"%@%d",[GDPublicManager instance].currency, originPrice];
     }
    
     NSString* sumTitle = [NSString stringWithFormat:@"%@ %@ %@",aTitle,titleSale,titleOrigin];
    
     [label setText:sumTitle afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange redRange = [[mutableAttributedString string] rangeOfString:titleSale options:NSCaseInsensitiveSearch];
        NSRange strikeRange = [[mutableAttributedString string] rangeOfString:titleOrigin options:NSCaseInsensitiveSearch];
        
        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
//        UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:12];
//        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
//        if (font) {
//            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
         [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)MOColorSaleFontColor().CGColor range:redRange];
         
         [mutableAttributedString addAttribute:kTTTStrikeOutAttributeName value:@YES range:strikeRange];
//            CFRelease(font);
//       }
        
        return mutableAttributedString;
    }];
}

-(int)language_id:(BOOL)forceEN
{
//    if (forceEN)
//    {
//        return 1;
//    }
//    else
//    {
        if ([languageCode isEqualToString:@"ar"])
        {
            return 2;
        }
        else if ([languageCode isEqualToString:@"zh"])
        {
            return 3;
        }
        else if ([languageCode isEqualToString:@"zh-Hant"])
        {
            return 3;
        }
        else if ([languageCode isEqualToString:@"zh-Hans"])
        {
            return 3;
        }
        else //en
        {
            return 1;
        }
 //   }
}

-(BOOL)isChinese
{
    //zh-Hant
    if ([languageCode isEqualToString:@"zh-Hans"] || [languageCode isEqualToString:@"zh-Hant"])
        return YES;
    else
        return NO;
}

-(BOOL)isSwitchChinese
{
    if (switchLanguage == 3)
        return YES;
    else
        return NO;
}

-(int)checkCity:(NSString*)cityName
{
    NSDictionary* info = nil;
    
    NSArray* tempArrar = [GDSettingManager instance].nDeliveryCity;
    if (tempArrar.count>0)
    {
       info = [tempArrar objectAtIndex:0];
    }

    if (info!=nil)
    {
        NSArray* tempArray = nil;
        SET_IF_NOT_NULL(tempArray,info[@"zone_list"]);
        
        for (NSDictionary* dict in tempArray)
        {
            NSString*  getcityName = @"";
            int        getcityId = [dict[@"zone_id"] intValue];
            SET_IF_NOT_NULL(getcityName, dict[@"name"]);
            
            if ([cityName compare:getcityName options:NSCaseInsensitiveSearch]==NSOrderedSame)
            {
                return getcityId;
            }
            
        }
    }
    return -1;
}

-(int)checkArea:(NSString*)areaName withCityID:(int)selCityId
{
    NSDictionary* info = nil;
    
    NSArray* tempArrar = [GDSettingManager instance].nDeliveryCity;
    if (tempArrar.count>0)
    {
        info = [tempArrar objectAtIndex:0];
    }
    
    if (info!=nil)
    {
        NSArray* tempArray = nil;
        SET_IF_NOT_NULL(tempArray,info[@"zone_list"]);
        
        NSArray* areaArray = nil;
        
        for (NSDictionary* dict in tempArray)
        {
            int  getcityId = [dict[@"zone_id"] intValue];
            if (getcityId==selCityId)
            {
                SET_IF_NOT_NULL(areaArray,dict[@"area_list"]);
                break;
            }
        }
        
        
        if (areaArray!=nil)
        {
            for (NSDictionary* dict in areaArray)
            {
                
                NSString*  getareaName = @"";
                int        getareaId = [dict[@"area_id"] intValue];
                SET_IF_NOT_NULL(getareaName,dict[@"name"]);
                
                //same
                if ([areaName compare:getareaName options:NSCaseInsensitiveSearch]==NSOrderedSame)
                {
                    [userDeliveryInfo setObject:getareaName forKey:@"selArea"];
                    return getareaId;
                }
                
                //if include
                NSRange findsuccess = [areaName rangeOfString:getareaName];
                if (findsuccess.location != NSNotFound)
                {
                    [userDeliveryInfo setObject:getareaName forKey:@"selArea"];
                    return getareaId;
                }
                
                findsuccess = [getareaName rangeOfString:areaName];
                if (findsuccess.location != NSNotFound)
                {
                    [userDeliveryInfo setObject:getareaName forKey:@"selArea"];
                    return getareaId;
                }
            }
        }

    }
    
    return -1;
}

-(NSString*)searchAarea:(int)areaId withCityID:(int)selCityId
{
    NSDictionary* info = nil;
    
    NSArray* tempArrar = [GDSettingManager instance].nDeliveryCity;
    if (tempArrar.count>0)
    {
        info = [tempArrar objectAtIndex:0];
    }
    
    if (info!=nil)
    {
        NSArray* tempArray = nil;
        SET_IF_NOT_NULL(tempArray,info[@"zone_list"]);
        
        NSArray* areaArray = nil;
        
        for (NSDictionary* dict in tempArray)
        {
            int  getcityId = [dict[@"zone_id"] intValue];
            if (getcityId==selCityId)
            {
                SET_IF_NOT_NULL(areaArray,dict[@"area_list"]);
                break;
            }
        }
        
        
        if (areaArray!=nil)
        {
            for (NSDictionary* dict in areaArray)
            {
                
                NSString*  getareaName = @"";
                int        getareaId = [dict[@"area_id"] intValue];
                SET_IF_NOT_NULL(getareaName,dict[@"name"]);
                
                //same
                if (areaId == getareaId)
                {
                    [userDeliveryInfo setObject:getareaName forKey:@"selArea"];
                    return getareaName;
                }
                
            }
        }
        
    }
    return @"";
}

-(NSString*)getCountryShort
{
    if ([_currentCountry isEqualToString:@"United Arab Emirates"])
    {
        return NSLocalizedString(@"UAE",@"阿联酋");
    }
    
    return _currentCountry;
}


MO_INLINE NSString* MOGetDictValueFromString(NSString* number, NSString* defaultValueIfNil)
{
    if(number)
    {
        return number;
    }
    else
    {
        return defaultValueIfNil;
    }
}

MO_INLINE int MOGetIntValueFromNumber(NSNumber* number, int defaultValueIfNil)
{
    if(number)
    {
        return [number intValue];
    }
    else
    {
        return defaultValueIfNil;
    }
}

MO_INLINE NSDate* MOGetDateValueFromDate(NSDate* number, NSDate* defaultValueIfNil)
{
    if(number)
    {
        return number;
    }
    else
    {
        return defaultValueIfNil;
    }
}

MO_INLINE NSDictionary* MOGetDictValueFromDate(NSDictionary* number, NSDictionary* defaultValueIfNil)
{
    if(number)
    {
        return number;
    }
    else
    {
        return defaultValueIfNil;
    }
}

MO_INLINE NSArray* MOGetArrayValueFromDate(NSArray* number, NSArray* defaultValueIfNil)
{
    if(number)
    {
        return number;
    }
    else
    {
        return defaultValueIfNil;
    }
}
@end
