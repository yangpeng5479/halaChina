//
//  FTLocationManager.h
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


#import <Foundation/Foundation.h>

@class CLLocation;

/**
 *  Error domain used for error created directly by FTLocationManager
 */
extern NSString *const FTLocationManagerErrorDomain;

/**
 *  FTLocationManagerErrorDomain custom error codes
 */
typedef NS_ENUM(NSInteger, FTLocationManagerErrorCode) {
    FTLocationManagerErrorCodeUnknown = 0,
    FTLocationManagerErrorCodeTimedOut
};

/**
 *  Typedef for completion handler block
 *
 *  @param location                 Received location or nil if there was an error
 *  @param error                    Error which occured while getting location or nil if everything went fine. Either the originating CLLocationManager error is passed or custom error with FTLocationManagerErrorDomain domain and FTLocationManagerErrorCode status code
 *  @param locationServicesDisabled YES if there was any error and it was because the Location Services are disabled for this. This is very often case to be checked so it is directly passed to the completion handler for .convenience
 */
typedef void (^FTLocationManagerCompletionHandler)(CLLocation *location,NSDictionary* userplace, NSError *error, BOOL locationServicesDisabled);


@interface FTLocationManager : NSObject

/**
 *  Location received from Location services
 */
@property (nonatomic, readonly) CLLocation   *bestEffortAtLocation;

@property (nonatomic, readonly) NSDictionary *userplace;

/**
 *  @return Shared singleton instance
 */
+ (FTLocationManager *)sharedManager;

/**
 *  Asks the manager get current location with the given completion handler block.
 *  Location is updated only once and the location listening is turned off again
 *  to preserve battery.
 *  If you dont provide completion block, STAsset macro will cause app crash because
 *  there is no logical use to update location without using it.
 *
 *  @param completionBlock Comletion block called on when the location is received.
 *  @see FTLocationManagerCompletionHandler
 */
- (void)updateLocationWithCompletionHandler:(FTLocationManagerCompletionHandler)completio;

@end
