//
//  FTLocationManager.m
//
//  Created by Lukas Kukacka on 7/31/13.
//  Copyright (c) 2013 Fuerte Int. All rights reserved.
//
//  Singleton manager for simple block-based asynchronous retrieving of actual users location
//
//
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Fuerte Int. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "FTLocationManager.h"

#import <CoreLocation/CoreLocation.h>

/*
newLocation.horizontalAccuracy > 65
poor

newLocation.horizontalAccuracy <= 65.0
Fair

newLocation.horizontalAccuracy <= 20.0
Good
 */

#define requirementAccuracy  70
#define requirementTimeOut   15

NSString *const FTLocationManagerErrorDomain = @"FTLocationManagerErrorDomain";

// CLLocationManager category for new iOS8 Location Request
@implementation CLLocationManager (Request)

- (void)iOS8LocationRequest
{
    SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
    if ([self respondsToSelector:requestSelector]) {
        ((void (*)(id, SEL))[self methodForSelector:requestSelector])(self, requestSelector);
    }
}

@end

//  Private interface encapsulating functionality
@interface FTLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) FTLocationManagerCompletionHandler completionBlock;

@end

@implementation FTLocationManager
{
}

#pragma mark Lifecycle

+ (FTLocationManager *)sharedManager
{
    static FTLocationManager *SharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[FTLocationManager alloc] init];
    });
    
    return SharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    //  Dealloc should not be called on singleton instance,
    //  but for sure
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark Private

- (CLLocationManager *)locationManager
{
    //  Location manager is lazily intialized when its really needed
    if(!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager iOS8LocationRequest];
        
        /*但是iOS的GPS位置信息精度仍然受到建筑物，山脉等障碍物的影响。如经过测试在我们公司的主楼6楼上，,用4G网络定位偏离到很远的位置（500米外），打开wifi,一般开启高德地图，获取的精度大约是65，在公司
        外面大门口（4g网络）的精度可以达到10米–20米。*/
        
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter  = kCLDistanceFilterNone;
        //启动位置更新
    }
    
    return _locationManager;
}

#pragma mark - Public interface

