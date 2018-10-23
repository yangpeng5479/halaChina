//
//  WCDatabaseManager.m
//  WristCentralPos
//
//  Created by tao tao on 20/8/14.
//  Copyright (c) 2014 tao tao. All rights reserved.
//

#import "WCDatabaseManager.h"


#define kDBFileNameQ                  @"DB_WC_CACHE"

/// This table is used to store the quality statistics data.
#define kTableNameUser                 @"Table_User"
#define kTableNameCategory             @"Table_Category"
#define kTableNameProduct              @"Table_Product"
#define kTableNameOrder                @"Table_Order"

#define kTableNameCart                 @"Table_Cart"

// Table column name
#define kTableNameUser_useremail    @"useremail"
#define kTableNameUser_usercountry    @"userphonecountry"
#define kTableNameUser_userphone    @"userphone"
#define kTableNameUser_userpass     @"userpass"
#define kTableNameUser_loginstatus  @"loginsatus"
#define kTableNameUser_userid       @"userid"

#define kTableCategory_name            @"name"
#define kTableCategory_parent           @"parent" //int
#define kTableCategory_slug            @"slug"
#define kTableCategory_termid            @"term_id" //int

#define kTableProductID       @"ID"  //use
#define kTableProductCategoryName  @"Categoryname" //use
#define kTableProductIDcommentcount @"commentcount"
#define kTableProductIDcomment_status  @"commentstatus"
#define kTableProductIDcurrency  @"currency"  //use
#define kTableProductIDfilter @"filter"
#define kTableProductIDguid @"guid"
#define kTableProductIDimg @"img"  //use
#define kTableProductIDvariation_id @"variation_id"
#define kTableProductIDimg_full   @"img_full"
#define kTableProductIDmenu_order  @"menu_order"
#define kTableProductIDping_status  @"ping_status"
#define kTableProductIDpinged  @"pinged"
#define kTableProductIDpostauthor   @"post_author"
#define kTableProductIDpostcontent   @"post_content"
#define kTableProductIDpostcontent_filtered  @"post_content_filtered"
#define kTableProductIDpostdate  @"post_date"
#define kTableProductIDpostdate_gmt  @"post_date_gmt"
#define kTableProductIDpostexcerpt  @"post_excerpt"
#define kTableProductIDpostmime_type  @"post_mime_type"
#define kTableProductIDpostmodified  @"post_modified"
#define kTableProductIDpostmodified_gmt  @"post_modified_gmt"
#define kTableProductIDpostname  @"post_name" //use
#define kTableProductIDpostparent  @"post_parent"
#define kTableProductIDpostpassword  @"post_password"
#define kTableProductIDpoststatus  @"post_status"
#define kTableProductIDposttitle  @"post_title"
#define kTableProductIDposttype  @"post_type"
#define kTableProductIDprice  @"price" //use
#define kTableProductIDstock  @"stock" //use
#define kTableProductIDtoping  @"to_ping"
#define kTableProductIDregularprice @"regular_price" //use
#define kTableProductIDsku @"sku" //use

#define kTableNameOrderID  @"orderID"
#define kTableNameOrderproductlist @"productlist"
#define kTableNameOrderaddress  @"address"
#define kTableNameOrdername  @"name"
#define kTableNameOrderphone  @"phone"
#define kTableNameOrdertax  @"tax"
#define kTableNameOrderpaymenttype  @"paymenttype"
#define kTableNameOrdertotalPrice  @"totalPrice"
#define kTableNameOrderID  @"orderID"
#define kTableNameOrderproductlist @"productlist"
#define kTableNameOrderaddress  @"address"
#define kTableNameOrdername  @"name"
#define kTableNameOrderphone  @"phone"
#define kTableNameOrdertax  @"tax"
#define kTableNameOrderpaymenttype  @"paymenttype"
#define kTableNameOrdertotalPrice  @"totalPrice"
#define kTableNameOrderDate  @"orderdate"

#define kTableNameMpnId       @"vendor_id"
#define kTableNameMpnName     @"vendor_name"
#define kTableNameProId       @"proid"
#define kTableNameOptionId       @"optionid"
#define kTableNameCartProduct @"product"
#define kTableNameCartUserID  @"userid"
#define kTableNameCartQty     @"qty"
#define kTableNameCartPrice   @"price"

@implementation WCDatabaseManager

+ (WCDatabaseManager *)instance
{
    static WCDatabaseManager *_sharedObject = nil;
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedObject = [[WCDatabaseManager alloc] init];
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self openDB];
        [self createTable];

    }
    return self;
}

