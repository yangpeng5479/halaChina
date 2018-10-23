//
//  GDMeViewController.m
//  Greadeal
//
//  Created by Elsa on 15/5/11.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDMeViewController.h"
#import "GDProductDetailsViewController.h"
#import "RDVTabBarController.h"

#import "UIArabicTableViewCell.h"
#import "OTCover.h"

#import "GDLoginViewController.h"
#import "GDRegsiterViewController.h"

#import "GDSettingViewController.h"
#import "GDWishListViewController.h"

#import "GDDeliveryAddressManageViewController.h"

#import "GDCSViewController.h"

#import "GDVoucherOrdersViewController.h"
#import "GDMyVouchersViewController.h"

#import "GDEditProfileViewController.h"
#import "GDReturnsViewController.h"
#import "GDSupportViewController.h"

#import "GDBuyMemberViewController.h"
#import "GDDeliveryOrderListViewController.h"

#import "GDShopDeliveryOrderListViewController.h"

#import "GDReservationDeliveryOrderListViewController.h"

#import "UIActionSheet+Blocks.h"


#define headerX  55

@interface GDMeViewController ()

@end

@implementation GDMeViewController

- (void)tapSetting
{
    GDSettingViewController *nv = [[GDSettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:nv animated:YES];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Me", @"我的");
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)GotMemberInfo
{
    [self performSelectorOnMainThread:@selector(LoginSuccess) withObject:nil waitUntilDone:NO];
}

- (void)LogoutSuccess
{
    [self LoginSuccess];
}

- (void)LoginSuccess
{
    if ([GDPublicManager instance].loginstauts==UNLOGIN)
    {
        signupBut.hidden = NO;
        loginBut.hidden = NO;
        
        username.hidden = YES;
        //memberView.hidden = YES;
        
        //memberDate.hidden = YES;
        //memberName.hidden = YES;
       
        //userphone.hidden = YES;
        voucherPanel.hidden = YES;
        
        avatarView.hidden = YES;
    }
    else
    {
        signupBut.hidden = YES;
        loginBut.hidden = YES;
        
        //memberView.hidden = NO;
        //memberName.hidden = NO;
        //memberDate.hidden = NO;
        
        username.hidden = NO;
        //userphone.hidden = NO;
        voucherPanel.hidden = NO;
        avatarView.hidden = NO;
        
        if ([[GDPublicManager instance] isMember])
        {
            //memberView.image = [UIImage imageNamed:@"member.png"];
            //memberName.text = NSLocalizedString(@"Gold Member",@"金卡");
           
            //NSString* strExpire = [NSString stringWithFormat:NSLocalizedString(@"Expired Date: %@", @"过期日期: %@"),[[GDPublicManager instance] memberEndDate]];
            //memberDate.text = strExpire;
        }
        else
        {
            //memberView.image= [UIImage imageNamed:@"non-member.png"];
            //memberName.text =  NSLocalizedString(@"Non Member", @"非会员");
            //memberDate.text = @"";
        }
        
        username.text  = [GDPublicManager instance].username;
        //userphone.text = [[GDPublicManager instance] memberPhone];
        
        [avatarView sd_setImageWithURL:[NSURL URLWithString:[GDPublicManager instance].user_avatar] placeholderImage:[UIImage imageNamed:@"avatar_defalut.png"]];
    }
    
    [meTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    CGRect r = self.view.bounds;
    
    meTableView = MOCreateTableView( r , UITableViewStyleGrouped, [UITableView class]);
    meTableView.dataSource = self;
    meTableView.delegate = self;
    meTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:meTableView];
    meTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
    if (self.rdv_tabBarController.tabBar.translucent) {
                UIEdgeInsets insets = UIEdgeInsetsMake(0,
                                                       0,
                                                       CGRectGetHeight(self.rdv_tabBarController.tabBar.frame),
                                                       0);
        
               meTableView.contentInset = insets;
               meTableView.scrollIndicatorInsets = insets;
    }
    
    // Configure the table header view.
    float  height = 136;
    headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, r.size.width, height)];
    headerView.image = [UIImage imageNamed:@"metabbg.png"];
    headerView.userInteractionEnabled = YES;
    
    //memberView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 26, 148, 91)];
    //memberView.userInteractionEnabled = YES;
    //[headerView addSubview:memberView];
    
    avatarView = [[UIImageView alloc] initWithFrame:CGRectMake((r.size.width-87)/2, 15, 87, 87)];
    avatarView.userInteractionEnabled = YES;
    avatarView.image = [UIImage imageNamed:@"avatar_defalut.png"];
    [headerView addSubview:avatarView];
    [avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editPhoto)]];
    avatarView.layer.masksToBounds = YES;
    avatarView.layer.cornerRadius = 87/2.0; 
    
    signupBut = [ACPButton buttonWithType:UIButtonTypeCustom];
    signupBut.frame = CGRectMake(30,(height-40)/2, 115*[GDPublicManager instance].screenScale, 40);
    [signupBut setStyleWithImage:@"button_white.png" highlightedImage:@"button_white.png" disableImage:@"button_white.png" andInsets:UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 2.0f)];
    [signupBut setLabelTextColor:MOAppTextBackColor() highlightedColor:MOAppTextBackColor() disableColor:nil];
    [signupBut setLabelFont:MOLightFont(18)];
    [signupBut setTitle:NSLocalizedString(@"Sign Up", @"注册") forState:UIControlStateNormal];
    [signupBut setCornerRadius:10];
    [signupBut addTarget:self action:@selector(tapSignup) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:signupBut];
    
    loginBut = [ACPButton buttonWithType:UIButtonTypeCustom];
    loginBut.frame = CGRectMake(175*[GDPublicManager instance].screenScale,(height-40)/2, 115*[GDPublicManager instance].screenScale, 40);
    [loginBut setStyleWithImage:@"button_white.png" highlightedImage:@"button_white.png" disableImage:@"button_white.png" andInsets:UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 2.0f)];
    [loginBut setLabelTextColor:MOAppTextBackColor() highlightedColor:MOAppTextBackColor() disableColor:nil];
    [loginBut setLabelFont:MOLightFont(18)];
    [loginBut setTitle:NSLocalizedString(@"Login", @"登录") forState:UIControlStateNormal];
    [loginBut setCornerRadius:0];
    [loginBut addTarget:self action:@selector(tapLogin) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:loginBut];
    
    username = MOCreateLabelAutoRTL();
    username.textAlignment = NSTextAlignmentCenter;
    username.frame = CGRectMake(0, 110, r.size.width, 20);
    username.font = MOLightFont(16);
    username.textColor = [UIColor whiteColor];
    username.backgroundColor = [UIColor clearColor];
    [headerView addSubview:username];
    
