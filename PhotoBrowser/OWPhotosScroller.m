//
//  OWPhotosScroller.m
//  OpenWire
//
//  Created by Jianjun Wu on 3/25/14.
//  Copyright (c) 2014 Jianjun. All rights reserved.
//

#import "OWPhotosScroller.h"

static const CGFloat kPageGap = 10.f;

@interface OWPhotosScroller () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *pages;
@property (nonatomic, strong) UIPageControl *pageIndicator;
@property (nonatomic, strong) NSMutableDictionary *pageViews;
@end

@implementation OWPhotosScroller

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor blackColor];
    CGRect rect = self.bounds;
    rect.size.width += kPageGap;
    self.pages = [[UIScrollView alloc] initWithFrame:rect];
    self.pages.pagingEnabled = YES;
    self.pages.delegate = self;
    self.pageIndicator = [[UIPageControl alloc] initWithFrame:(CGRect){0.f, 0.f, 0.f, 40.f}];
    self.pageIndicator.userInteractionEnabled = YES;
    self.pageViews = [NSMutableDictionary dictionary];
    
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
      [weakSelf memoryWarningDidReceive];
    }];
    [self addSubview:self.pages];
    [self addSubview:self.pageIndicator];
    [self setNeedsLayout];
  }
  return self;
}

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
  self.pageIndicator.numberOfPages = numberOfPages;
  CGSize size = self.bounds.size;
  NSAssert(size.width > 0, @"should set frame before");
  size.width = (kPageGap + size.width) * numberOfPages;
  self.pages.contentSize = size;
}

- (void)setCurrentPage:(NSInteger)currentPage defaultImage:(UIImage *)img
{
  [self changeCurrentPageTo:currentPage defaultImage:img];
}

- (void)layoutSubviews
{
  CGRect rect = self.pageIndicator.frame;
  rect.size.width = self.bounds.size.width;
  rect.origin.y = self.bounds.size.height - rect.size.height;
  self.pageIndicator.frame = rect;
  
  self.pages.autoresizingMask = ~UIViewAutoresizingNone;
  self.pageIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

  rect = self.bounds;
  rect.size.width += kPageGap;
  self.pages.frame = rect;

  CGSize size = self.bounds.size;
  size.width = (kPageGap + size.width) * self.pageIndicator.numberOfPages;
  self.pages.contentSize = size;
  
  [self.pageViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, OWPhotoZoomingView *view, BOOL *stop) {
    CGRect rect = self.pages.bounds;
    NSInteger curpage = key.integerValue;
    rect.size.width = self.frame.size.width;
    rect.origin.x = curpage * (rect.size.width + kPageGap);
    view.frame = rect;
    view.zoomScale = 1.0f;
    [view reLayoutImageView];
  }];
  [self changeCurrentPageTo:self.pageIndicator.currentPage
               defaultImage:nil];
}

- (void)updatePageControlIndicator
{
  NSUInteger pageIndex = self.pages.contentOffset.x / self.pages.bounds.size.width;
  [self changeCurrentPageTo:pageIndex defaultImage:nil];
}

- (void)changeCurrentPageTo:(NSInteger)curpage defaultImage:(UIImage *)img
{
  self.pageIndicator.currentPage = curpage;
  CGRect rect = self.pages.bounds;
  self.pages.contentOffset = CGPointMake(curpage * rect.size.width, 0.f);
  OWPhotoZoomingView *photoView = [self.pageViews objectForKey:@(curpage)];
  if (photoView == nil) {
    photoView = [[OWPhotoZoomingView alloc] init];
    [self.pageViews setObject:photoView forKey:@(curpage)];
  }
  rect.size.width = self.frame.size.width;
  rect.origin.x = curpage * (rect.size.width + kPageGap);
  photoView.frame = rect;
  [self.pages addSubview:photoView];
  if (!photoView.loaded) {
    [photoView setPhotoImage:img];
  }
  [self.delegate photosScrollerDidScrollToPage:curpage photoView:photoView];
}

- (void)memoryWarningDidReceive
{
  NSInteger curPage = self.pageIndicator.currentPage;
  NSArray *keys = [self.pageViews allKeys];
  for (NSNumber *pageNO in keys) {
    if (pageNO.integerValue < curPage - 1 || pageNO.integerValue > curPage + 1) {
      [[self.pageViews objectForKey:pageNO] removeFromSuperview];
      [self.pageViews removeObjectForKey:pageNO];
    }
  }
}

#pragma mark - delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
  if (!decelerate) {
    [self updatePageControlIndicator];
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  [self updatePageControlIndicator];
}

@end
