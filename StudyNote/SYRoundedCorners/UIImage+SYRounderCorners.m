
//
//  UIImage+SY.m
//  圆角Demo
//
//  Created by Kellen on 2017/2/13.
//  Copyright © 2017年 ShenYan. All rights reserved.
//

#import "UIImage+SYRounderCorners.h"
@implementation UIImage (SYRounderCorners)

- (void)sy_setRounderCornersSize:(CGSize)size completed:(SYRounderCornersCompletedBlock)completedBlock {
    [self sy_setCornersRadius:MIN(size.width, size.height)/2 size:size completed:completedBlock];
}

- (void)sy_setCornersRadius:(CGFloat)cornerRadius size:(CGSize)size completed:(SYRounderCornersCompletedBlock)completedBlock {
    [self sy_setCornersRadius:cornerRadius size:size borderColor:nil borderWidth:0 completed:completedBlock];
}

- (void)sy_setCornersRadius:(CGFloat)cornerRadius size:(CGSize)size borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth completed:(SYRounderCornersCompletedBlock)completedBlock {
    [self sy_setCornersRadius:SYCornersRadiusMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius) size:size borderColor:borderColor borderWidth:borderWidth contentMode:UIViewContentModeScaleToFill completed:completedBlock];
}

- (void)sy_setCornersRadius:(SYCornersRadius)cornerRadius size:(CGSize)size borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth contentMode:(UIViewContentMode)contentMode completed:(SYRounderCornersCompletedBlock)completedBlock {
    [UIImage sy_setCornersRadius:cornerRadius image:self size:size borderColor:borderColor borderWidth:borderWidth backgroundColor:nil withContentMode:contentMode completed:completedBlock];
}

+ (void)sy_setCornersRadius:(SYCornersRadius)cornersRadius
                       size:(CGSize)size
                borderColor:(UIColor *)borderColor
                borderWidth:(CGFloat)borderWidth
            backgroundColor:(UIColor *)backgroundColor
                  completed:(SYRounderCornersCompletedBlock)completedBlock {
    [UIImage sy_setCornersRadius:cornersRadius image:nil size:size borderColor:borderColor borderWidth:borderWidth backgroundColor:backgroundColor withContentMode:UIViewContentModeScaleToFill completed:completedBlock];
}

+ (void)sy_setCornersRadius:(SYCornersRadius)cornersRadius
                      image:(UIImage *)image
                       size:(CGSize)size
                borderColor:(UIColor *)borderColor
                borderWidth:(CGFloat)borderWidth
            backgroundColor:(UIColor *)backgroundColor
            withContentMode:(UIViewContentMode)contentMode
                  completed:(SYRounderCornersCompletedBlock)completedBlock {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *currentImage = [UIImage sy_setCornersRadius:cornersRadius image:image size:size borderColor:borderColor borderWidth:borderWidth backgroundColor:backgroundColor withContentMode:contentMode];
        dispatch_async(dispatch_get_main_queue(), ^{
            completedBlock(currentImage);
        });
    });
}

+ (UIImage *)sy_setCornersRadius:(SYCornersRadius)cornersRadius
                           image:(UIImage *)image
                            size:(CGSize)size
                     borderColor:(UIColor *)borderColor
                     borderWidth:(CGFloat)borderWidth
                 backgroundColor:(UIColor *)backgroundColor
                 withContentMode:(UIViewContentMode)contentMode {
    if (!backgroundColor) {backgroundColor = [UIColor whiteColor];}
    
    if (image) {
        image = [image _scaleToSize:CGSizeMake(size.width, size.height) contentMode:contentMode backgroundColor:backgroundColor];
    } else {
        image = [UIImage _imageWithColor:backgroundColor];
    }
    
    UIGraphicsBeginImageContextWithOptions(size, YES, UIScreen.mainScreen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -rect.size.height);
    CGFloat height = size.height;
    CGFloat width = size.width;
    cornersRadius = [self _transformationSYCornersRadius:cornersRadius size:size borderWidth:borderWidth];

    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextFillRect(context, rect);
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:CGPointMake(width - cornersRadius.bottomRightCornersRadius, height - cornersRadius.bottomRightCornersRadius) radius:cornersRadius.bottomRightCornersRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addArcWithCenter:CGPointMake(cornersRadius.bottomLeftCornersRadius, height - cornersRadius.bottomLeftCornersRadius) radius:cornersRadius.bottomLeftCornersRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addArcWithCenter:CGPointMake(cornersRadius.topLeftCornersRadius, cornersRadius.topLeftCornersRadius) radius:cornersRadius.topLeftCornersRadius startAngle:M_PI endAngle:3.0 * M_PI_2 clockwise:YES];
    [path addArcWithCenter:CGPointMake(width - cornersRadius.topRightCornersRadius, cornersRadius.topRightCornersRadius) radius:cornersRadius.topRightCornersRadius startAngle:3.0 * M_PI_2 endAngle:2.0 * M_PI clockwise:YES];
    [path closePath];
    
    [path addClip];
    CGContextDrawImage(context, rect, image.CGImage);
    if (borderWidth > 0) {
        if (!borderColor) {borderColor = [UIColor whiteColor];}
        path.lineWidth = borderWidth;
        [borderColor setStroke];
        [path stroke];
    }
    
    UIImage *currentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return currentImage;
}

