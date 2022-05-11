//
//  PXBarrageItemDescriptor.h
//  PXBarrage
//
//  Created by WZH ZHANG on 2022/5/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PXBarrageHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface PXBarrageItemDescriptor : NSObject

@property (nonatomic,strong) NSAttributedString *attributedText;

@property (nonatomic,assign) double speed;

@property (nonatomic,assign) NSTimeInterval remainDuration;  //被点击后，保持被打断状态的时间

@property (nonatomic,weak) id customObject;  //给记录一个对应对象，可能后期有用，使用weak，避免引用

- (instancetype) initWithAttributedText:(NSAttributedString *)attributedText;

@end

NS_ASSUME_NONNULL_END
