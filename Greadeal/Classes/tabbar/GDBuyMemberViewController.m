//
//  GDBuyMemberViewController.m
//  Greadeal
//
//  Created by Elsa on 15/11/26.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import "GDBuyMemberViewController.h"
#import "RDVTabBarController.h"
#import "GDPayMemberViewController.h"

@implementation GDBuyMemberViewController

#pragma mark - Helpers

- (void)buyCard
{
   
     NSInteger selectRank = [(DLRadioButton *)memberButtons[0] selectedButton].tag;
     if (selectRank>0)
     {
         NSDictionary *dict = pricesArray[selectRank-1];
         int rank = [dict[@"level"] intValue];
         float price = [dict[@"price"] floatValue];
         int level = [dict[@"membership_card_id"] intValue];
         
         if (rank>=[GDPublicManager instance].memberRank)
         {
             GDPayMemberViewController* vc  = [[GDPayMemberViewController alloc] init:rank withPrice:price withLevel:level];
             [self.navigationController pushViewController:vc animated:YES];
         }
         else
         {
             NSString* memberName;
             switch ([GDPublicManager instance].memberRank)
             {
                 case MEMBER_NON:
                     memberName = NSLocalizedString(@"Non Member", @"非会员");
                     break;
                 case MEMBER_BLUE:
                     memberName = NSLocalizedString(@"Gold Member", @"金卡会员");
                     break;
                 case MEMBER_GOLD:
                     memberName = NSLocalizedString(@"Gold Member", @"金卡会员");
                     break;
                 case MEMBER_PLATINUM:
                     memberName = NSLocalizedString(@"Platinum Member", @"白金卡会员");
                     break;
                 default:
                     break;
             }
             
             NSString* memberSelete;
             switch (rank) {
                 case MEMBER_BLUE:
                     memberSelete = NSLocalizedString(@"Gold Member", @"金卡会员");
                     break;
                 case MEMBER_GOLD:
                     memberSelete = NSLocalizedString(@"Gold Member", @"金卡会员");
                     break;
                 case MEMBER_PLATINUM:
                     memberSelete = NSLocalizedString(@"Platinum Member", @"白金卡会员");
                     break;
                 default:
                     break;
             }
             NSString* noteStr = [NSString stringWithFormat:NSLocalizedString(@"You are already %@ and unable to \ndegrade menbership for %@", @"您已经是%@,不能在降级购买%@"),memberName,memberSelete];
             
             [UIAlertView showWithTitle:NSLocalizedString(@"Note", nil)
                                message:noteStr
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil
                               tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                   if (buttonIndex == [alertView cancelButtonIndex]) {
                                       
                                   }
                               }];
         }
             
        
     }
     else
     {
         [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                            message:NSLocalizedString(@"No choose card", @"没有选择卡")
                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                  otherButtonTitles:nil
                           tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                               if (buttonIndex == [alertView cancelButtonIndex]) {
                                   
                               }
                           }];
     }
}

#pragma mark - UIViewController

- (void)createSection:(float)offset withImage:(NSString*)strImage withColor:(UIColor*)aColor withStr:(NSString*)aString
{
    UIImageView *memberImage = [[UIImageView alloc] init];
    memberImage.backgroundColor = [UIColor clearColor];
    memberImage.contentMode = UIViewContentModeScaleAspectFill;
    memberImage.clipsToBounds = YES;
    memberImage.image = [UIImage imageNamed:strImage];
    memberImage.frame = CGRectMake(10, offset, memberIconWidth, memberIconHeight);
    [self.view addSubview:memberImage];
    
    UILabel *Member  = [[UILabel alloc] init];
    Member.frame = CGRectMake(50, offset, 150, memberIconHeight);
    Member.font =  MOBlodFont(18);
    Member.textColor = aColor;
    Member.backgroundColor = [UIColor clearColor];
    Member.text = aString;
    [self.view addSubview:Member];

}

