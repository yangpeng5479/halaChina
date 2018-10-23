//
//  GDIntroViewController.m
//  Greadeal
//
//  Created by Elsa on 15/5/19.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDIntroViewController.h"

@interface GDIntroViewController ()

@end

@implementation GDIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 - (void)viewDidAppear:(BOOL)animated
{
     [super viewDidAppear:animated];
     // all settings are basic, pages with custom packgrounds, title image on each page
     [self showIntroWithCrossDissolve];
     // all settings are basic, introview with custom background, title image on each page
     //[self showBasicIntroWithBg];
     
     // all settings are basic, introview with custom background color and fixed title image
     //[self showBasicIntroWithFixedTitleView];
     
     // all settings are custom
     //[self showCustomIntro];
     
     // using customView property of EAIntroPage
     //[self showIntroWithCustomView];
     
     // separate pages initialization
     //[self showIntroWithSeparatePagesInit]
 
 }
 
 - (void)showIntroWithCrossDissolve
{
    EAIntroPage *page1 = [EAIntroPage page:colorFromHexString(@"e81748") withFont:NO];
   // page1.title = NSLocalizedString(@"Coupons in UAE",@"各种优惠");
    //page1.desc = NSLocalizedString(@"Indispensible money saver for your lifestyle",@"阿联酋吃喝玩乐必备神器");
    page1.bgImage = [UIImage imageNamed:@"1.png"];
    //page1.titleImage = [UIImage imageNamed:@"original"];
 
    EAIntroPage *page2 = [EAIntroPage page:colorFromHexString(@"744734") withFont:NO];
   // page2.title = NSLocalizedString(@"Order by mobile",@"手机买单");
    //page2.desc = NSLocalizedString(@"Enjoy coupons anytime, anywhere",@"不论何时，不论何地");
    page2.bgImage = [UIImage imageNamed:@"2.png"];
   // page2.titleImage = [UIImage imageNamed:@"supportcat"];
 
    EAIntroPage *page3 = [EAIntroPage page:colorFromHexString(@"1483d7") withFont:NO];
    //page3.title = NSLocalizedString(@"Secured payment",@"安全支付");
    //page3.desc = NSLocalizedString(@"Easy, fast, and assured",@"便捷又放心");
    page3.bgImage = [UIImage imageNamed:@"3.png"];
    //page3.titleImage = [UIImage imageNamed:@"femalecodertocat"];
 
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
 
    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0.0];
 }
 