//    userphone = MOCreateLabelAutoRTL();
//    userphone.frame = CGRectMake(22, 62, 110, 20);
//    userphone.font = MOLightFont(12);
//    userphone.textColor = [UIColor whiteColor];
//    userphone.backgroundColor = [UIColor clearColor];
//    [memberView addSubview:userphone];
//
//    memberName = MOCreateLabelAutoRTL();
//    memberName.frame = CGRectMake(180, 43, [GDPublicManager instance].screenWidth-190, 20);
//    memberName.font = MOLightFont(18);
//    memberName.textColor = [UIColor whiteColor];
//    memberName.backgroundColor = [UIColor clearColor];
//    [headerView addSubview:memberName];
 
//    memberDate = MOCreateLabelAutoRTL();
//    memberDate.frame = CGRectMake(180, 87, [GDPublicManager instance].screenWidth-120, 20);
//    memberDate.font = MOLightFont(12);
//    memberDate.textColor = [UIColor whiteColor];
//    memberDate.backgroundColor = [UIColor clearColor];
//    [headerView addSubview:memberDate];

//    offsetY+=25;
//    voucherPanel = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, [GDPublicManager instance].screenWidth, 44)];
//    [headerView addSubview:voucherPanel];
//    
//    UIImageView* rightImage = [[UIImageView alloc] init];
//    rightImage.image = [[UIImage imageNamed:@"productLline.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
//    rightImage.frame= CGRectMake(0, 0,
//                                 [GDPublicManager instance].screenWidth, 0.5);
//    [voucherPanel addSubview:rightImage];
    
