//
//  WCDatabaseManager.h
//  WristCentralPos
//
//  Created by tao tao on 20/8/14.
//  Copyright (c) 2014 tao tao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"
#import "FMDatabaseQueue.h"

@interface WCDatabaseManager : NSObject
{
     FMDatabaseQueue *_queue;
}

+ (WCDatabaseManager *)instance;

- (NSMutableDictionary*)getUserInfo;
- (BOOL)Login:(NSString*)email withid:(int)cid withCountry:(NSString*)country withPhone:(NSString*)phone withpass:(NSString*)userpass;
- (BOOL)Logout:(int)cid;

- (void)saveProductCategory:(NSArray*)list;
- (NSArray*)getProductGategory;

- (void)saveProductList:(NSArray*)list withCategory:(NSString*)categoryName;
- (NSArray*)getProductList:(NSString*)categoryName;

- (void)saveOrder:(NSDictionary*)orderList;
- (NSArray*)getOrder;

- (BOOL)saveCart:(NSDictionary*)cartList;
- (NSArray*)getCart;

- (BOOL)deleteCart:(int)proId withOption:(int)optionId;
- (BOOL)deleteCartOfAll;
- (BOOL)updateCartQty:(int)qty withID:(int)proId withOption:(int)optionId;
@end
