//
//  GDRatingViewController.m
//  Greadeal
//
//  Created by Elsa on 15/10/22.
//  Copyright © 2015年 Elsa. All rights reserved.
//

#import "GDRatingViewController.h"
#import "UIActionSheet+Blocks.h"
#import <AVFoundation/AVFoundation.h>  

#define  maxImage     4
#define  numberOfLine 4
#define  photosHeight (([[UIScreen mainScreen] bounds].size.width-20.0)/numberOfLine)

@interface GDRatingViewController ()

@end

@implementation GDRatingViewController

- (id)initWithProduct:(int)product_id
{
    self = [super init];
    if (self)
    {
        isVendor = NO;
        productId  = product_id;
    }
    return self;
}

- (id)initWithVendor:(int)vendor_id
{
    self = [super init];
    if (self)
    {
        isVendor = YES;
        vendorId = vendor_id;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Your Rating", @"您的评分");
    
    chosenImages   = [[NSMutableArray alloc] init];
    image_key_list = [[NSMutableArray alloc] init];
    
    self.view.backgroundColor = MOColorAppBackgroundColor();
   
    // Do any additional setup after loading the view.
    CWStarRateView *starRateView = [[CWStarRateView alloc] initWithFrame:CGRectMake(10, 20, 200, 30) numberOfStars:5];
    starRateView.scorePercent = 0.9;
    starRateView.allowIncompleteStar = YES;
    starRateView.hasAnimation = YES;
    starRateView.delegate = self;
    [self.view addSubview:starRateView];

    lastRatingTitleLabel = MOCreateLabelAutoRTL();
    lastRatingTitleLabel.backgroundColor = [UIColor clearColor];
    lastRatingTitleLabel.textColor = colorFromHexString(@"ffc700");
    lastRatingTitleLabel.font = MOLightFont(16);
    lastRatingTitleLabel.numberOfLines = 0;
    lastRatingTitleLabel.text = @"4.5";
    lastRatingTitleLabel.frame = CGRectMake([GDPublicManager instance].screenWidth-80, 20, 70, 30);
    [self.view addSubview:lastRatingTitleLabel];
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        CGRect tempRect = lastRatingTitleLabel.frame;
        tempRect.origin.x = 10;
        lastRatingTitleLabel.frame = tempRect;
        
        tempRect = starRateView.frame;
        tempRect.origin.x = self.view.frame.size.width-tempRect.size.width - 10;
        starRateView.frame = tempRect;
        
    }
    
    UILabel* commentLabel = MOCreateLabelAutoRTL();
    commentLabel.backgroundColor = [UIColor clearColor];
    commentLabel.textColor = MOColor33Color();
    commentLabel.font = MOLightFont(14);
    commentLabel.numberOfLines = 0;
    commentLabel.text = NSLocalizedString(@"Comment", @"评论");
    commentLabel.frame = CGRectMake(10, 65, [GDPublicManager instance].screenWidth-20, 20);
    [self.view addSubview:commentLabel];
    
    inputTextView = [[UICharCountingTextView alloc] initWithFrame:CGRectMake(10, 90, [GDPublicManager instance].screenWidth-20, 110)];
    inputTextView.backgroundColor = [UIColor clearColor];
    inputTextView.clipsToBounds = YES;
    inputTextView.delegate = self;
    inputTextView.placeholder = NSLocalizedString(@"Please write at most 140 characters about your personal experience at this store.", @"请写下您在本店的使用体验");
    inputTextView.maxNumberOfCharacter = 140;
    [self.view addSubview:inputTextView];

    UILabel* uploadLabel = MOCreateLabelAutoRTL();
    uploadLabel.backgroundColor = [UIColor clearColor];
    uploadLabel.textColor = MOColor33Color();
    uploadLabel.font = MOLightFont(14);
    uploadLabel.numberOfLines = 0;
    uploadLabel.text = NSLocalizedString(@"Upload Photos", @"上传图片");
    uploadLabel.frame = CGRectMake(10, 200, [GDPublicManager instance].screenWidth-20, 20);
    [self.view addSubview:uploadLabel];
    
    photosPage = [[UIView alloc] initWithFrame:CGRectMake(0, 220, self.view.frame.size.width, photosHeight*2)];
    photosPage.backgroundColor = [UIColor clearColor];
    [self.view addSubview:photosPage];
    
    float pHeight = photosHeight-10;
    float InteritemSpacing  = (self.view.frame.size.width-pHeight*numberOfLine)/(numberOfLine+1);
    
    addBut=[UIButton buttonWithType:UIButtonTypeCustom];
    [addBut setBackgroundImage:[UIImage imageNamed:@"addimage.png"] forState:UIControlStateNormal];
    addBut.frame = CGRectMake(InteritemSpacing, 5, photosHeight-10, photosHeight-10);
    [addBut addTarget:self action:@selector(selectImage) forControlEvents:UIControlEventTouchUpInside];
    [photosPage addSubview:addBut];
    
    [self showBarButton:YES];
}

