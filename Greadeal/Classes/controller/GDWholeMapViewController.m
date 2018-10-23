//
//  GDWholeMapViewController.m
//  Greadeal
//
//  Created by Elsa on 16/1/19.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDWholeMapViewController.h"
#import "RDVTabBarController.h"

@interface GDWholeMapViewController ()

@end

@implementation GDWholeMapViewController

- (id)init:(float)latitude withLong:(float)longitude withName:(NSString*)vendor_name
{
    self = [super init];
    if (self)
    {
        vlatitude  = latitude;
        vlongitude = longitude;
        vname      = vendor_name;
        
        self.title = NSLocalizedString(@"Vendor Location",@"商家位置");
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)dirctionMap:(UIGestureRecognizer*)gestureRecognizer
{
    CLLocationCoordinate2D endCoor = CLLocationCoordinate2DMake(vlatitude,vlongitude);
    
    [[GDPublicManager instance] mapDiredection:endCoor withEnd:endCoor withToName:vname withView:self.view];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.view.bounds
    vmapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    vmapView.delegate = self;
    [self.view addSubview:vmapView];
    
    if ([[GDPublicManager instance] showDiredection])
    {
    UIImageView* dirctionImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-100, self.view.bounds.size.height-170, 89, 69)];
    dirctionImage.image = [UIImage imageNamed:@"dirctions.png"];
    [vmapView addSubview:dirctionImage];
    dirctionImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dirctionMap:)];
    [dirctionImage addGestureRecognizer:singleTap1];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, 89, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"Directions", @"导航");
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.font = MOLightFont(14);
    [dirctionImage addSubview:label];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(vlatitude,  vlongitude);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.05, 0.05));
    [vmapView setRegion:region animated:NO];
    
    SVAnnotation *annotation = [[SVAnnotation alloc] initWithCoordinate:coordinate];
    annotation.title = NSLocalizedString(@"Vendor Location",@"商家位置");
    [vmapView addAnnotation:annotation];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation isKindOfClass:[SVAnnotation class]]) {
        NSString *identifier = NSLocalizedString(@"Vendor Location",@"商家位置");
        SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[vmapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if(pulsingView == nil) {
            pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            pulsingView.annotationColor = MOColorSaleFontColor();
            pulsingView.canShowCallout = YES;
        }
        
        return pulsingView;
    }
    
    return nil;
}

@end
