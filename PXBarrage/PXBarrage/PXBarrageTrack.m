//
//  PXBarrageTrack.m
//  PXBarrage
//
//  Created by WZH ZHANG on 2022/5/11.
//

#import "PXBarrageTrack.h"
#import "PXBarrageItem.h"
#import "PXBarrageHeader.h"

@interface PXBarrageTrack ()

@end

@implementation PXBarrageTrack

- (instancetype) initWithPositonY:(CGFloat)postionY {
    self = [super init];
    if (self) {
        self.positonY = postionY;
        _animatingItems = [NSMutableArray array];
    }
    return self;
}

#pragma mark - func

- (void)becomeAvailable {
    if ([self.delegate respondsToSelector:@selector(barrageTrackDidBecomeAvailable:)]) {
        [self.delegate barrageTrackDidBecomeAvailable:self];
    }
}

- (void)resetTrackAvailableTime {
    self.availableTimeForNext = CACurrentMediaTime();
}

- (NSArray <PXBarrageItem *> *)itemsStartAtItem:(PXBarrageItem *)item {
    int index = (int)[self.animatingItems indexOfObject:item];
    NSMutableArray *mArr = [NSMutableArray array];
    for (int i = index ; i < item.track.animatingItems.count ; i ++) {
        [mArr addObject:[self.animatingItems objectAtIndex:i]];
    }
    return [NSArray arrayWithArray:mArr];
}

#pragma mark - timer

- (void)startTimer {
    /*
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:timeGap target:self selector:@selector(becomeAvailable) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }*/
    
    NSTimeInterval timeGap = self.availableTimeForNext - CACurrentMediaTime();
    [self performSelector:@selector(becomeAvailable) withObject:nil afterDelay:timeGap];
}

/*
- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}*/

#pragma mark - getter & setter

- (BOOL)isAvailable {
    BOOL okForNext = self.availableTimeForNext < CACurrentMediaTime();
    //加上self.containPausedItem。当前轨道存在被打断暂停的弹幕，暂停该轨道后续的弹幕
    return (okForNext && !self.paused);
}

- (void)setPaused:(BOOL)paused {
    _paused = paused;
    if (!_paused) {
        //中断结束
        PXBarrageItem *item = self.animatingItems.lastObject;
        if (item) {
            //找到中断的弹幕item，计算该轨道显示后续弹幕的可用时间
            CGRect rect = item.layer.presentationLayer.frame;
            NSTimeInterval time = (CGRectGetMaxX(rect) - [UIScreen mainScreen].bounds.size.width + kBarrageItemsSpacingMin)  / item.descriptor.speed;
            self.availableTimeForNext = CACurrentMediaTime() + time;
//            [self startTimer];
        }
    }
}

- (void)setAvailableTimeForNext:(NSTimeInterval)availableTimeForNext {
    _availableTimeForNext = availableTimeForNext;
    [self startTimer];
}

@end

