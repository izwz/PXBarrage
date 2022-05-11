//
//  PXBarrageHeader.h
//  PXBarrage
//
//  Created by WZH ZHANG on 2022/5/11.
//

#ifndef PXBarrageHeader_h
#define PXBarrageHeader_h

//弹幕被点击的交互效果
typedef NS_ENUM(NSInteger, PXBarrageInteractType) {
    //无交互
    PXBarrageInteractTypeNone,
    //弹幕暂停移动
    PXBarrageInteractTypePause,
    //弹幕继续移动，但是变透明隐身，并弹个窗口，结束打断后，继续显示
    PXBarrageInteractTypeFadeAndToast
};

typedef NS_ENUM(NSUInteger, PXBarrageStatus) {
    PXBarrageStatusStopped,
    PXBarrageStatusPaused,
    PXBarrageStatusStarted,
};

//弹幕穿越屏幕的总时长，从头部露出，到尾部消失
//#define kBarrageAnimationDuration  7.0

//弹幕间最小间距30
#define kBarrageItemsSpacingMin  30.0

//弹幕默认速度
#define kBarrageItemDefaultSpeed 90.0;

//弹幕被点击后默认停留的时间
#define kBarrageItemDefualtRemainDuration 3.0


#endif /* PXBarrageHeader_h */