//    UIImageView* vLineImage = [[UIImageView alloc] init];
//    vLineImage.image = [[UIImage imageNamed:@"productLline.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
//    vLineImage.frame= CGRectMake([GDPublicManager instance].screenWidth/2, 0,
//                                 0.5, 44);
//    [voucherPanel addSubview:vLineImage];
//
//    
//    [voucherPanel addSubview:[self makeOrderView:NSLocalizedString(@"Voucher Orders", @"优惠券订单") withImage:@"whiteorders.png" withSel:@selector(gotoOrders) withX:0 withY:0]];
//    [voucherPanel addSubview:[self makeOrderView:NSLocalizedString(@"My Vouchers", @"我的优惠券") withImage:@"whitevourcher.png" withSel:@selector(gotoVouchers) withX:[GDPublicManager instance].screenWidth/2 withY:0]];
//    
    UIBarButtonItem*  scanButItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"scan_icon.png"] style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(scanAction)];
    
    self.navigationItem.leftBarButtonItem = scanButItem;
  
    UIBarButtonItem*  settingButItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain
                                                                    target:self action:@selector(tapSetting)];
    
    self.navigationItem.rightBarButtonItem = settingButItem;
    
    headerView.userInteractionEnabled = YES;
    [headerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editProfile)]];
    meTableView.tableHeaderView = headerView;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoginSuccess) name:kNotificationDidLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LogoutSuccess) name:kNotificationDidLogout object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GotMemberInfo) name:kNotificationDidMemberInfo object:nil];
    
    [self LoginSuccess];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView*)makeOrderView:(NSString*)text withImage:(NSString*)imageUrl withSel:(SEL) callback withX:(float)startX withY:(float)startY
{
    float butWidth = self.view.frame.size.width/2;
    float butHeight =  44;
    float offsetY = 5;
    
    UIView*  button = [[UIView alloc] initWithFrame:CGRectMake(startX, startY, butWidth, butHeight)];
    button.backgroundColor = [UIColor clearColor];
    button.userInteractionEnabled = YES;
    [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:callback]];
    
    UIImageView * iconImage = [[UIImageView alloc]initWithFrame:CGRectMake((butWidth-14)/2, offsetY, 14, 14)];
    
    iconImage.image = [UIImage imageNamed:imageUrl];
    [button addSubview:iconImage];
    
    offsetY+=14;
    
    UILabel* titleLabel =  MOCreateLabelAutoRTL();
    titleLabel.frame=CGRectMake(0, offsetY, butWidth, butHeight-offsetY);
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.font = MOLightFont(14);
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = text;
    titleLabel.numberOfLines = 0;
    [button addSubview:titleLabel];
    
    return button;
}

#pragma mark - Table view
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    if  (indexPath.section == kBuySection)
    {
        if (indexPath.row == 0)
        {
            cell.imageView.image = [UIImage imageNamed:@"vip.png"];
            cell.textLabel.text= NSLocalizedString(@"Buy Member Card", @"购买会员卡");
        }
        else if (indexPath.row == 1)
        {
            cell.imageView.image = [UIImage imageNamed:@"rules.png"];
            cell.textLabel.text= NSLocalizedString(@"Member Rules", @"会员规则");
        }
    }
    else if  (indexPath.section == kVourcherSection)
    {
        if (indexPath.row == 0)
        {
            cell.imageView.image = [UIImage imageNamed:@"voucher_order_me.png"];
            cell.textLabel.text= NSLocalizedString(@"Orders", @"订单");
        }
        else if (indexPath.row == 1)
        {
            cell.imageView.image = [UIImage imageNamed:@"my_voucher_me.png"];
            cell.textLabel.text= NSLocalizedString(@"Coupons", @"优惠券");
        }
    }
    else if  (indexPath.section == kDeliverySection)
    {
        if (indexPath.row == 0)
        {
            cell.imageView.image = [UIImage imageNamed:@"delivery_me.png"];
            cell.textLabel.text= NSLocalizedString(@"Delivery Orders", @"外卖订单");
        }
        else if (indexPath.row == 1)
        {
            cell.imageView.image = [UIImage imageNamed:@"dingdan_icon.png"];
            cell.textLabel.text= NSLocalizedString(@"Shopping Orders", @"商城订单");
        }

    }
    else if  (indexPath.section == kWishSection)
    {
        cell.imageView.image = [UIImage imageNamed:@"wishlist.png"];
        cell.textLabel.text= NSLocalizedString(@"Wish List", @"收藏");
    }
    else if  (indexPath.section == kShareSection)
    {
        if (indexPath.row == 0)
        {
            cell.imageView.image = [UIImage imageNamed:@"Helpme.png"];
            cell.textLabel.text= NSLocalizedString(@"Help", @"帮助");
        }
        else if (indexPath.row == 1)
        {
            cell.imageView.image = [UIImage imageNamed:@"me_phone.png"];
            cell.textLabel.text= NSLocalizedString(@"24-Hour Hotline", @"24小时热线电话");
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"app_share.png"];
            cell.textLabel.text= NSLocalizedString(@"App Share", @"App分享");
        }
      
    }
    else if  (indexPath.section == kSupportSection)
    {
        switch (indexPath.row) {
                case 0:
                    cell.imageView.image = [UIImage imageNamed:@"about.png"];
                    cell.textLabel.text= NSLocalizedString(@"About Us", @"关于");
                    break;
                case 1:
                    cell.imageView.image = [UIImage imageNamed:@"terms.png"];
                    cell.textLabel.text= NSLocalizedString(@"Privacy Policy", @"隐私政策");
                    break;
                default:
                    break;
        }
    }
   
    if  (indexPath.section == kBuySection)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.font = MOBlodFont(18);
        }
        else
            cell.textLabel.font= MOLightFont(14);
    }
    else
        cell.textLabel.font= MOLightFont(14);
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    if ([GDPublicManager instance].buy_section_show)
//    {
//        kBuySection = 0;
//        kShareSection = 1;
//        kVourcherSection = 2;
//        kDeliverySection = 3;
//        kWishSection = 3;
//        kSupportSection = 4;
//        return 5;
//    }
//    else
//    {
        int index = 0;
        kShareSection = index++;
        kVourcherSection = index++;
        //if ([[GDSettingManager instance] isChinese])
        //    kDeliverySection = index++;
        //else
            kDeliverySection = 9;
        kWishSection = index++;
        kSupportSection = index++;
    
        kBuySection = 10;
        return index;
