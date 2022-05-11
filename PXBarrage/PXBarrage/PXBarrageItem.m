//
//  PXBarrageItem.m
//  PXBarrage
//
//  Created by WZH ZHANG on 2022/5/11.
//

#import "PXBarrageItem.h"
#import "CALayer+PXBarrage.h"

#define kBarrageDefaultTextFontSize 14
#define kBarrageDefaultTextColor @"#FCFCFC"

@interface PXBarrageItem ()

@property (nonatomic,strong) UILabel *lbl;

@end

@implementation PXBarrageItem

- (instancetype) init {
    self = [super init];
    if (self) {
        [self addSubview:self.lbl];
    }
    return self;
}

- (void)setDescriptor:(PXBarrageItemDescriptor *)descriptor {
    _descriptor = descriptor;
    self.lbl.attributedText = descriptor.attributedText;
    [self.lbl sizeToFit];
    [self sizeToFit];
}

- (void)sizeToFit {
    CGFloat width = 0;
    CGFloat height = 0;
    for (CALayer *layer in self.layer.sublayers) {
        CGFloat maxX = CGRectGetMaxX(layer.frame);
        if (maxX > width) {
            width = maxX;
        }
        CGFloat maxY = CGRectGetMaxY(layer.frame);
        if (maxY > height) {
            height = maxY;
        }
    }
    if (width == 0 || height == 0) {
        CGImageRef content = (__bridge CGImageRef)self.layer.contents;
        if (content) {
            UIImage *image = [UIImage imageWithCGImage:content];
            width = image.size.width/[UIScreen mainScreen].scale;
            height = image.size.height/[UIScreen mainScreen].scale;
        }
    }
    self.bounds = CGRectMake(0.0, 0.0, width, height);
}

- (void)clearContents {
    self.layer.contents = nil;
}

- (void)updateSubviewsData {
    if (self.lbl.superview == nil) {
        [self addSubview:self.lbl];
    }
    self.lbl.attributedText = self.descriptor.attributedText;
}

- (void)prepareForReuse {
    [self.layer removeAllAnimations];
    self.descriptor = nil;
    self.isInterrupted = NO;
    self.toast = nil;
    self.walkingAnimation = nil;
}

- (void)layoutContentSubviews {
    if (!self.descriptor.attributedText) {
        return;
    }
    CGRect rect = [self.descriptor.attributedText.string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:[self.descriptor.attributedText attributesAtIndex:0 effectiveRange:NULL] context:nil];
    if (rect.size.width > ([UIScreen mainScreen].bounds.size.width * 0.8)) {
        CGRect aNewrect = rect;
        aNewrect.size.width = [UIScreen mainScreen].bounds.size.width * 0.8;
        self.lbl.frame = aNewrect;
    }else {
        self.lbl.frame = rect;
    }
}

- (void)convertContentToImage {
    UIImage *contentImage = [self.layer convertContentToImageWithSize:_lbl.frame.size];
    [self.layer setContents:(__bridge id)contentImage.CGImage];
}

- (void)removeSubViewsAndSublayers {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    for (CALayer *layer in self.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
}

- (void)addBarrageAnimationWithDelegate:(id<CAAnimationDelegate>)animationDelegate {
    if (!self.superview) {
        return;
    }
    self.walkingAnimation.delegate =  animationDelegate;
    [self.layer addAnimation:self.walkingAnimation forKey:kBarrageAnimationKey];
}

- (CAKeyframeAnimation *)walkingAnimation {
    if (!self.superview) {
        return nil;
    }
    if (!_walkingAnimation) {
        CGPoint startCenter = CGPointMake(CGRectGetMaxX(self.superview.bounds) + CGRectGetWidth(self.bounds)/2, self.center.y);
        CGPoint endCenter = CGPointMake(-(CGRectGetWidth(self.bounds)/2), self.center.y);
        CGFloat distanceX = fabs(startCenter.x - endCenter.x);
        CGFloat animationDuration = distanceX / self.descriptor.speed;
        _walkingAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        _walkingAnimation.values = @[[NSValue valueWithCGPoint:startCenter], [NSValue valueWithCGPoint:endCenter]];
        _walkingAnimation.keyTimes = @[@(0.0), @(1.0)];
        _walkingAnimation.duration = animationDuration;
        _walkingAnimation.repeatCount = 1;
        _walkingAnimation.removedOnCompletion = NO;
        _walkingAnimation.fillMode = kCAFillModeForwards;
    }
    return _walkingAnimation;
}

- (CABasicAnimation *)hidingAnimation {
    if (!self.superview) {
        return nil;
    }
    if (!_hidingAnimation) {
        _hidingAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        _hidingAnimation.fromValue = @1;
        _hidingAnimation.toValue = @0;
        _hidingAnimation.duration = 0.25;
        _hidingAnimation.removedOnCompletion = NO;
        _hidingAnimation.fillMode = kCAFillModeForwards;
    }
    return _hidingAnimation;
}

- (CABasicAnimation *)showingAnimation {
    if (!self.superview) {
        return nil;
    }
    if (!_showingAnimation) {
        _showingAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        _showingAnimation.fromValue = @0;
        _showingAnimation.toValue = @1;
        _showingAnimation.duration = 0.25;
        _showingAnimation.removedOnCompletion = NO;
        _showingAnimation.fillMode = kCAFillModeForwards;
    }
    //加个0.1秒的延迟，这样能让toast消失时，动画更自然
    _showingAnimation.beginTime = CACurrentMediaTime() + 0.1;
    return _showingAnimation;
}

#pragma mark - lazy load

- (UILabel *)lbl {
    if (!_lbl) {
        _lbl = [[UILabel alloc] init];
        _lbl.font = [UIFont systemFontOfSize:kBarrageDefaultTextFontSize];
    }
    return  _lbl;
}

@end