- (void)showBarButton:(BOOL)isShow
{
    if (isShow)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",@"返回") style:UIBarButtonItemStylePlain target:self action:@selector(exit)];
    
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Submit", @"提交") style:UIBarButtonItemStylePlain target:self action:@selector(tapOk)];
        
        addBut.hidden = NO;
    }
    else
    {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem= nil;
        addBut.hidden = YES;
    }
}

- (void)exit
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (UIView*)makeOrderView:(UIImage*)imageData withIndex:(int)nIndex
{
    float offsetY = 5;
    float pHeight = photosHeight-offsetY*2;
    
    float InteritemSpacing  = (self.view.frame.size.width-pHeight*numberOfLine)/(numberOfLine+1);
    float offsetX = nIndex*photosHeight+InteritemSpacing;
    
    if (nIndex/numberOfLine>=1)
    {
        offsetY += pHeight+5;
        offsetX = (nIndex%numberOfLine)*photosHeight+InteritemSpacing;
    }
    
    if ([GDSettingManager instance].isRightToLeft)
    {
        offsetX = [GDPublicManager instance].screenWidth - offsetX - photosHeight;
    }
    
    UIImageView * iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX,offsetY, pHeight, pHeight)];
    iconImage.tag = nIndex;
    iconImage.image =imageData;
    iconImage.userInteractionEnabled = YES;
    [iconImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)]];
    
    MODebugLayer(iconImage, 1.f, [UIColor redColor].CGColor);
    
    return iconImage;
}

- (void)relayoutImage
{
    for (UIView *view in photosPage.subviews)
    {
        [view removeFromSuperview];
    }
    
    for (int nIndex = 0;nIndex<chosenImages.count;nIndex++)
    {
        UIImage* imageUrl = [chosenImages objectAtIndex:nIndex];
        [photosPage addSubview:[self makeOrderView:imageUrl withIndex:nIndex]];
    }
    
   
    int nIndex = (int)chosenImages.count;
    
    if (nIndex<maxImage)
    {
        float offsetY = 5;
        float pHeight = photosHeight-offsetY*2;
    
        float InteritemSpacing  = (self.view.frame.size.width-pHeight*numberOfLine)/(numberOfLine+  1);
        float offsetX = nIndex*photosHeight+InteritemSpacing;
    
        if (nIndex/numberOfLine>=1)
        {
            offsetY += pHeight+5;
            offsetX = (nIndex%numberOfLine)*photosHeight+InteritemSpacing;
        }
    
        addBut.frame = CGRectMake(offsetX, offsetY, pHeight, pHeight);
        [photosPage addSubview:addBut];
    }
}

- (void)tapImageView:(UIGestureRecognizer *)tapGesture
{
    UIImageView *button = (UIImageView *)tapGesture.view;
    int index = (int)button.tag;
    
    if (index>=0)
    {
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity: [chosenImages count]];
        for (int i = 0; i < [chosenImages count]; i++) {
            UIImage* getImageStrUrl = [chosenImages objectAtIndex:i];
            
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.image = getImageStrUrl;
            [photos addObject:photo];
        }
        
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init:YES];
        browser.delegate = self;
        browser.currentPhotoIndex = index;
        browser.photos = photos;
        [browser show];
    }
}


- (void)selectImage
{
    [inputTextView resignFirstResponder];
    
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
                                 picker.allowsEditing = NO;
                                 
                                 [self presentViewController:picker animated:YES completion:nil];
                                 
                             }
                             else
                             {
                                 [ProgressHUD showError:NSLocalizedString(@"Camera not supported by the device", @"")];
                             }
                         }
                         else if (buttonIndex==1)
                         {
                             ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
                             
                             elcPicker.maximumImagesCount = maxImage-chosenImages.count; //Set the maximum number of images to select to 7
                             elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
                             elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
                             elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
                             elcPicker.mediaTypes = @[(NSString *)kUTTypeImage]; //Supports image and movie types
                             
                             elcPicker.imagePickerDelegate = self;
                             
                             [self presentViewController:elcPicker animated:YES completion:nil];
                         }
                     }];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)starRateView:(CWStarRateView *)starRateView scroePercentDidChange:(CGFloat)newScorePercent
{
    lastRatingTitleLabel.text = [NSString stringWithFormat:@"%.1f",newScorePercent];
}

#pragma mark - upload image data
- (NSString*)dataToJson
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:image_key_list options:NSJSONWritingPrettyPrinted error:nil];
    NSString* jsonStr = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
    
    return jsonStr;
}