//    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kBuySection)
        return 2;
    else if (section == kVourcherSection)
        return 2;
    else if (section == kDeliverySection)
        return 1;
    else if (section == kWishSection)
        return 1;
    else if (section == kShareSection)
        return 3;
    else if (section == kSupportSection)
        return 2;

    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == kBuySection || indexPath.section == kWishSection)
    {
        BOOL islogin = [self checkLogin];
        if (!islogin)
            return;
    }
    
    if (indexPath.section == kVourcherSection)
    {
        if (indexPath.row == 0)
        {
            [self gotoOrders];
        }
        else if (indexPath.row == 1)
        {
            [self gotoVouchers];
        }
    }
    else if (indexPath.section == kDeliverySection)
    {
        if (indexPath.row == 0)
        {
            GDReservationDeliveryOrderListViewController* nvCollection = [[GDReservationDeliveryOrderListViewController alloc] init];
            [self.navigationController pushViewController:nvCollection animated:YES];
        }
        else if (indexPath.row == 1)
        {
            GDShopDeliveryOrderListViewController * nvCollection = [[GDShopDeliveryOrderListViewController alloc] init];
            [self.navigationController pushViewController:nvCollection animated:YES];
        }
    }

    if (indexPath.section == kBuySection)
    {
        if (indexPath.row == 0)
        {
            [self buyCard];
        }
        else if (indexPath.row == 1)
        {
            [self useRules];
        }
    }
    else if (indexPath.section == kWishSection)
    {
        GDWishListViewController* nvCollection = [[GDWishListViewController alloc] init];
            [self.navigationController pushViewController:nvCollection animated:YES];
    }
    else if (indexPath.section == kShareSection)
    {
        if (indexPath.row == 0)
        {
            NSString* url = [NSString stringWithFormat:@"%@html/help/%@",MainWebPage,@([[GDSettingManager instance] language_id:NO])];
            
            GDReturnsViewController* nv = [[GDReturnsViewController alloc] init:url];
            [self.navigationController pushViewController:nv animated:YES];
        }
        else if (indexPath.row == 1)
        {
            [[GDPublicManager instance] makeHelp];
        }
        else
        {
            NSMutableArray *shareButtonTitleArray     = [[NSMutableArray alloc] init];
            NSMutableArray *shareButtonImageNameArray = [[NSMutableArray alloc] init];
            
            [shareButtonTitleArray addObject:@"Facebook"];
            [shareButtonTitleArray addObject:@"Twitter"];
            [shareButtonTitleArray addObject:@"QQ"];
            
            [shareButtonImageNameArray addObject:@"sns_icon_facebook"];
            [shareButtonImageNameArray addObject:@"sns_icon_twitter"];
            [shareButtonImageNameArray addObject:@"sns_icon_qq"];
            
            if ([[whatsappAccountManage sharedInstance] isInstalled])
            {
                [shareButtonTitleArray addObject:@"WhatsApp"];
                [shareButtonImageNameArray addObject:@"sns_icon_whatsapp"];
            }
            
            if ([[weixinAccountManage sharedInstance] isWXInstalled])
            {
                [shareButtonTitleArray addObject:NSLocalizedString(@"Wechat",@"微信好友")];
                [shareButtonTitleArray addObject:NSLocalizedString(@"Moments",@"微信朋友圈")];
                
                [shareButtonImageNameArray addObject:@"sns_icon_wechat"];
                [shareButtonImageNameArray addObject:@"sns_icon_moments"];
            }
            
            LXActivity *lxActivity = [[LXActivity alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonImageNameArray];
            [lxActivity showInView:self.view];

        }
        
    }
    else if (indexPath.section == kSupportSection)
    {
        switch (indexPath.row) {
                case 0:
                {
                    NSString* url = [NSString stringWithFormat:@"%@index.php?route=information/info&title=%@&language_id=%@",MainWebPage,@"Aboutus",@([[GDSettingManager instance] language_id:NO])];
                    
                    GDReturnsViewController* nv = [[GDReturnsViewController alloc] init:url];
                    [self.navigationController pushViewController:nv animated:YES];
                    
                }
                    break;
               
                case 1:
                {
                    NSString* url = [NSString stringWithFormat:@"%@index.php?route=information/info&title=%@&language_id=%@",MainWebPage,@"PrivacyPolicy",@([[GDSettingManager instance] language_id:NO])];
                    
                    GDReturnsViewController* nv = [[GDReturnsViewController alloc] init:url];
                    
                    [self.navigationController pushViewController:nv animated:YES];
                }
                break;
                default:
                    break;
            }
    }
}

