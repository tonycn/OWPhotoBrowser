//
//  OWPhotoBrowserController.m
//  OpenWire
//
//  Created by Jianjun Wu on 3/25/14.
//  Copyright (c) 2014 Jianjun. All rights reserved.
//

#import "OWPhotoBrowserController.h"

#import "OWPhotoZoomingView.h"
#import "OWPhotosScroller.h"

@interface OWPhotoBrowserPresentingAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, strong) UIImageView *fromView;
@end
@interface OWPhotoBrowserDismissingAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, strong) UIImageView *backToView;
@end

@interface OWPhotoBrowserController () <OWPhotosScrollerDelegate, UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) id<OWPhotosDataSource> datasource;
@property (nonatomic, strong) UIImageView *backToView;
@end

@implementation OWPhotoBrowserController

- (id)initWithDataSource:(id<OWPhotosDataSource>)photoDataSource
{
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    // Custom initialization
    self.datasource = photoDataSource;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
      self.transitioningDelegate = self;
    }
  }
  return self;
}

- (void)dealloc
{
  [self.datasource cancelAll];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
  CGRect rect = [UIScreen mainScreen].applicationFrame;
  rect.origin = CGPointZero;
  self.view = [[UIView alloc] initWithFrame:rect];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(didTapPhotoBrowser:)
                                               name:kOWPhotoZoomingViewSingleTapNotification
                                             object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  if ([self.datasource count] == 1) {
    OWPhotoZoomingView *photoView = [[OWPhotoZoomingView alloc] initWithFrame:self.view.bounds];
    photoView.autoresizingMask = ~UIViewAutoresizingNone;
    photoView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:photoView];
    [photoView setPhotoImage:self.fromView.image];
    [self loadImageAtPage:0 toView:photoView];
  } else {
    OWPhotosScroller *photosView = [[OWPhotosScroller alloc] initWithFrame:self.view.bounds];
    photosView.autoresizingMask = ~UIViewAutoresizingNone;
    photosView.delegate = self;
    [photosView setNumberOfPages:[self.datasource count]];
    [photosView setCurrentPage:self.currentPage defaultImage:self.fromView.image];
    [self.view addSubview:photosView];
  }
}

- (void)didTapPhotoBrowser:(NSNotification *)noti
{
  if ([self.datasource count] == 1) {
    self.backToView = self.fromView;
  } else {
    if ([self.datasource respondsToSelector:@selector(thumbnailImageViewAtIndex:)]) {
      self.backToView = [self.datasource thumbnailImageViewAtIndex:self.currentPage];
    }
  }
  BOOL animated = self.backToView.image ? YES : NO;
  if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
    animated = NO;
  }
  [self.presentingViewController dismissViewControllerAnimated:animated completion:NULL];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
  OWPhotoBrowserPresentingAnimator *animator = [[OWPhotoBrowserPresentingAnimator alloc] init];
  animator.fromView = self.fromView;
  return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
  OWPhotoBrowserDismissingAnimator *animator = [[OWPhotoBrowserDismissingAnimator alloc] init];
  animator.backToView = self.backToView;
  return animator;
}

- (void)loadImageAtPage:(NSUInteger)pageNO toView:(OWPhotoZoomingView *)view
{
  __weak OWPhotoZoomingView *weakView = view;
  if ([self.datasource respondsToSelector:@selector(thumbnailImageViewAtIndex:)]) {
    [view setPhotoImage:[self.datasource thumbnailImageViewAtIndex:pageNO].image];
  }
  __weak typeof(self) weakSelf = self;
  [self.datasource loadImageAtIndex:pageNO
                           progress:^(CGFloat percentage) {
                             [weakView setLoadingProgress:percentage];
                           }
                           complete:^(UIImage *image, __unused NSError *err) {
                             if (image) {
                               [weakView setPhotoImage:image];
                               weakView.loaded = (image != nil);
                             } else {
                               if ([weakSelf.datasource respondsToSelector:@selector(failureImage)]) {
                                 [weakView setPhotoImage:[weakSelf.datasource failureImage]];
                               }
                             }
                           }];
}

#pragma mark - OWPhotosScrollerDelegate
- (void)photosScrollerDidScrollToPage:(NSUInteger)pageNO
                            photoView:(OWPhotoZoomingView *)view
{
  self.currentPage = pageNO;
  if (!view.loaded) {
    [self loadImageAtPage:pageNO toView:view];
  }
}

