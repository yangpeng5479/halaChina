//
//  MOCountryViewController.m
//  Mozat
//
//  Created by tao tao on 8/2/12.
//  Copyright (c) 2012 MOZAT Pte Ltd. All rights reserved.
//

#import "MOCountryViewController.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "RDVTabBarController.h"

#define COUNTRY_NAME(code)  [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:code]

@interface MOCountryViewController ()

@property (nonatomic, retain) UILocalizedIndexedCollation *collation;
@property (nonatomic, retain) NSMutableArray *sectionsArray;

@end

@implementation MOCountryViewController {
}
@synthesize target;
@synthesize callback;
@synthesize countryCallingCode;
@synthesize mobileCountryCode;
@synthesize phoneNumberLength;
@synthesize previousCountryName;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.title = NSLocalizedString(@"Country", @"国家");
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Countries" ofType:@"plist"];
        countryDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        
	    NSArray *countryCodes = countryDict.allKeys;
        NSMutableDictionary *countryCodeToName = [[NSMutableDictionary alloc] initWithCapacity:countryCodes.count];
        for (NSString *code in countryCodes)
        {
            NSString *countryName = COUNTRY_NAME(code);
            if (countryName)
            {
                [countryCodeToName setObject:countryName forKey:code];
            }
        }
        
        countryCodeArray = [NSArray arrayWithArray:[countryCodeToName keysSortedByValueUsingComparator:^(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }]];
        
        countryNameArray = [NSMutableArray new];
        for (NSString *code in countryCodeArray)
        {
            NSString *countryName = COUNTRY_NAME(code);
            if (countryName)
            {
                [countryNameArray addObject:countryName];
            }
        }
        self.hidesBottomBarWhenPushed = YES;
        
        [self configureSections];
    }
    return self;
}

- (void)configureSections
{
	// Get the current collation and keep a reference to it.
    self.collation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger index, sectionTitlesCount = [[self.collation sectionTitles] count];
    
    NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    for (index = 0; index < sectionTitlesCount; index++)
    {
        NSMutableArray *array = [NSMutableArray array];
        [newSectionsArray addObject:array];
    }
    
    for (id item in countryDict.allKeys)
    {
        NSInteger sectionNumber;
        sectionNumber = [self.collation sectionForObject:COUNTRY_NAME(item) collationStringSelector:@selector(self)];
		// Get the array for the section.
        NSMutableArray *sectionItems = newSectionsArray[sectionNumber];
        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:[countryDict objectForKey:item]];
        [d setObject:item forKey:@"countryCode"];
        [sectionItems addObject:d];
    }
    
    self.sectionsArray = newSectionsArray;
  
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mainTableView = MOCreateTableView(self.view.bounds, UITableViewStylePlain, [UITableView class]);
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);

    [self.view addSubview:mainTableView];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_5_1)
	{
		mainTableView.sectionIndexColor = colorFromHexString(@"6a737d");
	}
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
    {
        mainTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
		[mainTableView setSeparatorInset:UIEdgeInsetsZero];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)checkLocalCountry
{
}

//- (void)configureInitialCountryCode:(NSString *)cc
//{
//    NSString *ccode = [cc uppercaseString];
//    
//    if (target != nil)
//    {
//		//countryCallingCode=[self getNameFromCode:ccode];
//        countryCallingCode = ccode;
//        NSDictionary *items;
//        items = [countryDict objectForKey:ccode];
//        mobileCountryCode = [items objectForKey:@"CountryCallingCode"];
//        phoneNumberLength = [items objectForKey:@"PhoneNumberLength"];
//        
//        [target performSelector:callback withObject:self];
//    }
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.collation sectionTitles] count];
}

- (NSInteger)   tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section
{
    NSArray *items = (self.sectionsArray)[section];
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.contentOffsetX = NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 ? 0 : -15;
    
	cell.detailTextLabel.textColor = [UIColor colorWithRed:0.717647 green:0.717647 blue:0.717647 alpha:1.0];
	cell.textLabel.textColor = [UIColor colorWithRed: 0.333333 green: 0.333333 blue: 0.333333 alpha:1.0];
   
    NSArray *sectionItems = (self.sectionsArray)[indexPath.section];
    NSDictionary *d = sectionItems[indexPath.row];
    cell.textLabel.text = COUNTRY_NAME([d objectForKey:@"countryCode"]);
    cell.detailTextLabel.text = [d objectForKey:@"CountryCallingCode"];
		
    if([[d objectForKey:@"countryCode"] isEqualToString:previousCountryName])
    {
        cell.textLabel.textColor = [UIColor blueColor];
        cell.detailTextLabel.textColor = [UIColor blueColor];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *ccode;
    
    NSArray *sectionItems = (self.sectionsArray)[indexPath.section];
    NSDictionary *d = sectionItems[indexPath.row];
       ccode = [d objectForKey:@"countryCode"];
    
    if (target != nil)
    {
		//countryCallingCode=[self getNameFromCode:ccode];
        countryCallingCode = ccode;
        NSDictionary *items;
        items = [countryDict objectForKey:ccode];
        NSString* CountryCallingCode = [items objectForKey:@"CountryCallingCode"];
        
        NSDictionary* parameters = @{@"id":CountryCallingCode};
        if ([target respondsToSelector:callback])
        {
            [target performSelector:callback withObject:parameters afterDelay:0];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *sectionItems = (self.sectionsArray)[section];
    if (sectionItems.count)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 24.f)];
        view.backgroundColor = colorFromHexString(@"f2f4f5");
			
        UILabel* label = MOCreateLabelAutoRTL();
        label.frame = CGRectMake(10, 3, self.view.bounds.size.width-20, 20.f);
        label.text = [self.collation sectionTitles][section];
        label.textColor = [UIColor blackColor];
        label.font = MOBlodFont(16);
        label.backgroundColor = [UIColor clearColor];
        [view addSubview:label];
        
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
					atIndex:(NSInteger)index
{
    return [self.collation sectionForSectionIndexTitleAtIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.collation sectionIndexTitles];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSArray *sectionItems = (self.sectionsArray)[section];
    if (sectionItems.count)
    {
        return 24.f;
    }
    else
    {
        return 0.f;
    }
}

@end
