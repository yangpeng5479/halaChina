//
//  GDWholeMapViewController.h
//  Greadeal
//
//  Created by Elsa on 16/1/19.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVAnnotation.h"
#import "SVPulsingAnnotationView.h"

@interface GDWholeMapViewController : UIViewController<MKMapViewDelegate>
{
    MKMapView *vmapView;
    float     vlatitude;
    float     vlongitude;
    NSString* vname;
}

- (id)init:(float)latitude withLong:(float)longitude withName:(NSString*)vendor_name;

@end
