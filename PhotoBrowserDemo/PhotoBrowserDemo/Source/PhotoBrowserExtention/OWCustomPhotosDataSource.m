//
//  OWCustomPhotosDataSource.m
//  OpenWire
//
//  Created by Jianjun Wu on 3/26/14.
//  Copyright (c) 2014 Jianjun. All rights reserved.
//

#import "OWCustomPhotosDataSource.h"

#import "OWSimpleURLConnection.h"

@interface OWCustomPhotosDataSource ()
@property (nonatomic, strong) NSArray *imageURLs;
@property (nonatomic, strong) NSMutableDictionary *loadingConnections;
@end

@implementation OWCustomPhotosDataSource
- (instancetype)initWithImageURLs:(NSArray *)imageURLs
{
  NSParameterAssert(imageURLs && imageURLs.count > 0);
  self = [super init];
  if (self) {
    self.imageURLs = imageURLs;
    self.loadingConnections = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)dealloc
{
  [self cancelAll];
}

- (void)loadImageAtIndex:(NSUInteger)index
                progress:(PhotoLoadProgress)progress
                complete:(PhotoLoadComplete)complete
{
  NSParameterAssert(index < self.imageURLs.count);
  NSParameterAssert(complete);
  NSURL *url = [NSURL URLWithString:self.imageURLs[index]];
  if ([self.loadingConnections objectForKey:url]) {
    return;
  }
  NSURLRequest *req = [NSURLRequest requestWithURL:url];

  __weak typeof(self) weakSelf = self;
  __block OWSimpleURLConnection * connection = nil;
  connection = [OWSimpleURLConnection OW_asyncRequest:req progressHandler:^(NSUInteger totalBytes, NSUInteger receivedBytes) {
    if (progress) {
      progress(receivedBytes * 1.f / totalBytes);
    }
  } completionHandler:^(OWSimpleURLConnection *conn, NSData *data, NSError *connectionError) {
    if (connectionError == nil && conn.httpResponse.statusCode == 200) {
      connection = conn;
      complete([[UIImage alloc] initWithData:data scale:[UIScreen mainScreen].scale], connectionError);
    }
    [weakSelf.loadingConnections removeObjectForKey:url];
  }];
  [connection start];
  progress(0.f);
  [self.loadingConnections setObject:connection forKey:url];
}

- (BOOL)imageExistedInCacheAtIndex:(NSUInteger)index
{
  return NO;
}

- (NSUInteger)count
{
  return self.imageURLs.count;
}

- (void)cancelAll
{
  for (OWSimpleURLConnection *conn in self.loadingConnections.allValues) {
    [conn cancel];
  }
  [self.loadingConnections removeAllObjects];
}

- (UIImageView *)thumbnailImageViewAtIndex:(NSInteger)photoIndex
{
  return [self.thumbnailViews objectAtIndex:photoIndex];
}

@end
