//
//  GDGridLayoutViewController.h
//  Greadeal
//
//  Created by Elsa on 15/8/25.
//  Copyright (c) 2015年 Elsa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDGridLayoutViewController : UIViewController <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>
{
    UICollectionView *photosCollection;
    NSMutableArray   *photosArray;
}

- (id)init:(NSMutableArray*)photos;

@end
