//
//  GDGridLayoutViewController.m
//  Greadeal
//
//  Created by Elsa on 15/8/25.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import "GDGridLayoutViewController.h"
#import "KRLCollectionViewGridLayout.h"

#import "RDVTabBarController.h"

#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

@interface GDGridLayoutViewController ()

@end

@implementation GDGridLayoutViewController

static NSString * const reuseIdentifier = @"Cell";

- (id)init:(NSMutableArray*)photos
{
    self = [super init];
    if (self)
    {
        photosArray = [[NSMutableArray alloc] init];
        photosArray = photos;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.title = NSLocalizedString(@"Menus", @"菜单");
   
    
    self.view.backgroundColor = MOColorAppBackgroundColor();
    
    CGRect r = self.view.bounds;
    float h = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    r.size.height-=h;

    //先实例化一个层
    KRLCollectionViewGridLayout *layout=[[ KRLCollectionViewGridLayout alloc ] init ];
    layout.numberOfItemsPerLine = 4;
    layout.aspectRatio = 1;
    layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
    layout.interitemSpacing = 8;
    layout.lineSpacing = 8;
    
    photosCollection=[[UICollectionView alloc] initWithFrame:r collectionViewLayout:layout];
    
    photosCollection.delegate=self;
    photosCollection.dataSource=self;
    
    // Register cell classes
    [photosCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self.view addSubview:photosCollection];
    photosCollection.backgroundColor = [UIColor clearColor];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapImageView:(UIGestureRecognizer *)tapGesture
{
    UIImageView *button = (UIImageView *)tapGesture.view;
    int index = (int)button.tag;
    
    if (index>=0)
    {
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity: [photosArray count]];
        for (int i = 0; i < [photosArray count]; i++) {
            
            NSString* getImageStrUrl = [photosArray objectAtIndex:i];
             
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [NSURL URLWithString: [getImageStrUrl encodeUTF] ];
            [photos addObject:photo];
        }
        
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init:NO];
        browser.currentPhotoIndex = index;
        browser.photos = photos;
        [browser show];
    }
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.contentView.backgroundColor = [UIColor blueColor];
    
    UIImageView * iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, cell.frame.size.height, cell.frame.size.height)];
    iconImage.contentMode = UIViewContentModeScaleAspectFill;
    iconImage.clipsToBounds = YES;
    iconImage.tag = indexPath.row;
    NSString* imageUrl = [photosArray objectAtIndex:indexPath.row];

    iconImage.userInteractionEnabled = YES;
    [iconImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)]];
    [iconImage sd_setImageWithURL:[NSURL URLWithString:[imageUrl encodeUTF]]
                 placeholderImage:[UIImage imageNamed:@"live_store_default.png"]];
  
    [cell.contentView addSubview:iconImage];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   
}


@end
