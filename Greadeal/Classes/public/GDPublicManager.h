//
//  GDPublicManager.h
//  WristCentralPos
//
//  Created by tao tao on 20/8/14.
//  Copyright (c) 2014 tao tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "MZTimerLabel.h"

#import <CoreLocation/CoreLocation.h>

@interface GDPublicManager : NSObject<MZTimerLabelDelegate>
{
    //user profile
    NSString* username;
    NSString* password;
    
    NSString* phoneCountry;
    NSString* phonenumber;
    
    int       cid;
    NSString* token;
    NSString* push_token;
    
    NSString* email;
    NSString* emailDomain;
    
    NSString* user_avatar;
    
    int       point;
    int       receive_notice;
    
    LoginType loginstauts;
    //network
    Reachability* _reachability;
    
    NSString* app_version;
    NSString* app_date;
    NSString* app_share_link;
    
    NSMutableArray   *cartsItem;
    MZTimerLabel     *countDownPay;
    
    float            defaultCount;
    
    NSString         *currency;
    BOOL             buy_section_show;

    //member
    NSString         *redeem_url;
    int              memberRank;
    NSString         *memberStartDate; //"date_started": "2015-12-01", #开始时间
    NSString         *memberEndDate;
    BOOL             memberIsExpired; //是否过期
    
    NSMutableArray   *availableMaps;
}

@property(nonatomic,strong) NSMutableArray   *cartsItem;
@property(nonatomic,strong) NSString         *currency;
@property (atomic, strong)  MZTimerLabel     *countDownPay;//s
@property (atomic, assign)  float            defaultCount;//m

@property (atomic, assign)  BOOL             buy_section_show;

@property (atomic, strong)  NSString *username;
@property (atomic, assign)  int cid;
@property (atomic, assign)  int point;
@property (atomic, assign)  int memberRank;

@property (atomic, assign)  int receive_notice;
@property (atomic, assign)  LoginType loginstauts;

@property (atomic, strong)  NSString *token;
@property (atomic, strong)  NSString *push_token;

@property (atomic, strong)  NSString *workPhone;
@property (atomic, strong)  NSString *nonworkPhone;

@property (atomic, strong)  NSString *email;
@property (atomic, strong)  NSString *emailDomain;

@property (atomic, strong)  NSString *user_avatar;

@property (atomic, strong)  NSString *password;
@property (atomic, strong)  NSString *phonenumber;
@property (atomic, strong)  NSString *phoneCountry;
@property (atomic, strong)  NSString *app_version;
@property (atomic, strong)  NSString *app_date;

@property (atomic, strong)  NSString *APIBaseUrl;

@property (atomic, assign)  float screenWidth;
@property (atomic, assign)  float screenScale;

@property (atomic, strong)  NSString *domainUrl;

+ (GDPublicManager *)instance;
@property(nonatomic,strong) Reachability* _reachability;

- (NSString*)getMobileCountryCode;

- (BOOL)getAirPrintStatus;
- (void)setAirPrintStatus:(BOOL)use;

- (NSString*)getAirPrintID;
- (void)setAirPrintID:(NSString*)printID;

- (BOOL)NSStringIsValidEmail:(NSString *)checkString;
- (float)caluArabicTextWidth;

- (void)startupUpload;
- (NSString *)getSha1String:(NSString *)srcString;
- (void)logoutEvent;

- (void)getCartData;
- (BOOL)checkCityChange;

- (BOOL)checkDeliveryAddressChange;

- (NSString*)getShareUrl;
- (void)makeCall:(NSString *)number withView:(UIView*)showView;

- (BOOL)validateNumber:(NSString*)number;

- (void)makeHelp;


///CART
- (void)clearCart;
- (int)getOrderQtyOfVendor:(int)vendor_id;
- (int)getOrderQtyOfProudct:(int)product_id withoption:(int)option_value_id;
- (int)getOrderQtyOfAll;

- (void)deleteProduct:(int)vendor_id withproduct:(int)product_id withoption:(int)option_value_id;
- (void)deleteVendor:(int)vendor_id;
- (NSMutableDictionary*)getVendorOfCart:(int)vendor_id;

///Get City ID
- (void)getCityID;

///Get Category
-(void)getCategory:(categoryType)selType success:(void(^)(NSError *error))block;

///Open Hours
- (NSDictionary*)getDateFormat:(NSString*)startTime withEnd:(NSString*)endTime withDay:(int)day;

///member function
- (BOOL)isVaildFreeBuy:(int)membership_level withNote:(BOOL)showNote;
- (BOOL)isMember;
- (BOOL)isBlueMember;
- (BOOL)isGoldMember;
- (BOOL)isPlatimunMember;
- (NSString*)memberEndDate;
- (BOOL)isExpiredMember;
- (NSString*)memberPhone;
- (int)returnMemberRank;
- (BOOL)isExpiredDate:(NSString*)expireDate;
- (NSString*)minExpiredDate:(NSString*)expireDate;
- (void)getMemberInfo;
- (BOOL)nonMemberFree:(NSArray*)orderArrar;
- (void)updateToken;

//trans chinese
-(void)toChinese:(NSString*)enText success:(void(^)(NSString* translated))block;

-(BOOL)showDiredection;
-(void)mapDiredection:(CLLocationCoordinate2D)startCoor withEnd:(CLLocationCoordinate2D)endCoor withToName:(NSString*)toName withView:(UIView*)superview;


@end