#pragma mark - Action
- (BOOL)checkLogin
{
    if ([GDPublicManager instance].cid<=0)
    {
        [UIAlertView showWithTitle:nil
                           message:NSLocalizedString(@"Please login first", @"您还没有登录")
                 cancelButtonTitle:NSLocalizedString(@"OK", @"确定")
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          }];
        
        return NO;
    }
    return YES;
}

- (void)gotoOrders
{
    BOOL islogin = [self checkLogin];
    if (!islogin)
        return;
    
    GDVoucherOrdersViewController* nv = [[GDVoucherOrdersViewController alloc] init];
    [self.navigationController pushViewController:nv animated:YES];
}

- (void)gotoVouchers
{
    BOOL islogin = [self checkLogin];
    if (!islogin)
        return;
    
    GDMyVouchersViewController* nv = [[GDMyVouchersViewController alloc] init];
    [self.navigationController pushViewController:nv animated:YES];
}

- (void)useRules
{
    NSString* url = [NSString stringWithFormat:@"%@index.php?route=information/info&title=%@&language_id=%@",MainWebPage,@"MembersRules",@([[GDSettingManager instance] language_id:NO])];
    
    GDReturnsViewController* nv = [[GDReturnsViewController alloc] init:url];
    
    [self.navigationController pushViewController:nv animated:YES];
}

- (void)buyCard
{
    GDBuyMemberViewController* vc = [[GDBuyMemberViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)editPhoto
{
    [UIActionSheet showInView:self.view
                    withTitle:nil
            cancelButtonTitle:NSLocalizedString(@"Cancel",@"取消")
       destructiveButtonTitle:nil
            otherButtonTitles:@[NSLocalizedString(@"Take Photo", @"拍照"), NSLocalizedString(@"Choose Existing", @"相册")]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                         if (buttonIndex==0)
                         {
                             if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                             {
                                 AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                                 
                                 if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted)
                                 {
                                     [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Camera Service is disabled. Please go to Setting->Privacy->Camera grant the access right.", @"APP没有权限打开照相机, 请在 设置->隐私->相机 重新打开")
                                                                delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"确定")otherButtonTitles:nil, nil] show];
                                     return;
                                 }
                                 
                                 UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                 picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                 picker.delegate = self;
                                 picker.allowsEditing = YES;
                                 
                                 [self presentViewController:picker animated:YES completion:nil];
                                 
                             }
                             else
                             {
                                 [ProgressHUD showError:NSLocalizedString(@"Camera not supported by the device", @"")];
                             }
                         }
                         else if (buttonIndex==1)
                         {
                             if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
                             {
                                 
                                 UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                 picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                                 picker.delegate = self;
                                 picker.allowsEditing = YES;
                                 
                                 [self presentViewController:picker animated:YES completion:nil];
                             }
                         }
                     }];

}