@end

static CGFloat kOWPhotoBrowserDefaultAnimationDuration = 0.4f;

void _setBoundsToAnimationView(UIImageView *animationView, UIView *container)
{
  UIImage *img = animationView.image;
  CGFloat screenScale = [UIScreen mainScreen].scale;
  CGSize imgSize = CGSizeMake(img.size.width * img.scale / screenScale,
                              img.size.height * img.scale / screenScale);
  if (animationView.contentMode == UIViewContentModeScaleAspectFill) {
    CGFloat imgRatio = imgSize.width / imgSize.height;
    CGFloat containerRatio = container.bounds.size.width / container.bounds.size.height;
    
    if (imgRatio > containerRatio) {
      CGFloat verticalGap = floorf(container.bounds.size.height - container.bounds.size.width / imgRatio);
      CGRect frame = container.bounds;
      frame.origin.y = floorf(verticalGap / 2);
      frame.size.height -= verticalGap;
      animationView.frame = frame;
    } else {
      // Fit width.
      if (imgSize.width >= container.bounds.size.width) {
        CGRect frame = container.bounds;
        frame.size.height = container.bounds.size.width / imgRatio;
        animationView.frame = frame;
      } else {
        CGRect frame = container.bounds;
        frame.size.height = MAX(imgSize.height, container.bounds.size.height);
        animationView.frame = frame;
      }
    }
  } else {
    animationView.frame = container.frame;
  }
}

@implementation OWPhotoBrowserPresentingAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
  return kOWPhotoBrowserDefaultAnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
  UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  UIView *container = [transitionContext containerView];
  toViewController.view.transform = CGAffineTransformMakeScale(0, 0);
  [container addSubview:toViewController.view];

  UIImageView *animationView = [[UIImageView alloc] initWithImage:self.fromView.image];
  animationView.contentMode = self.fromView.contentMode;
  animationView.frame = [container convertRect:self.fromView.bounds fromView:self.fromView];
  animationView.backgroundColor = [UIColor blackColor];
  [container addSubview:animationView];

  UIView *animationBGView = nil;
  if (animationView.contentMode == UIViewContentModeScaleAspectFill) {
    animationBGView = [[UIView alloc] initWithFrame:container.bounds];
    animationBGView.backgroundColor = [UIColor blackColor];
    [container insertSubview:animationBGView belowSubview:animationView];
    animationBGView.alpha = 1.f;
  }
  
  [UIView animateKeyframesWithDuration:kOWPhotoBrowserDefaultAnimationDuration delay:0 options:0 animations:^{
    if (animationView.contentMode == UIViewContentModeScaleAspectFill) {
      _setBoundsToAnimationView(animationView, container);
      animationBGView.alpha = 1.f;
    } else {
      animationView.frame = container.bounds;
    }
  } completion:^(BOOL finished) {
    [animationView removeFromSuperview];
    [animationBGView removeFromSuperview];
    toViewController.view.transform = CGAffineTransformIdentity;
    [transitionContext completeTransition:finished];
  }];
}

@end


@implementation OWPhotoBrowserDismissingAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
  return kOWPhotoBrowserDefaultAnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
  UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  fromViewController.view.transform = CGAffineTransformMakeScale(0, 0);
  UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  UIView *container = [transitionContext containerView];
  [container insertSubview:toViewController.view belowSubview:fromViewController.view];

  UIImageView *animationView = [[UIImageView alloc] initWithImage:self.backToView.image];
  animationView.backgroundColor = [UIColor clearColor];
  [container addSubview:animationView];
  
  animationView.contentMode = self.backToView.contentMode;
  animationView.layer.masksToBounds = YES;
  if (animationView.contentMode == UIViewContentModeScaleAspectFill) {
    _setBoundsToAnimationView(animationView, container);
  }
  self.backToView.hidden = YES;
  [UIView animateKeyframesWithDuration:kOWPhotoBrowserDefaultAnimationDuration delay:0 options:0 animations:^{
    fromViewController.view.transform = CGAffineTransformMakeScale(0, 0);
    animationView.frame = [container convertRect:self.backToView.bounds
                                        fromView:self.backToView];
  } completion:^(BOOL finished) {
    [animationView removeFromSuperview];
    [transitionContext completeTransition:finished];
    self.backToView.hidden = NO;
  }];
}

@end