// - (void)showBasicIntroWithBg
//{
//    EAIntroPage *page1 = [EAIntroPage page];
//    page1.title = @"Hello world";
//    page1.desc = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
//    page1.titleImage = [UIImage imageNamed:@"original"];
// 
//    EAIntroPage *page2 = [EAIntroPage page];
//    page2.title = @"This is page 2";
//    page2.desc = @"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.";
//    page2.titleImage = [UIImage imageNamed:@"supportcat"];
// 
//    EAIntroPage *page3 = [EAIntroPage page];
//    page3.title = @"This is page 3";
//    page3.desc = @"Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.";
//    page3.titleImage = [UIImage imageNamed:@"femalecodertocat"];
// 
//    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
//    intro.bgImage = [UIImage imageNamed:@"introBg"];
// 
//    [intro setDelegate:self];
//    [intro showInView:self.view animateDuration:0.0];
// }
// 
// - (void)showBasicIntroWithFixedTitleView
//{
//    EAIntroPage *page1 = [EAIntroPage page];
//    page1.title = @"Hello world";
//    page1.desc = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
// 
//    EAIntroPage *page2 = [EAIntroPage page];
//    page2.title = @"This is page 2";
//    page2.desc = @"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.";
// 
//    EAIntroPage *page3 = [EAIntroPage page];
//    page3.title = @"This is page 3";
//    page3.desc = @"Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.";
// 
//    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
//    UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"original"]];
//    intro.titleView = titleView;
//    intro.backgroundColor = [UIColor colorWithRed:0.0f green:0.49f blue:0.96f alpha:1.0f]; //iOS7 dark blue
// 
//    [intro setDelegate:self];
//    [intro showInView:self.view animateDuration:0.0];
// }
// 
// - (void)showCustomIntro
//{
//    EAIntroPage *page1 = [EAIntroPage page];
//    page1.title = @"Hello world";
//    page1.desc = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
//    page1.titleImage = [UIImage imageNamed:@"original"];
// 
//    EAIntroPage *page2 = [EAIntroPage page];
//    page2.title = @"This is page 2";
//    page2.titlePositionY = 180;
//    page2.desc = @"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.";
//    page2.descPositionY = 160;
//    page2.titleImage = [UIImage imageNamed:@"supportcat"];
//    page2.imgPositionY = 70;
// 
//    EAIntroPage *page3 = [EAIntroPage page];
//    page3.title = @"This is page 3";
//    page3.titleFont = [UIFont fontWithName:@"Georgia-BoldItalic" size:20];
//    page3.titlePositionY = 220;
//    page3.desc = @"Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit.";
//    page3.descFont = [UIFont fontWithName:@"Georgia-Italic" size:18];
//    page3.descPositionY = 200;
//    page3.titleImage = [UIImage imageNamed:@"femalecodertocat"];
//    page3.imgPositionY = 100;
// 
//    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
//    intro.backgroundColor = [UIColor colorWithRed:1.0f green:0.58f blue:0.21f alpha:1.0f]; //iOS7 orange
// 
//    intro.pageControlY = 100.0f;
// 
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [btn setBackgroundImage:[UIImage imageNamed:@"skipButton"] forState:UIControlStateNormal];
//    [btn setFrame:CGRectMake((320-230)/2, [UIScreen mainScreen].bounds.size.height - 60, 230, 40)];
//    [btn setTitle:@"SKIP NOW" forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    intro.skipButton = btn;
// 
//    [intro setDelegate:self];
//    [intro showInView:self.view animateDuration:0.0];
// }
// 
// - (void)showIntroWithCustomView
//{
//    EAIntroPage *page1 = [EAIntroPage page];
//    page1.title = @"Hello world";
//    page1.desc = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
//    page1.bgImage = [UIImage imageNamed:@"1"];
//    page1.titleImage = [UIImage imageNamed:@"original"];
// 
//    UIView *viewForPage2 = [[UIView alloc] initWithFrame:self.view.bounds];
//    UILabel *labelForPage2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 220, 300, 30)];
//    labelForPage2.text = @"Some custom view";
//    labelForPage2.font = MOLightFont(32];
//    labelForPage2.textColor = [UIColor whiteColor];
//    labelForPage2.backgroundColor = [UIColor clearColor];
//    labelForPage2.transform = CGAffineTransformMakeRotation(M_PI_2*3);
//    [viewForPage2 addSubview:labelForPage2];
//    EAIntroPage *page2 = [EAIntroPage pageWithCustomView:viewForPage2];
// 
//    EAIntroPage *page3 = [EAIntroPage page];
//    page3.title = @"This is page 3";
//    page3.desc = @"Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.";
//    page3.bgImage = [UIImage imageNamed:@"3"];
//    page3.titleImage = [UIImage imageNamed:@"femalecodertocat"];
// 
//    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
// 
//    [intro setDelegate:self];
//    [intro showInView:self.view animateDuration:0.0];
// }
// 
// - (void)showIntroWithSeparatePagesInit
//{
//     EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds];
// 
//     [intro setDelegate:self];
//     [intro showInView:self.view animateDuration:0.0];
// 
//    EAIntroPage *page1 = [EAIntroPage page];
//    page1.title = @"Hello world";
//    page1.desc = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
//    page1.bgImage = [UIImage imageNamed:@"1"];
//    page1.titleImage = [UIImage imageNamed:@"original"];
// 
//    EAIntroPage *page2 = [EAIntroPage page];
//    page2.desc = @"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.";
//    page2.bgImage = [UIImage imageNamed:@"2"];
//    page2.titleImage = [UIImage imageNamed:@"supportcat"];
// 
//    EAIntroPage *page3 = [EAIntroPage page];
//    page3.title = @"This is page 3";
//    page3.desc = @"Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.";
//    page3.bgImage = [UIImage imageNamed:@"3"];
//    page3.titleImage = [UIImage imageNamed:@"femalecodertocat"];
// 
//    [intro setPages:@[page1,page2,page3]];
// }

#pragma mark - EAIntroDelegate

- (void)introDidFinish
{
    [[GDSettingManager instance] setIntroPageVersion:currentIntroVersion];
    LOG(@"Intro callback");
    if ([self.target respondsToSelector:self.callback])
    {
        [self.target performSelector:self.callback withObject:nil afterDelay:0];
    }
}


@end
