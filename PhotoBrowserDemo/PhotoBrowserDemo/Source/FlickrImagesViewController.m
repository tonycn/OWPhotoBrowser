//
//  FlickrImagesViewController.m
//  PhotoBrowserDemo
//
//  Created by Jianjun Wu on 4/4/14.
//  Copyright (c) 2014 Jianjun. All rights reserved.
//

#import "FlickrImagesViewController.h"

#import "OWSimpleURLConnection.h"
#import "OWCustomPhotosDataSource.h"
#import "OWPhotoBrowserController.h"

static NSArray *gSmallImages = nil;
static NSArray *gLargeImages = nil;

@interface FlickrImagesViewController ()
@property (strong, nonatomic)  NSArray *imageViews;
@end

@implementation FlickrImagesViewController

+ (void)initialize
{
  if (self == [FlickrImagesViewController class]) {
    gSmallImages = @[@"https://farm9.staticflickr.com/8440/7931832934_dd2d1e6015.jpg",
                     @"https://farm9.staticflickr.com/8441/7936905134_db5b0e9d7a.jpg",
                     @"https://farm9.staticflickr.com/8032/8024062104_572fd07e5a.jpg",
                     @"https://farm9.staticflickr.com/8456/8027595902_d478fc9199.jpg"
                     ];
    
    gLargeImages = @[@"https://farm9.staticflickr.com/8440/7931832934_0134f56441_h.jpg",
                     @"https://farm9.staticflickr.com/8441/7936905134_819c3f4b71_o.jpg",
                     @"https://farm9.staticflickr.com/8032/8024062104_9d69268f67_h.jpg",
                     @"https://farm9.staticflickr.com/8456/8027595902_d478fc9199_b.jpg"
                     ];

  }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  self.imageViews = [self.view subviews];
  [self.imageViews enumerateObjectsUsingBlock:^(UIImageView *v, NSUInteger idx, BOOL *stop) {
    
    v.backgroundColor = [UIColor colorWithWhite:.4 alpha:1.f];
    v.layer.masksToBounds = YES;
    
    NSURL *url = [NSURL URLWithString:gSmallImages[idx]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    __block OWSimpleURLConnection * connection = nil;
    connection = [OWSimpleURLConnection OW_asyncRequest:req progressHandler:^(NSUInteger totalBytes, NSUInteger receivedBytes) {

    } completionHandler:^(OWSimpleURLConnection *conn, NSData *data, NSError *connectionError) {
      if (connectionError == nil && conn.httpResponse.statusCode == 200) {
        connection = conn;
        v.image = [[UIImage alloc] initWithData:data scale:[UIScreen mainScreen].scale];
        [self addTapGestureToView:v];
      }
    }];
    [connection start];
  }];
}

- (void)addTapGestureToView:(UIImageView *)imageView
{
  imageView.userInteractionEnabled = YES;
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapped:)];
  [imageView addGestureRecognizer:tapGesture];
}

- (void)didTapped:(UITapGestureRecognizer *)gesture
{
  [self showFromView:(id)gesture.view];
}

- (void)showFromView:(UIImageView *)view
{
  OWCustomPhotosDataSource *datasource = [[OWCustomPhotosDataSource alloc] initWithImageURLs:gLargeImages];
//  datasource.thumbnailViews = self.imageViews;
  OWPhotoBrowserController *photoBrowser = [[OWPhotoBrowserController alloc] initWithDataSource:datasource];
  [photoBrowser setCurrentPage:[self.imageViews indexOfObject:view]];
  photoBrowser.fromView = nil;
  [self presentViewController:photoBrowser
                     animated:view.image ? YES : NO
                   completion:NULL];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
  return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationPortrait;
}

@end
