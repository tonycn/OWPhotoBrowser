//
//  OWSimpleProgressHUD.m
//  OpenWire
//
//  Created by Jianjun Wu on 3/31/14.
//  Copyright (c) 2014 Jianjun. All rights reserved.
//

#import "OWSimpleProgressHUD.h"

@implementation OWSimpleProgressHUD

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.dismissWhenCompleted = YES;
    self.opacity = 0.f;
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void)showInView:(UIView *)view
{
  self.frame = view.bounds;
  [view addSubview:self];
  self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
  | UIViewAutoresizingFlexibleRightMargin
  | UIViewAutoresizingFlexibleTopMargin
  | UIViewAutoresizingFlexibleBottomMargin;
}

- (void)setProgress:(CGFloat)progress
{
  _progress = progress;
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  UIGraphicsPushContext(context);
  
  // Set background rect color
  if (self.backgroundColor) {
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
  } else {
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
  }

  // Center HUD
  CGRect allRect = self.bounds;
  CGSize boxSize = CGSizeMake(30.f, 30.f);
  CGPoint center = CGPointMake(roundf(allRect.size.width / 2),
                               roundf(allRect.size.height / 2));
  
  UIBezierPath *bgPath = [UIBezierPath bezierPath];
  [bgPath moveToPoint:CGPointMake(center.x, center.y - boxSize.height / 2)];
  [bgPath addArcWithCenter:center
                  radius:boxSize.width / 2
              startAngle:-M_PI_2
                endAngle:M_PI * 1.5
               clockwise:YES];
  [[UIColor colorWithWhite:0.f alpha:.8f] setStroke];
  bgPath.lineWidth = 5.f;
  [bgPath stroke];

  UIBezierPath *path = [UIBezierPath bezierPath];
  [path moveToPoint:CGPointMake(center.x, center.y - boxSize.height / 2)];
  [path addArcWithCenter:center
                  radius:boxSize.width / 2
              startAngle:-M_PI_2
                endAngle:M_PI * 2 * self.progress - M_PI_2
               clockwise:YES];
  path.lineWidth = 5.f;
  path.lineCapStyle = kCGLineCapRound;
  [[UIColor whiteColor] setStroke];
  [path stroke];
  
  UIGraphicsPopContext();
}

- (void)dismiss
{
  [self removeFromSuperview];
}

@end
