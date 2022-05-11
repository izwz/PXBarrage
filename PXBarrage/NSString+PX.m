//
//  NSString+PX.m
//  PXBarrage
//
//  Created by WZH ZHANG on 2022/5/11.
//

#import "NSString+PX.h"

@implementation NSString (PX)

+ (BOOL)px_isNilOrEmpty:(NSString *)value {
    if (value && ![value isEqual:[NSNull null]] && [value isKindOfClass:[NSString class]]) {
        NSCharacterSet *chracter = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimValue = [value stringByTrimmingCharactersInSet:chracter];
        if (trimValue.length > 0) {
            return NO;
        }
        return YES;
    }
    return YES;
}

@end
