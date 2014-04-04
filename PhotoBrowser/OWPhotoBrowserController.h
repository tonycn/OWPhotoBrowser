//
//  OWPhotoBrowserController.h
//  OpenWire
//
//  Created by Jianjun Wu on 3/25/14.
//  Copyright (c) 2014 Jianjun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OWPhotosDataSource.h"

@interface OWPhotoBrowserController : UIViewController
- (id)initWithDataSource:(id<OWPhotosDataSource>)photoDataSource;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UIImageView *fromView;
@end
