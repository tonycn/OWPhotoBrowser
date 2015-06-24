//
//  OWPhotoZoomingView.m
//  OpenWire
//
//  Created by Jianjun Wu on 3/25/14.
//  Copyright (c) 2014 Jianjun. All rights reserved.
//

#import "OWPhotoZoomingView.h"

#import "OWSimpleProgressHUD.h"

NSString *const kOWPhotoZoomingViewSingleTapNotification = @"OWPhotoZoomingViewSingleTapNotification";
NSString *const kOWPhotoZoomingViewLongPressedNotification = @"OWPhotoZoomingViewLongPressedNotification";


NSString *const kOWPhotoZoomingViewNotificationObjectKeyImageView = @"SingleTapNotificationKeyImageView";
NSString *const kOWPhotoZoomingViewNotificationObjectKeyImage = @"SingleTapNotificationKeyImage";

static Class gImageViewClass = NULL;

@interface OWPhotoZoomingView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UITapGestureRecognizer *singleTapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) OWSimpleProgressHUD *progressHUD;
@end

@implementation OWPhotoZoomingView

+ (void)initialize
{
  gImageViewClass = [UIImageView class];
}

+ (void)setImageViewClass:(Class)imageViewClass
{
  NSParameterAssert([imageViewClass isSubclassOfClass:[UIImageView class]]);
  gImageViewClass = imageViewClass;
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    self.delegate = self;
    CGRect frame= self.frame;
    frame.origin = CGPointZero;
    self.photoImageView = [[gImageViewClass alloc] initWithFrame:frame];
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.photoImageView.autoresizingMask = ~UIViewAutoresizingNone;
    [self addSubview:self.photoImageView];
    
    self.singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(singTapped:)];
    [self addGestureRecognizer:self.singleTapGesture];
  }
  return self;
}

- (void)reLayoutImageView
{
  UIImage *img = self.photoImageView.image;
  CGFloat screenScale = [UIScreen mainScreen].scale;
  CGSize imgSize = CGSizeMake(img.size.width * img.scale / screenScale,
                              img.size.height * img.scale / screenScale);
  CGRect rect= self.frame;
  rect.origin = CGPointZero;
  if (imgSize.width < rect.size.width
      && imgSize.height < self.bounds.size.height) {
    self.photoImageView.frame = rect;
  } else {
    if (imgSize.width < rect.size.width) {
      rect.size.height = imgSize.height;
    }
    self.photoImageView.frame = rect;
  }
  self.contentSize = self.photoImageView.frame.size;
  [self.photoImageView setNeedsDisplay];
  self.contentOffset = CGPointZero;
}

- (void)setPhotoImage:(UIImage *)img
{
  CGFloat screenScale = [UIScreen mainScreen].scale;
  CGSize imgSize = CGSizeMake(img.size.width * img.scale / screenScale,
                              img.size.height * img.scale / screenScale);
  CGRect rect= self.frame;
  rect.origin = CGPointZero;
  if (imgSize.width < rect.size.width
      && imgSize.height < self.bounds.size.height) {
    self.photoImageView.frame = rect;
  } else {
    if (imgSize.width < rect.size.width) {
      rect.size.height = imgSize.height;
    }
    self.photoImageView.frame = rect;
  }
  self.contentSize = self.photoImageView.frame.size;
  self.photoImageView.image = img;
  [self.photoImageView setNeedsDisplay];
  
  if (img == nil) {
    self.loaded = NO;
  }
}

- (void)setLoadingProgress:(CGFloat)progress
{
  if (progress < 1.f && self.progressHUD == nil) {
    self.progressHUD = [[OWSimpleProgressHUD alloc] initWithFrame:self.bounds];
    [self.progressHUD showInView:self];

  } else if (progress == 1.f) {
    [self.progressHUD dismiss];
    self.progressHUD = nil;
  }
  self.progressHUD.progress = progress;
}

- (void)setLoaded:(BOOL)loaded
{
  if (_loaded == loaded) {
    return;
  }
  _loaded = loaded;
  if (_loaded) {
    UIImage *image = self.photoImageView.image;
    CGFloat scaleH = image.size.width / self.frame.size.width;
    CGFloat scaleV = image.size.height / self.frame.size.height;
    CGFloat maxScale = MAX(scaleH, scaleV);
    self.maximumZoomScale = MAX(2.f, maxScale);
    CGFloat minScale = MIN(scaleH, scaleV);
    self.minimumZoomScale = MIN(1.f, minScale);
    self.doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    [self.doubleTapGesture setNumberOfTapsRequired:2];
    self.doubleTapGesture.cancelsTouchesInView = YES;
    [self addGestureRecognizer:self.doubleTapGesture];
    [self.singleTapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
    
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(longPressed:)];
    [self addGestureRecognizer:self.longPressGesture];
    [self.doubleTapGesture requireGestureRecognizerToFail:self.longPressGesture];
  } else {
    [self removeGestureRecognizer:self.doubleTapGesture];
  }
}

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer
{
  if (self.zoomScale == 1.f) {
    self.zoomScale = self.maximumZoomScale;
  } else {
    self.zoomScale = 1.f;
  }
}

- (void)singTapped:(UITapGestureRecognizer *)recognizer
{
  NSDictionary *objInfo = @{};
  if (self.photoImageView.image) {
    objInfo = @{
      kOWPhotoZoomingViewNotificationObjectKeyImageView :self.photoImageView,
      kOWPhotoZoomingViewNotificationObjectKeyImage : self.photoImageView.image
      };
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:kOWPhotoZoomingViewSingleTapNotification
                                                      object:objInfo];
}

- (void)longPressed:(UILongPressGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    NSDictionary *objInfo = @{};
    if (self.photoImageView.image) {
      objInfo = @{
                  kOWPhotoZoomingViewNotificationObjectKeyImageView :self.photoImageView,
                  kOWPhotoZoomingViewNotificationObjectKeyImage : self.photoImageView.image
                  };
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kOWPhotoZoomingViewLongPressedNotification
                                                        object:objInfo];
  }
}

- (void)setContentOffset:(CGPoint)contentOffset
{
  const CGSize contentSize = self.contentSize;
  const CGSize scrollViewSize = self.bounds.size;
  
  if (contentSize.width < scrollViewSize.width) {
    contentOffset.x = -(scrollViewSize.width - contentSize.width) / 2.0;
  }
  
  if (contentSize.height < scrollViewSize.height) {
    contentOffset.y = -(scrollViewSize.height - contentSize.height) / 2.0;
  }
  
  [super setContentOffset:contentOffset];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
  return self.photoImageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
  
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
  self.scrollEnabled = YES; // reset
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
  
}

@end