- (void)updateLocationWithCompletionHandler:(FTLocationManagerCompletionHandler)completion
{
    NSAssert(completion, @"You have to provide non-NULL completion handler to [FTLocationManager updateLocationWithCompletionHandler:]");
    
    [self performSelector:@selector(stopUpdating)
               withObject:nil
               afterDelay:requirementTimeOut];
   
    self.completionBlock = completion;
    
    _bestEffortAtLocation = nil;
    
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (NSString*)getFiled:(NSString*)gettype withCompnents:(NSArray*)address_components withName:(NSString*)filedName
{
    for (NSDictionary* dict in address_components)
    {
        LOG(@"JSON: %@", dict);
        NSArray* types = dict[@"types"];
        
        if (types.count>0)//get first type
        {
            NSString* _type = [types objectAtIndex:0];
            if ([_type compare:gettype options:NSCaseInsensitiveSearch]==NSOrderedSame)
            {
                NSString* getValue=@"";
                SET_IF_NOT_NULL(getValue, dict[filedName]);
                return getValue;
            }
        }
    }
    return @"";
}

#pragma mark - Google Map Api
- (void)getGeoCode
{
    //  Save user location
    NSDictionary* userLocation = @{@"longitude":@(_bestEffortAtLocation.coordinate.longitude),@"latitude":@(_bestEffortAtLocation.coordinate.latitude)};
    [[GDSettingManager instance] saveCityLocation:userLocation];
   
    if (_completionBlock)
    {
            
        NSString* url = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?latlng=%f,%f&language=en&sensor=false",_bestEffortAtLocation.coordinate.latitude,_bestEffortAtLocation.coordinate.longitude];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
        
        LOG(@"google map = %@",url);
        
        [manager GET:url
              parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            NSDictionary* place = nil;
                 
            NSMutableArray* areaArray = [NSMutableArray new];
                 
            NSString* country = @"";//types = (country,
            NSString* countryShort = @"";//types = (country,Short
            NSString* city    = @"";//types = (locality,
                                    //administrative_area_level_1 州
                                    //administrative_area_level_2 县
           
            NSString* area    = @"";//types = (neighborhood or sublocality_level_1
            
            NSString* address = @"";//types = (route,street_address);
            NSString* route_area    = @"";//types = (neighborhood or sublocality_level_1
            //LOG(@"JSON: %@", responseObject);
            NSArray *results = responseObject[@"results"];
                 
            
            for (NSDictionary* each in results)
            {
                NSString* component_type=@"";//address_components
                NSArray* address_components = each[@"address_components"];
                NSArray* types = each[@"types"];
                     
                if (types.count>0)//get first type
                {
                         component_type = [types objectAtIndex:0];
                         
                         if ([component_type compare:@"street_address" options:NSCaseInsensitiveSearch]==NSOrderedSame)
                         {
                             address = [self getFiled:@"route" withCompnents:address_components withName:@"short_name"];
                             
                             address = [self getFiled:@"premise" withCompnents:address_components withName:@"short_name"];
                         }
                         else if ([component_type compare:@"premise" options:NSCaseInsensitiveSearch]==NSOrderedSame)
                         {
                             address = [self getFiled:component_type withCompnents:address_components withName:@"short_name"];
                             
                             route_area = [self getFiled:@"neighborhood" withCompnents:address_components withName:@"long_name"];
                             
                             if (route_area.length<=0)
                             {
                                 route_area = [self getFiled:@"sublocality_level_1" withCompnents:address_components withName:@"long_name"];
                             }
                         }
                         else if ([component_type compare:@"route" options:NSCaseInsensitiveSearch]==NSOrderedSame && address.length<=0)
                         {
                             address = [self getFiled:component_type withCompnents:address_components withName:@"short_name"];
                             
                             route_area = [self getFiled:@"neighborhood" withCompnents:address_components withName:@"long_name"];
                             
                             if (route_area.length<=0)
                             {
                                 route_area = [self getFiled:@"sublocality_level_1" withCompnents:address_components withName:@"long_name"];
                             }
                         }
                         else if  ([component_type compare:@"sublocality_level_1" options:NSCaseInsensitiveSearch]==NSOrderedSame)
                         {
                             area = [self getFiled:component_type withCompnents:address_components withName:@"long_name"];
                             
                             [areaArray addObject:area];

                         }
                         else if  ([component_type compare:@"neighborhood" options:NSCaseInsensitiveSearch]==NSOrderedSame)
                         {
                             area = [self getFiled:component_type withCompnents:address_components withName:@"long_name"];
                             
                             [areaArray addObject:area];
                         }
                         else if  ([component_type compare:@"locality" options:NSCaseInsensitiveSearch]==NSOrderedSame)  //有音标
                         {
                             city = [self getFiled:component_type withCompnents:address_components withName:@"short_name"];
                         }
                         else if  (city.length<=0 && [component_type compare:@"administrative_area_level_1" options:NSCaseInsensitiveSearch]==NSOrderedSame)
                         {
                             city = [self getFiled:component_type withCompnents:address_components withName:@"long_name"];
                         }
                         else if  (city.length<=0 && [component_type compare:@"administrative_area_level_2" options:NSCaseInsensitiveSearch]==NSOrderedSame)
                         {
                             city = [self getFiled:component_type withCompnents:address_components withName:@"long_name"];
                         }
                         else if  ([component_type compare:@"country" options:NSCaseInsensitiveSearch]==NSOrderedSame)
                         {
                             country = [self getFiled:component_type withCompnents:address_components withName:@"long_name"];
                             
                             countryShort = [self getFiled:component_type withCompnents:address_components withName:@"short_name"];
                         }
                     }
                 }
                 
                 if (areaArray.count<=0)
                 {
                     [areaArray addObject:route_area];
                 }
            
                 //place = @{@"city":city,@"area":areaArray,@"address":address,@"country":country};
                 //naver return area
            place = @{@"city":city,@"address":address,@"country":country,@"countryshort":countryShort};
            
                 if (self.completionBlock!=nil)
                 {
                     _completionBlock(_bestEffortAtLocation,place,nil, NO);
                     self.completionBlock = nil;
                 }
                 
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 if (self.completionBlock!=nil)
                 {
                     _completionBlock(_bestEffortAtLocation,nil,nil, NO);
                     self.completionBlock = nil;
                 }
             }];
        }
    
}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    LOG(@"%@",newLocation);
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    //
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 30.0) {
        return;
    }
   
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
  
    // test the measurement to see if it is more accurate than the previous measurement
    if (_bestEffortAtLocation == nil || _bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        // store the location as the "best effort"
        _bestEffortAtLocation = newLocation;
     
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        if (newLocation.horizontalAccuracy <= requirementAccuracy )//self.locationManager.desiredAccuracy)
        {
            // we have a measurement that meets our requirements, so we can stop updating the location
            
            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
            [self stopPreviousTimeOut];
            
            // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
            [self stopUpdating];
           
        }
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    _bestEffortAtLocation = nil;
    
    [self stopUpdating];
    
    if(error.domain == kCLErrorDomain && error.code == kCLErrorDenied)
    {
        [self locationUpdatingFailedWithError:error locationServicesDisabled:YES];
    }
 
    LOG(@"locationManager didFailWithError");
}

#pragma mark - Private helper methods

- (void)locationUpdatingFailedWithError:(NSError *)error locationServicesDisabled:(BOOL)locationServicesDisabled
{
    
    NSString* outputText;
    if(locationServicesDisabled)
    {
            outputText = [NSString stringWithFormat:NSLocalizedString(@"Location Service is disabled. \nPlease go to 'Settings > Privacy > Location Services' \nto grant the access right.",@"定位服务被关闭, 请到 设置->隐私->定位服务 打开使用权限")];
    }
    else
    {
        outputText = [NSString stringWithFormat:NSLocalizedString(@"Failed to get address information: %@",@"获取地址信息失败 %@"), error];
    }
        
    [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:outputText
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
     }];
   
}

- (void)stopPreviousTimeOut
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdating) object:nil];
}

- (void)stopUpdating
{
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    
    if (_bestEffortAtLocation != nil)
    {
        //for demo
//        CLLocation *LocationAtual = [[CLLocation alloc] initWithLatitude:25.167538 longitude:55.409226];
//        
//        _bestEffortAtLocation = LocationAtual;
        
        [self getGeoCode];
    }
    else
    {
        //  Cancel previous error timeouts
        [self stopPreviousTimeOut];
        
        //  Report error with block
        if (_completionBlock) {
            _completionBlock(nil, nil, nil, YES);
        }
    }
}

@end