- (DLRadioButton*)createButton:(float)offset withStr:(NSString*)aString withId:(int)membership_card_id
{
    DLRadioButton* tempBut = [[DLRadioButton alloc] initWithFrame:CGRectMake(50, offset, 200, 20)];
    [tempBut setTitle:aString forState:UIControlStateNormal];
    [tempBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    tempBut.circleColor = [UIColor grayColor];
    tempBut.indicatorColor = [UIColor redColor];
    tempBut.tag = membership_card_id;
    [self.view addSubview:tempBut];
    tempBut.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    return tempBut;
}

- (void)showPriceList
{
    DLRadioButton *firstRadioButton;
    NSMutableArray *otherButtons = [NSMutableArray new];
    
    offsetY = 10;
    
    for (NSDictionary* dict in pricesArray)
    {
        int level = [dict[@"level"] intValue];
        int membership_card_id = [dict[@"membership_card_id"] intValue];
        int price = [dict[@"price"] intValue];
        int days  = [dict[@"days"] intValue];
        
        switch (level) {
            case MEMBER_BLUE:
            {
                if (days==365)
                {
                    [self createSection:offsetY withImage:@"gold.png" withColor:colorFromHexString(@"0b64b1") withStr:NSLocalizedString(@"Gold Card", @"金卡")];
                    blueSection = YES;
        
                    offsetY+=30;
                    DLRadioButton* radioButton1 = [self createButton:offsetY withStr:[NSString stringWithFormat:NSLocalizedString(@"%@%d /Year",@"%@%d /年"),[GDPublicManager instance].currency,price] withId:membership_card_id];
                    [otherButtons addObject:radioButton1];
                }
                
            }
            break;
//            case MEMBER_GOLD:
//            {
//                offsetY+=35;
//                [self createSection:offsetY withImage:@"gold.png" withColor:colorFromHexString(@"cfa248") withStr:NSLocalizedString(@"Gold Card", @"金卡")];
//                goldSection = YES;
//                
//                offsetY+=30;
//                DLRadioButton* radioButton1 = [self createButton:offsetY withStr:[NSString stringWithFormat:NSLocalizedString(@"%@%d /Year",@"%@%d /年"),[GDPublicManager instance].currency,price] withId:membership_card_id];
//                [otherButtons addObject:radioButton1];
//
//            }
//                break;
//            case MEMBER_PLATINUM:
//            {
//                offsetY+=35;
//                [self createSection:offsetY withImage:@"platinum.png" withColor:colorFromHexString(@"a67f44") withStr:NSLocalizedString(@"Platinum Card", @"白金卡")];
//                platinumSection = YES;
//                
//                offsetY+=30;
//                DLRadioButton* radioButton1 = [self createButton:offsetY withStr:[NSString stringWithFormat:NSLocalizedString(@"%@%d /Year",@"%@%d /年"),[GDPublicManager instance].currency,price] withId:membership_card_id];
//                [otherButtons addObject:radioButton1];
//            }
//                break;
            default:
                break;
        }
    }
    
    firstRadioButton.otherButtons = otherButtons;
    [memberButtons addObjectsFromArray:otherButtons];
   
    offsetY+=30;
    [self getNote];
    
    ACPButton *buyMemberBut = [ACPButton buttonWithType:UIButtonTypeCustom];
    buyMemberBut.frame = CGRectMake(10, self.view.frame.size.height-40, [GDPublicManager instance].screenWidth-20, 36);
    [buyMemberBut setStyleRedButton];
    [buyMemberBut setTitle: NSLocalizedString(@"Continue to pay", @"确定并支付") forState:UIControlStateNormal];
    [buyMemberBut addTarget:self action:@selector(buyCard) forControlEvents:UIControlEventTouchUpInside];
    [buyMemberBut setLabelFont:MOLightFont(16)];
    [self.view addSubview:buyMemberBut];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Buy Member Card",@"购买会员卡");
    
    self.view.backgroundColor  = MOColorSaleProductBackgroundColor();
    
    blueSection  = NO;
    goldSection  = NO;
    platinumSection = NO;
    
    pricesArray   = [[NSMutableArray alloc] init];
    memberButtons = [[NSMutableArray alloc] init];
    
    [self getMemberPriceList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getNote
{
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/page/get_html"];
    
    parameters = @{@"key":@"use_rules",@"language_id":@([[GDSettingManager instance] language_id:NO])};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             NSString* html = responseObject[@"data"][@"html"];
             
             UILabel* noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, offsetY, [GDPublicManager instance].screenWidth-20,200)];
             noticeLabel.font = MOLightFont(12);
             noticeLabel.textAlignment = NSTextAlignmentLeft;
             noticeLabel.textColor = MOColorSaleFontColor();
             noticeLabel.numberOfLines = 0;
             
             NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
             noticeLabel.attributedText = attrStr;
             
             CGSize fittingSize = [noticeLabel sizeThatFits:CGSizeMake([GDPublicManager instance].screenWidth-20, 20)];
             noticeLabel.frame = CGRectMake(10, offsetY, [GDPublicManager instance].screenWidth-20,fittingSize.height);
             
             [self.view addSubview:noticeLabel];
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
             [ProgressHUD showError:errorInfo];
         }
         
         [ProgressHUD dismiss];
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [ProgressHUD showError:error.localizedDescription];
     }];
    
}

- (void)getMemberPriceList
{
    [ProgressHUD show:nil];
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Membership/get_membership_cards_on_sale"];
    
    parameters = @{@"language_id":@([[GDSettingManager instance] language_id:NO])};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
            @synchronized(pricesArray)
            {
                [pricesArray removeAllObjects];
            }
             
             pricesArray = responseObject[@"data"][@"membership_cards"];
             
             [self showPriceList];
         }
         else
         {
             NSString *errorInfo =@"";
             SET_IF_NOT_NULL( errorInfo , responseObject[@"info"]);
             LOG(@"errorInfo: %@", errorInfo);
             [ProgressHUD showError:errorInfo];
         }
         
         [ProgressHUD dismiss];
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [ProgressHUD showError:error.localizedDescription];
     }];

}
@end
