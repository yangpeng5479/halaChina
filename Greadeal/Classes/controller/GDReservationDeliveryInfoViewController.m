//
//  GDReservationDeliveryInfoViewController.m
//  Greadeal
//
//  Created by Elsa on 16/6/3.
//  Copyright © 2016年 Elsa. All rights reserved.
//

#import "GDReservationDeliveryInfoViewController.h"

@interface GDReservationDeliveryInfoViewController ()

@end

@implementation GDReservationDeliveryInfoViewController

- (id)init:(NSDictionary*)vender_info
{
    self = [super init];
    if (self)
    {
        venderinfo = vender_info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect r = self.view.bounds;
    
    mainTableView = MOCreateTableView( r , UITableViewStyleGrouped, [UITableView class]);
    mainTableView.dataSource = self;
    mainTableView.delegate   = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainTableView];
    mainTableView.backgroundColor = MOColorSaleProductBackgroundColor();
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1)
        return 60;
    else
        return 44;
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
    
    if  (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            NSString* phone = @"";
            SET_IF_NOT_NULL(phone, venderinfo[@"telephone"]);
            
            cell.imageView.image = [UIImage imageNamed:@"info_phone.png"];
            cell.textLabel.text= [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Phone", @"电话"),[GDPublicManager instance].workPhone];
            
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_call_phone.png"]];
        }
        else if (indexPath.row == 1)
        {
            NSString* address = @"";
            SET_IF_NOT_NULL(address, venderinfo[@"address"]);
            
            cell.textLabel.numberOfLines = 0;
            cell.imageView.image = [UIImage imageNamed:@"info_address.png"];
            cell.textLabel.text= [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Address", @"地址"),address];
        }
    }
    else if  (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            NSString*  delivery_time_min=@"0";
            SET_IF_NOT_NULL(delivery_time_min, venderinfo[@"delivery_time_min"]);
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Delivery Time: %@Mins", @"配送时间: %@分钟"),delivery_time_min];
            
            cell.imageView.image = [UIImage imageNamed:@"info_delivery.png"];
        }
        else if (indexPath.row == 1)
        {
            NSArray* openTimeArray = nil;
            SET_IF_NOT_NULL(openTimeArray,venderinfo[@"open_time"]);
            if (openTimeArray.count>0)
            {
                NSDictionary* dict = [openTimeArray objectAtIndex:0];
                if (dict!=nil)
                {
                    NSString* open_time_start = dict[@"open_time_start"];
                    NSString* open_time_end   = dict[@"open_time_end"];
                    
                    NSString* sTime = [NSString stringWithFormat:@"%@",[open_time_start substringToIndex:5]];
                    NSString* eTime = [NSString stringWithFormat:@"%@",[open_time_end substringToIndex:5]];
                    
                    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Opening Hours: %@ - %@",@"营业时间: %@ - %@"),sTime,eTime];
                    
                }
            }
            cell.imageView.image = [UIImage imageNamed:@"info_openhour.png"];
            
        }
    }
    else if  (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            NSString*  sale_off=@"0";
            SET_IF_NOT_NULL(sale_off, venderinfo[@"discount"]);
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Sale: %@%% OFF", @"折扣: %@%%"),sale_off];
            
            cell.imageView.image = [UIImage imageNamed:@"info_sale.png"];
        }
    }
    
    cell.textLabel.font = MOLightFont(14);
    cell.textLabel.textColor = MOColor66Color();
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSString*  sale_off=@"0";
    SET_IF_NOT_NULL(sale_off, venderinfo[@"discount"]);
    
    int  n_sale_off = [sale_off intValue];
    if (n_sale_off>0)
        return 2;
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 1;
        default:
            break;
    }
    return 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        [[GDPublicManager instance] makeHelp];
    }
}

@end
