//
//  PXBarrageItemDescriptor.m
//  PXBarrage
//
//  Created by WZH ZHANG on 2022/5/11.
//

#import "PXBarrageItemDescriptor.h"
#import <UIKit/UIKit.h>
#import "PXBarrageHeader.h"

@implementation PXBarrageItemDescriptor

- (instancetype) initWithAttributedText:(NSAttributedString *)attributedText {
    self = [super init];
    if (self) {
        NSMutableAttributedString *attributeTextWithShadow = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor blackColor];
        shadow.shadowOffset = CGSizeMake(1, 1);
        shadow.shadowBlurRadius = 3;
        NSDictionary *attribute = @{NSShadowAttributeName : shadow};
        NSRange range = NSMakeRange(0, attributedText.length);
        [attributeTextWithShadow addAttributes:attribute range:range];
        self.attributedText = attributeTextWithShadow;
    }
    return self;
}

- (double)speed {
    if (_speed == 0) {
        _speed = kBarrageItemDefaultSpeed;
    }
    return _speed;
}

- (NSTimeInterval)remainDuration {
    if (_remainDuration == 0) {
        _remainDuration = kBarrageItemDefualtRemainDuration;
    }
    return _remainDuration;
}

@end
