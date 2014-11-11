//
//  LocalImagesViewController.m
//  PhotoBrowserDemo
//
//  Created by Jianjun Wu on 4/4/14.
//  Copyright (c) 2014 Jianjun. All rights reserved.
//

#import "LocalImagesViewController.h"

#import "OWPhotosDataSource.h"
#import "OWPhotoBrowserController.h"

@interface LocalImagesViewController ()
@property (strong, nonatomic) NSArray *imageViews;
@end

@implementation LocalImagesViewController

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
  for (UIImageView *v in self.imageViews) {
    v.layer.masksToBounds = YES;
    [self addTapGestureToView:v];
  }
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
  NSArray *imgs = @[[self.imageViews[0] image],
                    [self.imageViews[1] image],
                    [self.imageViews[2] image],
                    [self.imageViews[3] image]];
  OWSimplePhotosDataSource *datasource = [[OWSimplePhotosDataSource alloc] initWithImages:imgs];
  OWPhotoBrowserController *photoBrowser = [[OWPhotoBrowserController alloc] initWithDataSource:datasource];
  [photoBrowser setCurrentPage:[self.imageViews indexOfObject:view]];
  photoBrowser.fromView = view;
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
