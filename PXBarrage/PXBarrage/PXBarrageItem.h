//
//  PXBarrageItem.h
//  PXBarrage
//
//  Created by WZH ZHANG on 2022/5/11.
//

#import <UIKit/UIKit.h>
#import "PXBarrageItemDescriptor.h"
#import "PXBarrageTrack.h"

#define kBarrageAnimationKey  @"BarrageItemAnimationKey"

@class PXBarrageInterctToast;
@interface PXBarrageItem : UIView

@property (nonatomic,strong) PXBarrageItemDescriptor *descriptor;

@property (nonatomic,weak) PXBarrageTrack *track;  //所处轨道

@property (nonatomic,assign) BOOL isInterrupted;  //记录被用户点击打断，暂停在屏幕上

@property (nonatomic,strong) CAKeyframeAnimation *walkingAnimation;
@property (nonatomic,strong) CABasicAnimation *hidingAnimation;
@property (nonatomic,strong) CABasicAnimation *showingAnimation;

@property (nonatomic,weak) PXBarrageInterctToast *toast;

//有时候会出现一种情况：弹幕被点击，处于交互状态，然后弹幕继续往前走出屏幕，再结束交互，这里加一个bool值记录下这个弹幕需要被回收
@property (nonatomic,assign) BOOL waitForReuseAfterInteract;

- (void)clearContents;

- (void)updateSubviewsData;

- (void)prepareForReuse;

- (void)layoutContentSubviews;

- (void)convertContentToImage;

- (void)removeSubViewsAndSublayers;

- (void)addBarrageAnimationWithDelegate:(id<CAAnimationDelegate>)animationDelegate;

@end


