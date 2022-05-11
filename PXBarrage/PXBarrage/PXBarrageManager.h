//
//  PXBarrageManager.h
//  PXBarrage
//
//  Created by WZH ZHANG on 2022/5/11.
//

#import <Foundation/Foundation.h>
#import "PXBarrageCanvasView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PXBarrageManager : NSObject

@property (nonatomic,strong)PXBarrageCanvasView *barrageCanvasView;


/// 设置弹幕轨道
/// @param number 轨道数量
/// @param positonY 第一条轨道的y轴坐标
/// @param spacing 两条轨道的间隔（y轴方向）
- (void)setTracksNumber:(NSUInteger)number startPositionY:(CGFloat)positonY spacing:(CGFloat)spacing;

- (void)start;
- (void)stop;
- (void)pause;
- (void)resume;
- (void)fireBarrage:(PXBarrageItemDescriptor *)descriptor;


@end

NS_ASSUME_NONNULL_END
