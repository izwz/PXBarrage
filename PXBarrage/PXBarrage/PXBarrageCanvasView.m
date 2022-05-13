//
//  PXBarrageCanvasView.h
//  PXBarrage
//
//  Created by WZH ZHANG on 2022/5/11.
//

#import "PXBarrageCanvasView.h"
#import "PXBarrageHeader.h"
#import "PXBarrageTrack.h"

@interface PXBarrageCanvasView ()<CAAnimationDelegate,PXBarrageTrackDelegate>

@property (nonatomic,strong) NSMutableArray  <PXBarrageTrack *> *tracks;
@property (nonatomic,strong) NSMutableArray <PXBarrageItem *> * reusableItems; //可复用的弹幕
@property (nonatomic,strong) NSMutableArray <PXBarrageItem *> * animatingItems; // 正在显示的弹幕
@property (nonatomic,strong) NSMutableArray <PXBarrageItem *> * jammedItems;  //被阻塞的弹幕

@property (nonatomic,weak) PXBarrageItem *currentInteractItem;

@end

@implementation PXBarrageCanvasView

#pragma mark - init

- (instancetype) init {
    self = [super init];
    if (self) {
        self.status = PXBarrageStatusStopped;
        self.tracks = [NSMutableArray array];
        self.reusableItems = [NSMutableArray array];
        self.animatingItems = [NSMutableArray array];
        self.jammedItems = [NSMutableArray array];
    }
    return self;
}

- (void)setTracksNumber:(NSUInteger)number startPositionY:(CGFloat)positonY spacing:(CGFloat)spacing {
    [self.tracks removeAllObjects];
    CGFloat y = positonY;
    for (int i = 0; i < number; i ++) {
        PXBarrageTrack *track = [[PXBarrageTrack alloc] initWithPositonY:y];
        track.delegate = self;
        track.index = i;
        [self.tracks addObject:track];
        y += spacing;
    }
}

#pragma mark - Barage Control

- (void)start {
    if (self.status != PXBarrageStatusStarted) {
        self.status = PXBarrageStatusStarted;
    }
}

- (void)stop {
    if (self.status != PXBarrageStatusStopped) {
        self.status = PXBarrageStatusStopped;
        
        if (self.interactType == PXBarrageInteractTypePause) {
            if (self.currentInteractItem) {
                [self endInteractBarrageItemAndCancelPrevious:self.currentInteractItem];
            }
        }
        
        for (PXBarrageItem *item in self.animatingItems) {
            CFTimeInterval pausedTime = [item.layer convertTime:CACurrentMediaTime() fromLayer:nil];
            item.layer.speed = 0.0;
            item.layer.timeOffset = pausedTime;
            [item.layer removeAllAnimations];
            [item removeFromSuperview];
        }
        for (PXBarrageTrack *track in self.tracks) {
            [track.animatingItems removeAllObjects];
            [track resetTrackAvailableTime];
        }
        [self.animatingItems removeAllObjects];
        [self.reusableItems removeAllObjects];
        [self.jammedItems removeAllObjects];
    }
}

- (void)pause {
    if (self.status != PXBarrageStatusPaused) {
        self.status = PXBarrageStatusPaused;
        for (PXBarrageItem *item in self.animatingItems) {
            if (item.isInterrupted) {
                continue;;
            }
            CFTimeInterval pausedTime = [item.layer convertTime:CACurrentMediaTime() fromLayer:nil];
            item.layer.speed = 0.0;
            item.layer.timeOffset = pausedTime;
        }
    }
}