- (void)tapOk
{
    [inputTextView resignFirstResponder];
    
    if (inputTextView.text.length < 10)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                           message:NSLocalizedString(@"Your comments should contain 10 or more characters", @"您的点评内容至少要10个字符")
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  
                              }
                          }];
        return;
    }
    
    
    if (chosenImages.count>0)
    {
        [self uploadImage];
    }
    else
    {
        [self addRate];
    }
}

- (void)addRate
{
    [ProgressHUD show:nil];
    
    NSString* url;
    NSDictionary *parameters;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/product/add_review"];
    
    if (isVendor)
    {
        if (image_key_list.count>0)
        {
             parameters = @{@"token":[GDPublicManager instance].token,@"vendor_id":@(vendorId),@"text":inputTextView.text,@"rating":lastRatingTitleLabel.text,@"imagelist_json":[self dataToJson]};
        }
        else
        {
            parameters = @{@"token":[GDPublicManager instance].token,@"vendor_id":@(vendorId),@"text":inputTextView.text,@"rating":lastRatingTitleLabel.text};
        }
    }
    else
    {
        if (image_key_list.count>0)
        {
            parameters = @{@"token":[GDPublicManager instance].token,@"product_id":@(productId),@"text":inputTextView.text,@"rating":lastRatingTitleLabel.text,@"imagelist_json":[self dataToJson]};
        }
        else
        {
            parameters = @{@"token":[GDPublicManager instance].token,@"product_id":@(productId),@"text":inputTextView.text,@"rating":lastRatingTitleLabel.text};
        }
    }
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    
    [manager POST:url
       parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [ProgressHUD dismiss];
         
         int status = [responseObject[@"status"] intValue];
         if (status==1)
         {
             [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
             
             [self exit];
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
}


- (AFHTTPRequestOperation *)uploadImage
{
    [ProgressHUD show:NSLocalizedString(@"Uploading, Please wait a moment!", @"正在上传,请等待一会儿!")];
    
    [self showBarButton:NO];
    
    NSString* url;
    
    url = [NSString stringWithFormat:@"%@%@",[GDPublicManager instance].APIBaseUrl,@"rest2/v1/Image/upload_image_list"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFHTTPRequestOperation *op = [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                  {
                                      for(int i=0; i<chosenImages.count; i++)
                                      {
                                          UIImage *eachImg = [chosenImages objectAtIndex:i];
                                          
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
                                          [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"file%d", i+1] fileName:@"rating.png" mimeType:@"image/jpeg"];
                                      }
                                  }
                                  success:^(AFHTTPRequestOperation *operation, id responseObject)
                                  {
                                      [ProgressHUD dismiss];
                                      
                                      [self showBarButton:YES];
                                      
                                      int status = [responseObject[@"status"] intValue];
                                      if (status==1)
                                      {
                                          [ProgressHUD showSuccess:NSLocalizedString(@"Done",@"完成")];
                                          
                                          @synchronized(image_key_list)
                                          {
                                                [image_key_list removeAllObjects];
                                          }
                                          
                                          NSArray* temp = responseObject[@"data"][@"image_key_list"];
                                          
                                          if (temp.count>0)
                                          {
                                              [image_key_list addObjectsFromArray:temp];
                                          }
                                          
                                          [self addRate];
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
                                      [self showBarButton:YES];
                                      [ProgressHUD showError:error.localizedDescription];
                                  }];
    
    [op setUploadProgressBlock:^(NSUInteger bytesWritten,long long totalBytesWritten,long long totalBytesExpectedToWrite)
     {
         // if (xxProgressView != nil) {
         //            [xxProgressView setProgressViewTo:totalBytesWritten*1.0/totalBytesExpectedToWrite];
     }];
    return op;
}

#pragma mark - PhotoBrowserDelegate
- (void)CellPhotoImageReload
{
    [self relayoutImage];
}

- (void)deleteImage:(NSInteger)ImageIndex
{
    @synchronized(chosenImages)
    {
        [chosenImages removeObjectAtIndex:ImageIndex];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    LOG(@"UIImagePickerController: User ended picking assets");
    
//    @synchronized(chosenImages)
//    {
//        [chosenImages removeAllObjects];
//    }
    
    if ([info objectForKey:UIImagePickerControllerOriginalImage]){
        UIImage* image=[info objectForKey:UIImagePickerControllerOriginalImage];
        [chosenImages addObject:image];
    }
    
    if (chosenImages.count>0)
    {
        [self relayoutImage];
        //[self uploadImage];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    LOG(@"UIImagePickerController: User pressed cancel button");
}


#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
//    @synchronized(chosenImages)
//    {
//        [chosenImages removeAllObjects];
//    }
    
    //NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
    for (NSDictionary *dict in info) {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                [chosenImages addObject:image];
                //[images addObject:image];
            } else {
                LOG(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        }
        else {
            LOG(@"Uknown asset type");
        }
    }
    
    //chosenImages = images;
    
    if (chosenImages.count>0)
    {
        [self relayoutImage];
        //[self uploadImage];
    }
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
