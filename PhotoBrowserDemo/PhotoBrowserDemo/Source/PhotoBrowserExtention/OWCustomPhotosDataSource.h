//
//  OWCustomPhotosDataSource.h
//  OpenWire
//
//  Created by Jianjun Wu on 3/26/14.
//  Copyright (c) 2014 Jianjun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OWPhotosDataSource.h"

@interface OWCustomPhotosDataSource : NSObject <OWPhotosDataSource>
- (instancetype)initWithImageURLs:(NSArray *)imageURLs;
@property (nonatomic, strong) NSArray *thumbnailViews;
@end