- (void)openDB
{
    NSString *dbPath = [self dbFilePath];
    LOG(@"%@",dbPath);
    
    NSAssert(dbPath, @"dbPath should not be nil");
    @synchronized(self)
    {
        if (dbPath)
        {
			// If the database has already been open, do nothing.
            if (_queue == nil)
            {
                _queue = [[FMDatabaseQueue alloc] initWithPath:dbPath];
            }
        }
        else
        {
            _queue = nil;
        }
    }
}

- (NSString *)dbFilePath
{
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *result = [documentDir stringByAppendingPathComponent:kDBFileNameQ];
    return result;
}

- (void)createTable
{
    @synchronized(self)
    {
         [_queue inDatabase:^(FMDatabase *db) {
             NSString *createTableUser =
            [NSString stringWithFormat:
             @"CREATE TABLE IF NOT EXISTS %@ "
             "(%@ INTEGER PRIMARY KEY NOT NULL, "
             "%@ TEXT, "
             "%@ TEXT, "
             "%@ TEXT, "
             "%@ TEXT, "
             "%@ INTEGER"
             ");",
             kTableNameUser,
             kTableNameUser_userid,
             kTableNameUser_useremail,
             kTableNameUser_usercountry,
             kTableNameUser_userphone,
             kTableNameUser_userpass,
             kTableNameUser_loginstatus];
            
            BOOL success = [db executeUpdate:createTableUser];
            if (success)
            {
               
            }
            else
            {
                NSAssert(0, @"Error creating table");
            }
             
             NSString *createTableCart =
             [NSString stringWithFormat:
              @"CREATE TABLE IF NOT EXISTS %@ "
              "(%@ INTEGER NOT NULL , "
              "%@ INTEGER NOT NULL , "
              "%@ BLOB NOT NULL, "
              "%@ INTEGER NOT NULL,"
              "%@ FLOAT NOT NULL,"
               "%@ INTEGER NOT NULL,"
              "%@ INTEGER NOT NULL,"
               "%@ TEXT"
              ");",
              kTableNameCart,
              kTableNameProId,
              kTableNameOptionId,
              kTableNameCartProduct,
              kTableNameCartQty,
              kTableNameCartPrice,
              kTableNameCartUserID,
              kTableNameMpnId,
              kTableNameMpnName
              ];
             
             success = [db executeUpdate:createTableCart];
             if (success)
             {
                 
             }
             else
             {
                 NSAssert(0, @"Error creating table");
             }
             
             
             NSString *createTableCategory =
             [NSString stringWithFormat:
              @"CREATE TABLE IF NOT EXISTS %@ "
              "(%@ TEXT  NOT NULL, "
              "%@ INTEGER NOT NULL,"
              "%@ TEXT NOT NULL, "
              "%@ INTEGER NOT NULL"
              ");",
              kTableNameCategory,
              kTableCategory_name,
              kTableCategory_parent,
              kTableCategory_slug,
              kTableCategory_termid
              ];
             
             success = [db executeUpdate:createTableCategory];
             if (success)
             {
                 
             }
             else
             {
                 NSAssert(0, @"Error creating table");
             }

             NSString *createTableProduct=
             [NSString stringWithFormat:
              @"CREATE TABLE IF NOT EXISTS %@ "
              //"(%@ INTEGER  PRIMARY KEY NOT NULL, "
              "(%@ INTEGER  NOT NULL, "
              "%@ TEXT NOT NULL, "
              "%@ TEXT NOT NULL, "
              "%@ TEXT NOT NULL, "
              "%@ TEXT NOT NULL, "
              "%@ TEXT NOT NULL, "
              "%@ INTEGER NOT NULL,"
              "%@ TEXT,"
              "%@ TEXT,"
              "%@ INTEGER NOT NULL"
              ");",
              kTableNameProduct,
              kTableProductID,
              kTableProductCategoryName,
              kTableProductIDcurrency,
              kTableProductIDimg,
              kTableProductIDpostname,
              kTableProductIDprice,
              kTableProductIDstock,
              kTableProductIDregularprice,
              kTableProductIDsku,
              kTableProductIDvariation_id
              ];
             
             success = [db executeUpdate:createTableProduct];
             if (success)
             {
                 
             }
             else
             {
                 NSAssert(0, @"Error creating table");
             }
             
             NSString *createTableOrder=
             [NSString stringWithFormat:
              @"CREATE TABLE IF NOT EXISTS %@ "
              //"(%@ TEXT PRIMARY KEY NOT NULL, "
              "(%@ TEXT, "
              "%@ TEXT NOT NULL, "
              "%@ TEXT NOT NULL, "
              "%@ TEXT NOT NULL, "
              "%@ TEXT NOT NULL, "
              "%@ TEXT NOT NULL, "
              "%@ TEXT NOT NULL,"
              "%@ TEXT NOT NULL,"
              "%@ datetime default (datetime('now'))"
              ");",
              kTableNameOrder,
              kTableNameOrderID,
              kTableNameOrderproductlist,
              kTableNameOrderaddress,
              kTableNameOrdername,
              kTableNameOrderphone,
              kTableNameOrdertax,
              kTableNameOrderpaymenttype,
              kTableNameOrdertotalPrice,
              kTableNameOrderDate
              ];
             
             success = [db executeUpdate:createTableOrder];
             if (success)
             {
                 
             }
             else
             {
                 NSAssert(0, @"Error creating table");
             }

        }];
     }
    
}