- (void)editProfile
{
    if ([GDPublicManager instance].cid>0)
    {
        GDEditProfileViewController* nv = [[GDEditProfileViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:nv animated:YES];
    }
}

- (void)scanAction
{
    static QRCodeReaderViewController *reader = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        reader                        = [QRCodeReaderViewController new];
        reader.modalPresentationStyle = UIModalPresentationFormSheet;
    });
    reader.delegate = self;
    
    [reader setCompletionWithBlock:^(NSString *resultAsString) {
        LOG(@"Completion with result: %@", resultAsString);
    }];
    
    [self presentViewController:reader animated:YES completion:NULL];
}

- (void)tapSignup
{
    LOG(@"tapSignup");
    GDRegsiterViewController* vc = [[GDRegsiterViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nc = [[UINavigationController alloc]
                                  initWithRootViewController:vc];
    
    [self presentViewController:nc animated:YES completion:^(void) {}];
}

- (void)tapLogin
{
    LOG(@"tapLogin");
    GDLoginViewController* vc = [[GDLoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    UINavigationController *nc = [[UINavigationController alloc]
                                  initWithRootViewController:vc];
    
    [self presentViewController:nc animated:YES completion:^(void) {}];
}

#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        if ([result hasPrefix:@"http"])
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"QR Code", @"二维码内容")
                               message:result
                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消")
                     otherButtonTitles:@[NSLocalizedString(@"Open", @"打开")]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex != [alertView cancelButtonIndex]) {
                                      NSURL *url = [NSURL URLWithString:[result encodeUTF]];
                                      UIApplication *ourApplication = [UIApplication sharedApplication];
                                      [ourApplication openURL:url];
                                  }
                                  }];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"QR Code", @"二维码内容") message:result delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"确定") otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - LXActivityDelegate

- (void)didClickOnImageIndex:(NSString*)imageIndex
{
    NSString* title = NSLocalizedString(@"Download & Install Greadeal",@"下载Greadeal 应用并安装");
    NSString* desc=NSLocalizedString(@"\n1:Coupons in UAE\n2:Indispensible money saver for your lifestyle\n3:Secured payment\n4:Easy, fast, and assured",@"\n1:各种优惠\n2:阿联酋吃喝玩乐必备神器\n3:安全支付\n4:便捷又放心");
    NSString* desc1=NSLocalizedString(@"\n1:Indispensible money saver for your lifestyle\n2:Secured payment\n3:Easy, fast, and assured",@"n1:阿联酋吃喝玩乐必备神器\n2:安全支付\n3:便捷又放心");
    NSString* webUrl = [[GDPublicManager instance] getShareUrl];

    NSString* text = [NSString stringWithFormat:@"%@%@",title,desc];
    NSString* text1 = [NSString stringWithFormat:@"%@%@",title,desc1];
    
    NSURL*     url = [NSURL URLWithString:webUrl];
    UIImage* imageData = [UIImage imageNamed:@"Icon-120.png"];
    
    if ([imageIndex isEqualToString:@"sns_icon_facebook"])
    {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultDone)
            {
                [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
            }
            [controller dismissViewControllerAnimated:YES completion:nil];
        };
        controller.completionHandler =myBlock;
        
        [controller setInitialText:text];
        [controller addURL:url];
        [controller addImage:imageData];
        
        [self presentViewController:controller animated:YES completion:nil];
    }
    else if  ([imageIndex isEqualToString:@"sns_icon_twitter"])
    {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultDone)
            {
                [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
            }
            [controller dismissViewControllerAnimated:YES completion:nil];
        };
        controller.completionHandler =myBlock;
        
        [controller setInitialText:text1];
        [controller addURL:url];
        [controller addImage:imageData];
        
        [self presentViewController:controller animated:YES completion:nil];
    }
    else if  ([imageIndex isEqualToString:@"sns_icon_qq"])
    {
        NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:title forKey:@"paramTitle"];
        [parameters setObject:desc forKey:@"paramSummary"];
        [parameters setObject:webUrl forKey:@"paramUrl"];
        [parameters setObject:@"http://7xkdae.com2.z0.glb.qiniucdn.com/app/logo.png" forKey:@"paramImages"];
       
        [[qqAccountManage sharedInstance] clickAddShare:parameters];
        
    }
    else if  ([imageIndex isEqualToString:@"sns_icon_whatsapp"])
    {
        [[whatsappAccountManage sharedInstance] sendMessageToFriend:title withUrl:webUrl];
    }
    else if  ([imageIndex isEqualToString:@"sns_icon_wechat"])
    {
        NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:title forKey:@"title"];
        [parameters setObject:webUrl forKey:@"url"];
        [parameters setObject:desc forKey:@"description"];
        if (imageData!=nil)
            [parameters setObject:imageData forKey:@"image"];
        [[weixinAccountManage sharedInstance] sendMessageToFriend:parameters];
    }
    else if  ([imageIndex isEqualToString:@"sns_icon_moments"])
    {
        NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:title forKey:@"title"];
        [parameters setObject:webUrl forKey:@"url"];
        [parameters setObject:desc forKey:@"description"];
        if (imageData!=nil)
            [parameters setObject:imageData forKey:@"image"];
        
        [[weixinAccountManage sharedInstance] sendMessageToCycle:parameters];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    LOG(@"UIImagePickerController: User ended picking assets");
    
    if ([info objectForKey:UIImagePickerControllerOriginalImage]){
        UIImage* image=[info objectForKey:UIImagePickerControllerOriginalImage];
        
        avatarView.image = image;
        [avatarView setNeedsDisplay];
        [self uploadImage];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    LOG(@"UIImagePickerController: User pressed cancel button");
}


