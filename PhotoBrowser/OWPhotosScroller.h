//
//  OWPhotosScroller.h
//  OpenWire
//
//  Created by Jianjun Wu on 3/25/14.
//  Copyright (c) 2014 Jianjun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OWPhotoZoomingView.h"

@protocol OWPhotosScrollerDelegate <NSObject>

- (void)photosScrollerDidScrollToPage:(NSUInteger)pageNO
                            photoView:(OWPhotoZoomingView *)view;

@end

@interface OWPhotosScroller : UIView
@property (nonatomic, weak) id<OWPhotosScrollerDelegate> delegate;
- (void)setNumberOfPages:(NSInteger)num;
- (void)setCurrentPage:(NSInteger)currentPage defaultImage:(UIImage *)img;

@end
