//
//  CALayer+PXBarrage.m
//  PXBarrage
//
//  Created by WZH ZHANG on 2022/5/11.
//

#import "CALayer+PXBarrage.h"

@implementation CALayer (PXBarrage)

- (UIImage *)convertContentToImageWithSize:(CGSize)contentSize {
    UIGraphicsBeginImageContextWithOptions(contentSize, 0.0, [UIScreen mainScreen].scale);
    //self为需要截屏的UI控件 即通过改变此参数可以截取特定的UI控件
    [self renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