- (AFHTTPRequestOperation *)uploadImage
{
    [ProgressHUD show:NSLocalizedString(@"Uploading, Please wait a moment!", @"正在上传,请等待一会儿!")];
    
    NSString* url;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Image/upload_image_list"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFHTTPRequestOperation *op = [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                  {
                                      
                                          UIImage *eachImg = avatarView.image;
                                          
                                          float imageRatio = eachImg.size.height / eachImg.size.width;
                                          CGFloat newWidth = eachImg.size.width;
                                          if (newWidth > 960) {
                                              newWidth = 960;
                                          }
                                          
                                          UIImage *scaledImage = [UIImage scaleImage:eachImg ToSize:CGSizeMake(newWidth, newWidth*imageRatio)];
                                          
                                          int maxPackageSize = MIN(500 * 1024, 512000);
                                          float qualityFactor = 1;
                                          NSData *imageData = UIImageJPEGRepresentation(scaledImage, qualityFactor);
                                          while (imageData.length > maxPackageSize) {
                                              qualityFactor -= 0.05;
                                              imageData = UIImageJPEGRepresentation(scaledImage, qualityFactor);
                                          }
                                          
                                    // 上传图片，以文件流的格式
                                    [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"file%d", 1] fileName:@"avatar.png" mimeType:@"image/jpeg"];
                                      
                                  }
                                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                                  {
                                      [ProgressHUD dismiss];
                                      
                                    
                                      int status = [responseObject[@"status"] intValue];
                                      if (status==1)
                                      {
                                          
        
                                          NSArray* temp = responseObject[@"data"][@"image_key_list"];
                                          
                                          if (temp.count>0)
                                          {
                                              //uploading key
                                              NSString* key = [temp objectAtIndex:0];
                                              [self uploadAvatarKey:key];
                                          }
                                          
                                          
                                      }
                                      else
                                      {
                                          NSString *errorInfo =@"";
                                          SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
                                          LOG(@"errorInfo: %@", errorInfo);
                                          [ProgressHUD showError:errorInfo];
                                      }
                                      
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                  {
                                     
                                      [ProgressHUD showError:error.localizedDescription];
                                  }];
    
    [op setUploadProgressBlock:^(NSUInteger bytesWritten,long long totalBytesWritten,long long totalBytesExpectedToWrite)
     {
        
     }];
    return op;
}


-(void)uploadAvatarKey:(NSString*)key
{
    NSString* url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/customer/update_baseinfo"];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    NSDictionary *parameters;

    parameters = @{@"header":key,@"token":[GDPublicManager instance].token};

    [ProgressHUD show:NSLocalizedString(@"Processing...", @"处理中...") Interaction:NO];
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         LOG(@"JSON: %@", responseObject);
         [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
     LOG(@"error: %@", error.localizedDescription);
     [ProgressHUD showError:error.localizedDescription];
     }];
}

@end
