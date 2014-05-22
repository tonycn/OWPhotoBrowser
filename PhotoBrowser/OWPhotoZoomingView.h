//
//  OWPhotoZoomingView.h
//  OpenWire
//
//  Created by Jianjun Wu on 3/25/14.
//  Copyright (c) 2014 Jianjun. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kOWPhotoZoomingViewSingleTapNotification;

@interface OWPhotoZoomingView : UIScrollView
@property (nonatomic, assign) BOOL loaded;
- (void)setPhotoImage:(UIImage *)image;
- (void)setLoadingProgress:(CGFloat)progress;

+ (void)setImageViewClass:(Class)imageViewClass;

@end
