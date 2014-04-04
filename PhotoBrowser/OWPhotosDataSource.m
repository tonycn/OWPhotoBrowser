//
//  OWPhotosDataSource.m
//  OpenWire
//
//  Created by Jianjun Wu on 3/25/14.
//  Copyright (c) 2014 Jianjun. All rights reserved.
//

#import "OWPhotosDataSource.h"

@interface OWSimplePhotosDataSource ()
@property (nonatomic, strong) NSArray *images;
@end

@implementation OWSimplePhotosDataSource
- (instancetype)initWithImages:(NSArray *)images
{
  NSParameterAssert(images && images.count > 0);
  self = [super init];
  if (self) {
    self.images = images;
  }
  return self;
}

- (void)loadImageAtIndex:(NSUInteger)index
                progress:(PhotoLoadProgress)progress
                complete:(PhotoLoadComplete)complete
{
  NSParameterAssert(index < self.images.count);
  NSParameterAssert(complete);
  if (progress) {
    progress(1.f);
  }
  complete(self.images[index], nil);
}

- (BOOL)imageExistedInCacheAtIndex:(NSUInteger)index
{
  return YES;
}

- (NSUInteger)count
{
  return self.images.count;
}

- (void)cancelAll
{
}

@end
