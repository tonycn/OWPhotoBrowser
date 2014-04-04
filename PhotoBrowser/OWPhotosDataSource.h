//
//  OWPhotosDataSource.h
//  OpenWire
//
//  Created by Jianjun Wu on 3/25/14.
//  Copyright (c) 2014 Jianjun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PhotoLoadProgress)(CGFloat percentage);
typedef void (^PhotoLoadComplete)(UIImage *image, NSError *error);

@protocol OWPhotosDataSource <NSObject>
- (void)loadImageAtIndex:(NSUInteger)index
                progress:(PhotoLoadProgress)progress
                complete:(PhotoLoadComplete)complete;
- (BOOL)imageExistedInCacheAtIndex:(NSUInteger)index;
- (NSUInteger)count;
- (void)cancelAll;
@optional
- (UIImage *)failureImage;
- (UIImageView *)thumbnailImageViewAtIndex:(NSInteger)photoIndex;
@end

@interface OWSimplePhotosDataSource : NSObject <OWPhotosDataSource>
- (instancetype)initWithImages:(NSArray *)images;
@end
