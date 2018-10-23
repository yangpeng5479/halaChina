//
//  UIViewController+MOAdditions.m
//  Mozat
//
//  Created by zouxu on 6/6/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

//#import "MOTabBarController.h"
#import "UIViewController+MOAdditions.h"
//#import "WCNavigationController.h"

@implementation UIViewController (MOAdditions)


-(UIViewController*)currentTopViewControllerFromRoot:(UIViewController*)root
{
	UIViewController *top = root;
	if([root isKindOfClass:[UINavigationController class]])
	{
		top = [self currentTopViewControllerFromRoot:((UINavigationController*)root).topViewController];
	}
	else if([root isKindOfClass:[UITabBarController class]])
	{
		top = [self currentTopViewControllerFromRoot:((UITabBarController*)root).selectedViewController];
	}
	else if(root.presentedViewController)
	{
		top = [self currentTopViewControllerFromRoot:root.presentedViewController];
	}
	else
	{
		top = root;
	}
	return top;
}

-(UIViewController*)currentTopViewController
{

	UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
	//Recursively find out the actual top view controller.
	return [self currentTopViewControllerFromRoot:[window rootViewController]];
}


- (id)previousViewControllerOnCurrentViewStack
{
    NSArray *controllers = self.navigationController.viewControllers;
    
    for (int i = (int)[controllers count] - 1; i > 0; i--)
    {
        UIViewController *vc = [controllers objectAtIndex:i];
        if (vc != self)
        {
            continue;
        }
        if (i > 0)
        {
            return controllers[i - 1];
        }
        else
        {
            return nil;
        }
    }
    return nil;
}


- (NSInteger)indexOfViewControllerClassOnCurrentStack:(Class)classObj
{
    NSArray *controllers = self.navigationController.viewControllers;
    for (int i = 0; i < [controllers count]; i++)
    {
        UIViewController *vc = [controllers objectAtIndex:i];
        if ([vc isKindOfClass:classObj])
        {
            return i;
        }
    }
    return -1;
}

- (BOOL)checkViewControllerisOnViewStack:(UIViewController *)viewController
{
    NSArray *controllers = self.navigationController.viewControllers;
    for (int i = 0; i < [controllers count]; i++)
    {
        UIViewController *vc = [controllers objectAtIndex:i];
        if (vc == viewController)
        {
            return YES;
        }
    }
    return NO;
}

- (void)configureTitle:(NSString *)title
{
	[self configureTitle:title fitWidth:YES];
}


- (void)configureTitle:(NSString *)title fitWidth:(BOOL)fit
{
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = MOBlodFont(20);
        titleView.backgroundColor = [UIColor clearColor];
		
		titleView.textColor = [UIColor whiteColor];
		
        self.navigationItem.titleView = titleView;
    }
	titleView.adjustsFontSizeToFitWidth = fit;
    titleView.text = title;
    [titleView sizeToFit];
}

-(UIViewController*)previousViewControllerInStack
{
	// The current view controller is not embedded inside a navigation controller
    if (self.navigationController == nil)
    {
        return nil;
    }
	/**
	 * The root view controller is at index 0 in the array, the back view controller is at index n-2,
	 * and the top controller is at index n-1, where n is the number of items in the array.
	 */
    NSArray *viewControllers = self.navigationController.viewControllers;
    int n = (int)viewControllers.count;
    if (n >= 2)
    {
        UIViewController *backViewController = [viewControllers objectAtIndex:n - 2];
		return backViewController;
    }
	return nil;
}

- (UIBarButtonItem*)configureBackBarButton
{
	return [self configureBackBarButtonWithTitle:nil];
}

- (void)configureMenuButton
{
   // self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"drawer_icon.png"]  style:UIBarButtonItemStylePlain target:(WCNavigationController *)self.navigationController action:@selector(showMenu)];
    
//    UIImage* img=[UIImage imageNamed:@"drawer_icon.png"];
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    
//    btn.frame =CGRectMake(0, 0, 32, 32);
//    [btn setBackgroundImage:img forState:UIControlStateNormal];
//    [btn addTarget: (WCNavigationController *)self.navigationController action: @selector(showMenu) forControlEvents: UIControlEventTouchUpInside];
//    
//    UIBarButtonItem* item=[[UIBarButtonItem alloc]initWithCustomView:btn];
//    self.navigationItem.leftBarButtonItem=item;
}

- (void)configureImageInBar
{
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 98, 25)];//allocate titleView
    titleView.image  = [UIImage imageNamed:@"logoNav.png"];
    self.navigationItem.titleView = titleView;
}

-(UIBarButtonItem*)configureBackBarButtonWithTitle:(NSString *)title
{
	UIViewController *previousVC = [self previousViewControllerInStack];
    if (title.length<=0)
        title = previousVC.title;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle: title
                                                                      style:UIBarButtonItemStylePlain
                                                                      target:self
        action:@selector(back)];
	
	UIBarButtonItem *toRet = backButtonItem;
	
	if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
	{
//		if(previousVC)
//		{
////			previousVC.navigationItem.backBarButtonItem = backButtonItem;
//			//!!!Tricky!!! In iOS 7, the TITLE of the previous ViewController decides the title of the current view controller's Back button!!!
//			//And somehow when going back to previous view controller, its title will automatically change back to the original one.
//			if(!isEmptyString(title))
//				previousVC.navigationItem.title = title;
//		}

//		self.navigationItem.backBarButtonItem = backButtonItem;
		//Only change this when the title text is different. This is to avoid losing the user's tapping focus when the button has been changed right after the user has touched it but hasn't lifted finger yet.
		if(!self.navigationItem.leftBarButtonItem || ![backButtonItem.title isEqualToString:self.navigationItem.leftBarButtonItem.title])
		{
			self.navigationItem.leftBarButtonItem = backButtonItem;
		}
		else
		{
			toRet = self.navigationItem.leftBarButtonItem;
		}
		//self.navigationItem.backBarButtonItem.target = self;
		//self.navigationItem.backBarButtonItem.action = action;
	}
	//For iOS 6 and below.
	else
	{
        self.navigationItem.leftBarButtonItem = backButtonItem;
    }
	return toRet;
}

- (NSNumber*)back
{
    if (self.navigationController != nil
        && self.navigationController.viewControllers.count >= 2)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
	return [NSNumber numberWithBool:YES];
}


- (void) disableScrollsToTopPropertyOnAllSubviewsOf:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)subview).scrollsToTop = NO;
        }
        [self disableScrollsToTopPropertyOnAllSubviewsOf:subview];
    }
}

- (void)addFBEvent:(NSString*)note
{
    [FBSDKAppEvents logEvent:note];
}

@end