- (NSMutableDictionary*)getUserInfo
{
    __block NSMutableDictionary *userdata = [[NSMutableDictionary alloc] init];
    
    [_queue inDatabase:^(FMDatabase *db)
    {
        FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"SELECT %@,%@,%@,%@,%@ FROM '%@'",
                                       kTableNameUser_useremail,kTableNameUser_usercountry, kTableNameUser_userphone,kTableNameUser_userpass,kTableNameUser_loginstatus, kTableNameUser]];
        //get last one
        NSString* useremail=@"";
        NSString* phoneCountry=@"";
        NSString* userphone=@"";
        NSString* userpass=@"";
        int       loginstatus = 0;
        if ([s next])
        {
            useremail = [s stringForColumnIndex:0];
            phoneCountry= [s stringForColumnIndex:1];
            userphone = [s stringForColumnIndex:2];
            userpass = [s stringForColumnIndex:3];
            loginstatus = [s intForColumnIndex:4];
        }
        [s close];
        
        [userdata setObject:useremail forKey:@"useremail"];
        [userdata setObject:phoneCountry==nil?@"":phoneCountry forKey:@"phonecountry"];
        [userdata setObject:userphone==nil?@"":userphone forKey:@"userphone"];
        [userdata setObject:userpass forKey:@"userpass"];
        [userdata setObject:[NSNumber numberWithInt:loginstatus] forKey:@"loginstatus"];
        
    }];
   return userdata;
}

- (BOOL)Login:(NSString*)email withid:(int)cid withCountry:(NSString*)country withPhone:(NSString*)phone withpass:(NSString*)userpass
{
    //write user data to database
    [_queue inDatabase:^(FMDatabase *db)
     {
         //first delte all of records
//         NSString *updateStr = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE %@=%d",
//                                kTableNameUser,kTableNameUser_userid,cid];
         NSString *updateStr = [NSString stringWithFormat:@"DELETE FROM '%@'",
                                kTableNameUser];
         [db executeUpdate:updateStr];
       
         updateStr = [NSString stringWithFormat:@"INSERT INTO '%@'('%@', '%@','%@', '%@', '%@','%@')VALUES(?,?,?,?,?,?)",
                    kTableNameUser, kTableNameUser_useremail, kTableNameUser_usercountry,kTableNameUser_userphone,kTableNameUser_userpass,kTableNameUser_userid,kTableNameUser_loginstatus];
         BOOL success = [db executeUpdate:updateStr, email,country,phone,userpass,@(cid),@(1)];
         NSAssert(success, @"failed to update table");
         
     }];
    return YES;
}

-(BOOL)Logout:(int)cid
{
    [_queue inDatabase:^(FMDatabase *db)
     {
         NSString *updateStr = [NSString stringWithFormat:@"UPDATE %@ SET %@=? , %@=? WHERE %@=?",
                                kTableNameUser, kTableNameUser_loginstatus,kTableNameUser_userpass, kTableNameUser_userid];
         BOOL success = [db executeUpdate:updateStr, @(0), @"",@(cid)];
         NSAssert(success, @"failed to update table");

     }];
    return YES;
}

- (void)saveProductCategory:(NSArray*)list
{
    [_queue inDatabase:^(FMDatabase *db)
    {
        //first delte all of records
        NSString *updateStr = [NSString stringWithFormat:@"DELETE FROM '%@'",
                                    kTableNameCategory];
        [db executeUpdate:updateStr];

        for (NSDictionary*obj in list)
        {
            updateStr = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@', '%@','%@')VALUES(?,?,?,?)",
                     kTableNameCategory, kTableCategory_name, kTableCategory_parent,kTableCategory_slug,kTableCategory_termid];
             
            NSString* name = obj[@"name"];
            NSString* slug = obj[@"slug"];
            int parent = [obj[@"parent"] intValue];
            int term_id = [obj[@"term_id"] intValue];
             
            BOOL success = [db executeUpdate:updateStr, name, @(parent),slug, @(term_id)];
            NSAssert(success, @"failed to update table");
        }
    }];
}

