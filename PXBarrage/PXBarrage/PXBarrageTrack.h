//
//  PXBarrageTrack.h
//  PXBarrage
//
//  Created by WZH ZHANG on 2022/5/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PXBarrageTrack;
@protocol PXBarrageTrackDelegate <NSObject>
@optional
- (void)barrageTrackDidBecomeAvailable:(PXBarrageTrack *)track;
@end

@class PXBarrageItem;
@interface PXBarrageTrack : NSObject

@property (nonatomic,assign) NSUInteger index; // 轨道序号
@property (nonatomic,assign) CGFloat positonY;  //轨道的y轴位置
@property (nonatomic,assign) NSTimeInterval availableTimeForNext; //记录下一个弹幕item可以在此轨道发射的时间差

@property (nonatomic,strong) NSMutableArray <PXBarrageItem *> * animatingItems;

@property (nonatomic,assign) BOOL isAvailable; // 是否可用
@property (nonatomic,assign) BOOL paused; //当前轨道上是否有被打断的弹幕

@property (nonatomic,weak) id <PXBarrageTrackDelegate> delegate;

- (instancetype) initWithPositonY:(CGFloat)postionY;

- (void)resetTrackAvailableTime;

- (NSArray <PXBarrageItem *> *)itemsStartAtItem:(PXBarrageItem *)item;

@end

NS_ASSUME_NONNULL_END
