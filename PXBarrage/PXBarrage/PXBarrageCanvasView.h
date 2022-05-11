//
//  PXBarrageCanvasView.h
//  PXBarrage
//
//  Created by WZH ZHANG on 2022/5/11.
//

#import <UIKit/UIKit.h>
#import "PXBarrageItem.h"
#import "PXBarrageItemDescriptor.h"

@class PXBarrageCanvasView;
@protocol PXBarrageCanvasViewDelegate <NSObject>
@optional;
- (void)barrageCanvasView:(PXBarrageCanvasView *_Nullable)barrageCanvasView didInteract:(PXBarrageItem *_Nullable)barrageItem ;

- (void)barrageCanvasView:(PXBarrageCanvasView *_Nullable)barrageCanvasView itemDidEndInteract:(PXBarrageItem *_Nullable)barrageItem ;

@end

NS_ASSUME_NONNULL_BEGIN

@class  PXBarrageTrack;
@interface PXBarrageCanvasView : UIView

@property (nonatomic,assign) PXBarrageStatus status;
@property (nonatomic,weak) id<PXBarrageCanvasViewDelegate> delegate;

@property (nonatomic,assign) PXBarrageInteractType interactType;  //打断类型

- (void)setTracksNumber:(NSUInteger)number startPositionY:(CGFloat)positonY spacing:(CGFloat)spacing;
 
- (void)start;
- (void)stop;
- (void)pause;
- (void)resume;
- (void)fireBarrageWithDescriptor:(PXBarrageItemDescriptor *)descritor;

- (void)endInteractBarrageItemAndCancelPrevious:(PXBarrageItem *)item;

@end



NS_ASSUME_NONNULL_END