- (void)resume {
    if (self.status == PXBarrageStatusStarted) {
        return;
    }else if (self.status == PXBarrageStatusPaused) {
        self.status = PXBarrageStatusStarted;
    }else {
        return;
    }
    
    CFTimeInterval timeSincePauseForTracks = 0.0; //记录暂停的时长
    for (PXBarrageItem *item in self.animatingItems) {
        if (item.isInterrupted ) {
            continue;;
        }
        CFTimeInterval pausedTime = item.layer.timeOffset;
        item.layer.speed = 1.0;
        item.layer.timeOffset = 0;
        item.layer.beginTime = 0;
        CFTimeInterval timeSincePause = [item.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        timeSincePauseForTracks = timeSincePause;
        item.layer.beginTime = timeSincePause;
    }
    
    for (PXBarrageTrack *track in self.tracks) {
        track.availableTimeForNext += timeSincePauseForTracks;
    }
    if (self.jammedItems.count > 0) {
        [self fireJammedItems];
    }
}

- (void)pauseItem:(PXBarrageItem *)item {
    item.isInterrupted = YES;
    CFTimeInterval pausedTime = [item.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    item.layer.speed = 0.0;
    item.layer.timeOffset = pausedTime;
}

- (void)resumeItem:(PXBarrageItem *)item {
    CFTimeInterval pausedTime = item.layer.timeOffset;
    item.layer.speed = 1.0;
    item.layer.timeOffset = 0;
    item.layer.beginTime = 0;
    CFTimeInterval timeSincePause = [item.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    item.layer.beginTime = timeSincePause;
}

#pragma mark - Fire Barage

- (void)fireBarrageWithDescriptor:(PXBarrageItemDescriptor *)descritor {
    if (!descritor.attributedText) {
        return;
    }
    PXBarrageItem *item = [self dequeueReusableBarrageItem];
    if (item) {
        item.descriptor = descritor;
        [self fireBarrage:item];
    }
}

- (void)fireBarrage:(PXBarrageItem *)item {
    if (self.status != PXBarrageStatusStarted) {
        return;
    }
    if (self.tracks.count <=0) {
        return;
    }
    
    if (self.hidden) {
        //view被隐藏后，不再往下执行，移除所有被阻塞的弹幕，移除所有可复用的弹幕，尽量减少资源消耗
        //正在执行的弹幕继续执行，不移除，虽然看不见，这样是为了在重新显示画布时，已经发出去的弹幕如果没有结束就还在屏幕上执行动画到结束，体验上会比较好
        [self.jammedItems removeAllObjects];
        [self.reusableItems removeAllObjects];
    }
    
    PXBarrageTrack *track = [self availableTrack];
    if (track) {
        //有可用轨道，正常发送弹幕
        [self fireBarrage:item onTrack:track];
    }else {
        //无可用轨道，弹幕被阻塞
        [self.jammedItems addObject:item];
    }
}

- (void)fireBarrage:(PXBarrageItem *)item onTrack:(PXBarrageTrack *)track {
    item.track = track;
    [track.animatingItems addObject:item];
//    [item clearContents];
    [item updateSubviewsData];
//    [item layoutContentSubviews];
//    [item convertContentToImage];
    [item sizeToFit];
//    [item removeSubViewsAndSublayers];
    [self addSubview:item];
    CGRect startFrame = [self barrageItemStartFrame:item track:track];
    item.frame = startFrame;
    [item addBarrageAnimationWithDelegate:self];
    [self recordAvailableTimeForNext:item track:track];
    
    [self.animatingItems addObject:item];
    if ([self.jammedItems containsObject:item]) {
        [self.jammedItems removeObject:item];  //被阻塞弹幕已成功发送，从已阻塞弹幕队列移除
    }
}

//尝试发送被阻塞的弹幕
- (void)fireJammedItems {
    if (self.jammedItems.count > 0) {
        if (self.status == PXBarrageStatusStarted && self.tracks.count > 0) {
            if ([self availableTrack] && self.jammedItems.firstObject)  {
                [self fireBarrage:self.jammedItems.firstObject];
            }
        }
    }
}

#pragma mark - item reuse
- (PXBarrageItem *)dequeueReusableBarrageItem {
    PXBarrageItem *firstitem = self.reusableItems.firstObject;
    if (firstitem) {
        [self.reusableItems removeObject:firstitem];
        return firstitem ;
    }else {
        return  [self createNewItem];
    }
}

- (PXBarrageItem *)createNewItem {
    PXBarrageItem *item = [[PXBarrageItem alloc] init];
    return item;
}

#pragma mark funcs

- (PXBarrageTrack *)availableTrack {
    for (PXBarrageTrack *track in self.tracks) {
        if (track.isAvailable) {
            return  track;
        }
    }
    return nil;
}

- (CGRect)barrageItemStartFrame:(PXBarrageItem *)item track:(PXBarrageTrack *)track {
    CGRect rect = item.bounds;
    rect.origin.x = CGRectGetMaxX(self.frame);
    rect.origin.y = track.positonY;
    return  rect;
}

- (void)recordAvailableTimeForNext:(PXBarrageItem *)item track:(PXBarrageTrack *)track {
    CAKeyframeAnimation *keyFrameAnimation = item.walkingAnimation;
    if (!keyFrameAnimation) {
        return;
    }
    /*
    NSValue *fromValue = keyFrameAnimation.values.firstObject;
    NSValue *toValue = keyFrameAnimation.values.lastObject;
    if (!fromValue || !toValue) {
        return;
    }
    NSTimeInterval duration = keyFrameAnimation.duration;
    CGPoint fromPoint = fromValue.CGPointValue;
    CGPoint toPoint = toValue.CGPointValue;
    CGFloat distanceX = fabs(toPoint.x - fromPoint.x);
    double speed = distanceX / duration;*/
    double speed = item.descriptor.speed;
    NSTimeInterval time = (item.bounds.size.width + kBarrageItemsSpacingMin) / speed; //加上弹幕间最小间距30
    track.availableTimeForNext = CACurrentMediaTime() + time;
}

- (void)itemFinished:(PXBarrageItem *)item {
    item.waitForReuseAfterInteract = NO;
    [item.track.animatingItems removeObject:item];
    item.track = nil;
    [item removeFromSuperview];
    [item prepareForReuse];
    [self.reusableItems addObject:item];
}

#pragma mark - handle user touch

- (void)handleTouchPoint:(CGPoint)touchPoint {
    for (PXBarrageItem *item in self.animatingItems) {
        if ([item.layer.presentationLayer hitTest:touchPoint]) {
//            CGRect rect = item.layer.presentationLayer.frame;
            [self barrageItemClicked:item];
            break;
        }
    }
}

- (void)barrageItemClicked:(PXBarrageItem *)item  {
    if (self.interactType == PXBarrageInteractTypeNone ) {
        return;
    }else if (self.interactType == PXBarrageInteractTypePause) {
        if (self.currentInteractItem) {
            [self endInteractBarrageItemAndCancelPrevious:self.currentInteractItem];
        }
        [self handleInteractBarrageItem:item];
        if ([self.delegate respondsToSelector:@selector(barrageCanvasView:didInteract:)]) {
            [self.delegate barrageCanvasView:self didInteract:item];
        }
    }else if (self.interactType == PXBarrageInteractTypeFadeAndToast) {
        if (self.currentInteractItem) {
            [self endInteractBarrageItemAndCancelPrevious:self.currentInteractItem];
        }
        [self handleInteractBarrageItem:item];
        if ([self.delegate respondsToSelector:@selector(barrageCanvasView:didInteract:)]) {
            [self.delegate barrageCanvasView:self didInteract:item];
        }
    }
}

- (void)handleInteractBarrageItem:(PXBarrageItem *)item {
    if (self.status == PXBarrageStatusStarted) {
        if (self.interactType == PXBarrageInteractTypeNone ) {
            return;;
        }else if (self.interactType == PXBarrageInteractTypePause) {
            self.currentInteractItem = item;
            item.track.paused = YES;
            for (PXBarrageItem *barrageItem in [item.track itemsStartAtItem:item]) {
                [self pauseItem:barrageItem];
            }
        }else if (self.interactType == PXBarrageInteractTypeFadeAndToast) {
            self.currentInteractItem = item;
            [item.layer addAnimation:item.hidingAnimation forKey:@"hidingAnimation"];
        }
        NSTimeInterval delay = item.descriptor.remainDuration;
        [self performSelector:@selector(endInteractBarrageItem:) withObject:item afterDelay:delay];
    }
}

- (void)endInteractBarrageItemAndCancelPrevious:(PXBarrageItem *)item {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(endInteractBarrageItem:) object:self.currentInteractItem];
    [self endInteractBarrageItem:self.currentInteractItem];
}

- (void)endInteractBarrageItem:(PXBarrageItem *)item{
    if (self.interactType == PXBarrageInteractTypeNone ) {
        return;
    }else if (self.interactType == PXBarrageInteractTypePause) {
        self.currentInteractItem = nil;
        item.track.paused = NO;
        for (PXBarrageItem *barrageItem in [item.track itemsStartAtItem:item]) {
            [self resumeItem:barrageItem];
        }
    }else if (self.interactType == PXBarrageInteractTypeFadeAndToast) {
        self.currentInteractItem = nil;
        [item.layer addAnimation:item.showingAnimation forKey:@"showingAnimation"];
    }
    if ([self.delegate respondsToSelector:@selector(barrageCanvasView:itemDidEndInteract:)]) {
        [self.delegate barrageCanvasView:self itemDidEndInteract:item];
    }
    if (item.waitForReuseAfterInteract) {
        [self itemFinished:item];
    }
}

#pragma mark - override touch events

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (event.type == UIEventTypeTouches) {
        UITouch *touch = [touches.allObjects firstObject];
        CGPoint touchPoint = [touch locationInView:self];
        [self handleTouchPoint:touchPoint];
    }
}

#pragma mark - PXBarrageTrackDelegate

- (void)barrageTrackDidBecomeAvailable:(PXBarrageTrack *)track {
    [self fireJammedItems];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!flag) {
        return;;
    }
    PXBarrageItem *currentItem;
    for (PXBarrageItem *item in self.animatingItems) {
        if (anim == [item.layer animationForKey:kBarrageAnimationKey]) {
            currentItem = item;
            [self.animatingItems removeObject:item];
            for (PXBarrageTrack *track in self.tracks) {
                if ([track.animatingItems containsObject:item]) {
                    [track.animatingItems removeObject:item];
                    break;
                }
            }
            break;
        }
    }
    
    if (currentItem) {
        if (currentItem != self.currentInteractItem) {
            [self itemFinished:currentItem];
        }
        else {
            currentItem.waitForReuseAfterInteract = YES;
        }
    }
}

@end