#pragma mark - Private Helpers
+ (SYCornersRadius)_transformationSYCornersRadius:(SYCornersRadius)cornersRadius size:(CGSize)size borderWidth:(CGFloat)borderWidth {
    cornersRadius.topLeftCornersRadius = _minimum(size.width, size.height, cornersRadius.topLeftCornersRadius);
    cornersRadius.topRightCornersRadius = _minimum(size.width - cornersRadius.topLeftCornersRadius, size.height, cornersRadius.topRightCornersRadius);
    cornersRadius.bottomLeftCornersRadius = _minimum(size.width, size.height - cornersRadius.topLeftCornersRadius, cornersRadius.bottomLeftCornersRadius);
    cornersRadius.bottomRightCornersRadius = _minimum(size.width - cornersRadius.bottomLeftCornersRadius, size.height - cornersRadius.topRightCornersRadius, cornersRadius.bottomRightCornersRadius);
    return cornersRadius;
}

static inline CGFloat _minimum(CGFloat a, CGFloat b, CGFloat c) {
    CGFloat minimum = MIN(MIN(a, b), c);
    return MAX(minimum, 0);
}

- (UIImage *)_scaleToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode backgroundColor:(UIColor *)backgroundColor {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, YES, UIScreen.mainScreen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context, kCGPathFill);
    [self drawInRect:[self _convertRect:rect contentMode:contentMode]];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (CGRect)_convertRect:(CGRect)rect contentMode:(UIViewContentMode)contentMode {
    CGSize size = self.size;
    rect = CGRectStandardize(rect);
    size.width = size.width < 0 ? -size.width : size.width;
    size.height = size.height < 0 ? -size.height : size.height;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    switch (contentMode) {
        case UIViewContentModeRedraw:
        case UIViewContentModeScaleAspectFit:
        case UIViewContentModeScaleAspectFill: {
            if (rect.size.width < 0.01 || rect.size.height < 0.01 ||
                size.width < 0.01 || size.height < 0.01) {
                rect.origin = center;
                rect.size = CGSizeZero;
            } else {
                CGFloat scale;
                if (contentMode == UIViewContentModeScaleAspectFill) {
                    if (size.width / size.height < rect.size.width / rect.size.height) {
                        scale = rect.size.width / size.width;
                    } else {
                        scale = rect.size.height / size.height;
                    }
                } else {
                    if (size.width / size.height < rect.size.width / rect.size.height) {
                        scale = rect.size.height / size.height;
                    } else {
                        scale = rect.size.width / size.width;
                    }
                }
                size.width *= scale;
                size.height *= scale;
                rect.size = size;
                rect.origin = CGPointMake(center.x - size.width * 0.5, center.y - size.height * 0.5);
            }
        } break;
        case UIViewContentModeCenter: {
            rect.size = size;
            rect.origin = CGPointMake(center.x - size.width * 0.5, center.y - size.height * 0.5);
        } break;
        case UIViewContentModeTop: {
            rect.origin.x = center.x - size.width * 0.5;
            rect.size = size;
        } break;
        case UIViewContentModeBottom: {
            rect.origin.x = center.x - size.width * 0.5;
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeLeft: {
            rect.origin.y = center.y - size.height * 0.5;
            rect.size = size;
        } break;
        case UIViewContentModeRight: {
            rect.origin.y = center.y - size.height * 0.5;
            rect.origin.x += rect.size.width - size.width;
            rect.size = size;
        } break;
        case UIViewContentModeTopLeft: {
            rect.size = size;
        } break;
        case UIViewContentModeTopRight: {
            rect.origin.x += rect.size.width - size.width;
            rect.size = size;
        } break;
        case UIViewContentModeBottomLeft: {
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeBottomRight: {
            rect.origin.x += rect.size.width - size.width;
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeScaleToFill:
        default: {
            rect = rect;
        }
    }
    return rect;
}

+ (UIImage *)_imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



@end
