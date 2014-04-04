//
//  OWSimpleProgressHUD.h
//  OpenWire
//
//  Created by Jianjun Wu on 3/31/14.
//  Copyright (c) 2014 Jianjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWSimpleProgressHUD : UIView
/*
 @property dismissWhenCompleted default is YES;
 */
@property (nonatomic, assign) BOOL dismissWhenCompleted;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat opacity;
- (void)showInView:(UIView *)view;
- (void)dismiss;
@end
