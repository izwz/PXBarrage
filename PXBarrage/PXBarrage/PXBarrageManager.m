//
//  PXBarrageManager.m
//  PXBarrage
//
//  Created by WZH ZHANG on 2022/5/11.
//

#import "PXBarrageManager.h"
#import "PXBarrageItemDescriptor.h"


@implementation PXBarrageManager

- (void)dealloc {
    [self.barrageCanvasView stop];
    [self.barrageCanvasView removeFromSuperview];
}

- (instancetype) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setTracksNumber:(NSUInteger)number startPositionY:(CGFloat)positonY spacing:(CGFloat)spacing {
    [self stop];
    [self.barrageCanvasView setTracksNumber:number startPositionY:positonY spacing:spacing];
}

- (void)start {
    [self.barrageCanvasView start];
}

- (void)stop {
    [self.barrageCanvasView stop];
}

- (void)pause {
    [self.barrageCanvasView pause];
}

- (void)resume {
    [self.barrageCanvasView resume];
}

- (void)fireBarrage:(PXBarrageItemDescriptor *)descriptor {
    if (self.barrageCanvasView.status == PXBarrageStatusStarted ) {
        [self.barrageCanvasView fireBarrageWithDescriptor:descriptor];
    }
}

- (PXBarrageCanvasView *)barrageCanvasView {
    if (!_barrageCanvasView) {
        _barrageCanvasView = [[PXBarrageCanvasView alloc] init];
    }
    return  _barrageCanvasView;
}

@end
