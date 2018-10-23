//
//  MOItemSelectViewController.m
//  Mozat
//
//  Created by taotao on 7/13/13.
//  Copyright (c) 2013 MOZAT Pte Ltd. All rights reserved.
//

#import "MOItemSelectViewController.h"
#import "RDVTabBarController.h"

@interface MOItemSelectViewController ()

@end

@implementation MOItemSelectViewController

- (id)initWithStyle:(UITableViewStyle)style withDict:(NSDictionary *)aDict value:(NSString*)aKey target:(id)aTarget action:(SEL)action withTitle:(NSString*)aTitle
{
    self = [super initWithStyle:style];
    if (self) {
        showDict = aDict;
		currentKey = aKey;
			
        indexList   = [[NSArray alloc] init];
        
		keyArray = [NSArray arrayWithArray:[[showDict allValues] sortedArrayUsingComparator:^(NSString* a, NSString* b) {
			return [a compare:b options:NSNumericSearch];
		}]];
		
        keyArray = [self arrayForSections:keyArray];
        
		target   = aTarget;
		callback = action;
		
		self.title = aTitle;
        
		self.hidesBottomBarWhenPushed = YES;
		
		self.tableView.backgroundColor = MOColorAppBackgroundColor();
		self.tableView.backgroundView = nil;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;

    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [ProgressHUD dismiss];
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	//!!!MUST put this line in viewDidLoad rather than in init!!! Otherwise the "Back" button with lose its text!!!
	MOInitTableView(self.tableView);
       // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)arrayForSections:(NSArray *)objects {
    
    //    https://gist.github.com/davidhexd/11123942
    //    //  For some locales (Arabic is one), index is always off by one -.-
    //
    //    NSInteger index = [[UILocalizedIndexedCollation currentCollation] sectionForObject:@"Alex" collationStringSelector:@selector(description)];
    //    NSString *sectionTitle = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:index];
    
    //  In this situation, sectionTitle is "B".
    /*
     * selector 需要返回一个 NSString ，按照这个返回的string来做分组排序，
     * | name | 是 | ContactEntity | 的Propty，直接有get方法
     */
    SEL selector = @selector(self);
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    // | sectionTitlesCount | 的值为 27 , | sectionTitles | 的内容为 A - Z + #，总计27，（不同的Locale会返回不同的值，见http://nshipster.com/uilocalizedindexedcollation/）
    NSInteger sectionTitlesCount = [[collation sectionTitles] count];
    
    // 创建 27 个 section 的内容
    NSMutableArray *mutableSections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
        [mutableSections addObject:[NSMutableArray array]];
    }
    
    // 将| objects |中的内容加入到 创建的 27个section中
    for (NSString* object in objects) {
        
        NSInteger sectionNumber = [collation sectionForObject:object
                                      collationStringSelector:selector];
        
        //  For some locales (Arabic is one), index is always off by one -.-
        if ([GDSettingManager instance].isRightToLeft)
        {
            if (sectionNumber>1)  sectionNumber--;
        }
        [[mutableSections objectAtIndex:sectionNumber] addObject:object];
    }
       
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
        NSArray *objectsForSection = [mutableSections objectAtIndex:idx];
        
        NSArray *sortedArray = [objectsForSection sortedArrayUsingComparator:^(id a, id b) {
            return [a compare:b options:NSCaseInsensitiveSearch];
        }];
        
        [mutableSections replaceObjectAtIndex:idx withObject:sortedArray];
    }
    
    // 删除空的section
    NSMutableArray *existTitleSections = [NSMutableArray array];
    
    for (NSArray *section in mutableSections) {
        if ([section count] > 0) {
            [existTitleSections addObject:section];
        }
    }
    
    // 删除空section 对应的索引(index)
    
    NSMutableArray *existTitles = [NSMutableArray array];
    NSArray *allSections = [collation sectionIndexTitles];
    
    for (NSUInteger i = 0; i < [allSections count]; i++) {
        if ([mutableSections[ i ] count] > 0) {
            [existTitles addObject:allSections[ i ]];
        }
    }
    indexList = existTitles;
    
    return existTitleSections;
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* str = indexList[section];
    
    UILabel* titleLabel = MOCreateLabelAutoRTL();
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = MOBlodFont(16);
    titleLabel.text = str;
    
    CGRect r =self.view.bounds;
    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(r.origin.x, 0, r.size.width, 20)];
    titleLabel.frame = CGRectMake(r.origin.x+15, 4, r.size.width-30, 20);
    hView.backgroundColor =[UIColor colorWithRed:(245/255.0) green:(245/255.0) blue:(245/255.0) alpha:1.0];
    
    [hView addSubview:titleLabel];
    return hView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return indexList[ section ];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return indexList;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return keyArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [keyArray[section] count];
    //return keyArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	UIArabicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[UIArabicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
	}
	cell.contentOffsetX = NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 ? 0 : -15;
    // Configure the cell...
    NSString* key = keyArray[indexPath.section][indexPath.row];
 
    cell.textLabel.text = key;//[showDict objectForKey:key];
	cell.textLabel.font = MOLightFont(14);
	if ([key isEqualToString:currentKey])
	{
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick.png"]];
    }
	else
	{
		cell.accessoryView = nil;
	}
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSString*  strKey = keyArray[indexPath.section][indexPath.row];
    NSString*  strid = @"";
    for (NSString *Key in [showDict allKeysForObject:strKey]) {
        strid = Key;
        break;
    }
    
    NSDictionary* parameters = @{@"id":strid,@"name":strKey};
                         
    if ([target respondsToSelector:callback])
    {
        [target performSelector:callback withObject:parameters afterDelay:0];
    }
    
    [self.navigationController popViewControllerAnimated:YES];

}

@end