- (NSArray*)getProductGategory
{
    __block NSMutableArray *categorydata = [[NSMutableArray alloc] init];
    
    [_queue inDatabase:^(FMDatabase *db)
     {
         NSString* queryStr = [NSString stringWithFormat:@"SELECT %@,%@,%@,%@ FROM '%@'",
                               kTableCategory_name, kTableCategory_parent,kTableCategory_slug,kTableCategory_termid,kTableNameCategory];
         
         FMResultSet *s = [db executeQuery:queryStr];
       
         while ([s next])
         {
             NSDictionary *dict = [s resultDictionary];
             [categorydata addObject:dict];
         }
         [s close];
         
    }];
    return categorydata;
}

- (void)saveProductList:(NSArray*)list withCategory:(NSString*)categoryName
{
    [_queue inDatabase:^(FMDatabase *db)
     {
         //first delte all of records
         NSString *updateStr = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE %@='%@'",
                                kTableNameProduct,kTableProductCategoryName,categoryName];
         [db executeUpdate:updateStr];
         
         for (NSDictionary*obj in list)
         {
             updateStr = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@') VALUES (?,?,?,?,?,?,?,?,?,?)",
                          kTableNameProduct, kTableProductID, kTableProductCategoryName,kTableProductIDcurrency,kTableProductIDimg,kTableProductIDpostname,kTableProductIDprice,kTableProductIDstock,kTableProductIDregularprice,kTableProductIDsku,kTableProductIDvariation_id];
             
             int ID = [obj[@"ID"] intValue];
             NSString* currency = obj[@"currency"];
             NSString* img = obj[@"img"];
             NSString* post_name = obj[@"post_name"];
             NSString* price = obj[@"price"];
             int stock = [obj[@"stock"] intValue];
             NSString* regularprice = obj[@"regular_price"];
             NSString* sku = obj[@"sku"];
             int   variation_id =  [obj[@"variation_id"] intValue];
      
             if ([regularprice isKindOfClass:[NSNull class]])
             {
                 regularprice = @"";
             }
             
             //NSLog(@"---%d %@",ID,categoryName);
             BOOL success = [db executeUpdate:updateStr,@(ID),categoryName,currency,img,post_name,price, @(stock),regularprice,sku,@(variation_id)];
             NSAssert(success, @"failed to update table");
         }
     }];

}

- (NSArray*)getProductList:(NSString*)categoryName
{
    __block NSMutableArray *productdata = [[NSMutableArray alloc] init];
    
    [_queue inDatabase:^(FMDatabase *db)
     {
         FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"SELECT %@,%@,%@,%@,%@,%@,%@,%@,%@ FROM '%@'  WHERE %@='%@' ",kTableProductID, kTableProductCategoryName,kTableProductIDcurrency,kTableProductIDimg,kTableProductIDpostname,kTableProductIDprice,kTableProductIDstock,kTableProductIDregularprice,kTableProductIDsku,kTableNameProduct,kTableProductCategoryName,categoryName]];
         
         while ([s next])
         {
             NSDictionary *dict = [s resultDictionary];
             [productdata addObject:dict];
         }
         [s close];
         
     }];
    return productdata;
}

- (void)saveOrder:(NSDictionary*)orderList
{
    [_queue inDatabase:^(FMDatabase *db)
     {
        NSString *updateStr = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@','%@','%@','%@','%@') VALUES (?,?,?,?,?,?,?,?)",
                               kTableNameOrder,
                               kTableNameOrderID,
                               kTableNameOrderproductlist,
                               kTableNameOrderaddress,
                               kTableNameOrdername,
                               kTableNameOrderphone,
                               kTableNameOrdertax,
                               kTableNameOrderpaymenttype,
                               kTableNameOrdertotalPrice];
             
        int ID = [orderList[@"orderID"] intValue];
        NSString* productlist = orderList[@"productlist"];
        NSString* address = orderList[@"address"];
        NSString* name = orderList[@"name"];
        NSString* phone = orderList[@"phone"];
        NSString* tax = orderList[@"tax"];
        NSString* paymenttype = orderList[@"paymenttype"];
        NSString* totalPrice = orderList[@"totalPrice"];
         
        BOOL success = [db executeUpdate:updateStr,@(ID),productlist,address,name,phone,tax, paymenttype,totalPrice];
        NSAssert(success, @"failed to update table");
         
     }];

}

