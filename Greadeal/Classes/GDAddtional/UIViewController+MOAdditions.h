//
//  UIViewController+MOAdditions.h
//  Mozat
//
//  Created by zouxu on 6/6/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (MOAdditions)

-(UIViewController*)currentTopViewController;

- (id)previousViewControllerOnCurrentViewStack;

- (NSInteger)indexOfViewControllerClassOnCurrentStack:(Class)classObj;

- (BOOL)checkViewControllerisOnViewStack:(UIViewController *)viewController;

- (void)configureTitle:(NSString *)title;
- (void)configureTitle:(NSString *)title fitWidth:(BOOL)fit;

- (UIBarButtonItem*)configureBackBarButtonWithTitle:(NSString*)title;
- (UIBarButtonItem*)configureBackBarButton;

- (void)configureMenuButton;
- (void)configureImageInBar;
//-(void)configureLeftBarButtonItemToBackViewController:(SEL)action;
-(NSNumber*)back;
-(UIViewController*)previousViewControllerInStack;
- (void)disableScrollsToTopPropertyOnAllSubviewsOf:(UIView *)view;

- (void)addFBEvent:(NSString*)note;

@end
