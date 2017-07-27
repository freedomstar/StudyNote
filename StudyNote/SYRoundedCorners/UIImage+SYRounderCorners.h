//
//  UIImage+SY.h
//  圆角Demo
//
//  Created by Kellen on 2017/2/13.
//  Copyright © 2017年 ShenYan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct _SYCornersRadius {
    CGFloat topLeftCornersRadius;
    CGFloat topRightCornersRadius;
    CGFloat bottomLeftCornersRadius;
    CGFloat bottomRightCornersRadius;
} SYCornersRadius;

static inline SYCornersRadius SYCornersRadiusMake(CGFloat topLeftCornersRadius, CGFloat topRightCornersRadius, CGFloat bottomLeftCornersRadius, CGFloat bottomRightCornersRadius) {
    SYCornersRadius cornersRadius;
    cornersRadius.topLeftCornersRadius = topLeftCornersRadius;
    cornersRadius.topRightCornersRadius = topRightCornersRadius;
    cornersRadius.bottomLeftCornersRadius = bottomLeftCornersRadius;
    cornersRadius.bottomRightCornersRadius = bottomRightCornersRadius;
    return cornersRadius;
}

static inline NSString * NSStringFromSYCornersRadius(SYCornersRadius cornersRadius) {
    return [NSString stringWithFormat:@"{%.2f, %.2f, %.2f, %.2f}", cornersRadius.topLeftCornersRadius, cornersRadius.topRightCornersRadius, cornersRadius.bottomLeftCornersRadius, cornersRadius.bottomRightCornersRadius];
}

typedef void(^SYRounderCornersCompletedBlock)(UIImage *image);

@interface UIImage (SYRounderCorners)

- (void)sy_setRounderCornersSize:(CGSize)size completed:(SYRounderCornersCompletedBlock)completedBlock;
- (void)sy_setCornersRadius:(CGFloat)cornerRadius size:(CGSize)size completed:(SYRounderCornersCompletedBlock)completedBlock;
- (void)sy_setCornersRadius:(CGFloat)cornerRadius
                       size:(CGSize)size
                borderColor:(UIColor *)borderColor
                borderWidth:(CGFloat)borderWidth
                  completed:(SYRounderCornersCompletedBlock)completedBlock;
- (void)sy_setCornersRadius:(SYCornersRadius)cornerRadius
                      size:(CGSize)size
               borderColor:(UIColor *)borderColor
               borderWidth:(CGFloat)borderWidth
               contentMode:(UIViewContentMode)contentMode
                 completed:(SYRounderCornersCompletedBlock)completedBlock;

+ (void)sy_setCornersRadius:(SYCornersRadius)cornersRadius
                       size:(CGSize)size
                borderColor:(UIColor *)borderColor
                borderWidth:(CGFloat)borderWidth
            backgroundColor:(UIColor *)backgroundColor
                  completed:(SYRounderCornersCompletedBlock)completedBlock;
+ (void)sy_setCornersRadius:(SYCornersRadius)_cornersRadius
                      image:(UIImage *)_image
                       size:(CGSize)size
                borderColor:(UIColor *)borderColor
                borderWidth:(CGFloat)borderWidth
            backgroundColor:(UIColor *)_backgroundColor
            withContentMode:(UIViewContentMode)contentMode
                  completed:(SYRounderCornersCompletedBlock)completedBlock;
@end