- (NSArray*)getOrder
{
    __block NSMutableArray *orderdata = [[NSMutableArray alloc] init];
    
    [_queue inDatabase:^(FMDatabase *db)
     {
          NSString* str = [NSString stringWithFormat:@"SELECT %@,%@,%@,%@,%@,%@,%@,%@,%@ FROM '%@'",
          
          kTableNameOrderID,
          kTableNameOrderproductlist,
          kTableNameOrderaddress,
          kTableNameOrdername,
          kTableNameOrderphone,
          kTableNameOrdertax,
          kTableNameOrderpaymenttype,
          kTableNameOrdertotalPrice,
          kTableNameOrderDate,
          kTableNameOrder];
         
         FMResultSet *s = [db executeQuery:str];
         
         while ([s next])
         {
             NSDictionary *dict = [s resultDictionary];
             [orderdata addObject:dict];
             
         }
         [s close];
         
     }];
    return orderdata;
}

- (BOOL)saveCart:(NSDictionary*)cartList
{
    __block BOOL success;
    [_queue inDatabase:^(FMDatabase *db)
     {
         NSString *updateStr = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@','%@','%@','%@','%@') VALUES (?,?,?,?,?,?,?,?)",
                                kTableNameCart,
                                kTableNameProId,
                                kTableNameOptionId,
                                kTableNameCartProduct,
                                kTableNameCartQty,
                                kTableNameCartPrice,
                                kTableNameCartUserID,
                                kTableNameMpnId,
                                kTableNameMpnName];
         
         NSDictionary* productlist = cartList[@"product"];
         int qty = [cartList[@"qty"] intValue];
         float price = [cartList[@"price"] floatValue];
         int userid = [cartList[@"userid"] intValue];
         
         int vendor_id = [cartList[@"vendor_id"] intValue];
         int proid = [cartList[@"proid"] intValue];
         int optionid = [cartList[@"optionid"] intValue];
         NSString* vendor_name = cartList[@"vendor_name"];
         
         success = [db executeUpdate:updateStr,@(proid),@(optionid),productlist,@(qty),@(price),@(userid),@(vendor_id),vendor_name];
         NSAssert(success, @"failed to update table");
         
     }];
    return success;
}

- (NSArray*)getCart
{
    int cid = [GDPublicManager instance].cid;
    
    __block NSMutableArray *cartdata = [[NSMutableArray alloc] init];
    
    [_queue inDatabase:^(FMDatabase *db)
     {
         NSString* str = [NSString stringWithFormat:@"SELECT %@,%@,%@,%@,%@,%@,%@,%@ FROM '%@' WHERE %@=%d",
                          kTableNameProId,
                          kTableNameCartProduct,
                          kTableNameCartQty,
                          kTableNameCartPrice,
                          kTableNameCartUserID,
                          kTableNameOptionId,
                          kTableNameMpnId,
                          kTableNameMpnName,
                          kTableNameCart,
                          kTableNameCartUserID,
                          cid];
         
         FMResultSet *s = [db executeQuery:str];
         
         while ([s next])
         {
             NSDictionary *dict = [s resultDictionary];
             [cartdata addObject:dict];
             
         }
         [s close];
         
     }];
    return cartdata;
}

- (BOOL)deleteCart:(int)proId withOption:(int)optionId
{
    __block BOOL execResult = NO;
    [_queue inDatabase:^(FMDatabase *db)
     {
         NSString *updateStr = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE %@=%d AND %@=%d",
                           kTableNameCart,kTableNameProId,proId,kTableNameOptionId,optionId];
          execResult = [db executeUpdate:updateStr];
          }];
    return execResult;
}

- (BOOL)deleteCartOfAll
{
    __block BOOL execResult = NO;
    [_queue inDatabase:^(FMDatabase *db)
     {
         NSString *updateStr = [NSString stringWithFormat:@"DELETE FROM '%@'",
                                kTableNameCart];
         execResult = [db executeUpdate:updateStr];
     }];
    return execResult;

}

- (BOOL)updateCartQty:(int)qty withID:(int)proId  withOption:(int)optionId;
{
    __block BOOL execResult = NO;
    [_queue inDatabase:^(FMDatabase *db)
     {
         NSString *updateStr = [NSString stringWithFormat:@"UPDATE %@ SET %@=? WHERE %@=? AND %@=?",
                                kTableNameCart, kTableNameCartQty, kTableNameProId,kTableNameOptionId];
         BOOL success = [db executeUpdate: updateStr,@(qty), @(proId), @(optionId)];
         NSAssert(success, @"failed to update table");
     }];
    return execResult;
}

@end
