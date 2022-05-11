//
//  PXBarrageInterctToast.h
//  PXBarrage
//
//  Created by WZH ZHANG on 2022/5/11.
//

#import <UIKit/UIKit.h>
#import "PXBarrageHeader.h"
#import "PXBarrageItem.h"
#import "PXBarrageCanvasView.h"

NS_ASSUME_NONNULL_BEGIN

@class PXBarrageInterctToast;
@protocol PXBarrageInterctToastDelegate <NSObject>

@optional
- (void)barrageInterctToastDidTouchBackground:(PXBarrageInterctToast *)toast;

- (void)barrageInterctToast:(PXBarrageInterctToast *)toast didClickButton:(UIButton *)btn;

@end

@interface PXBarrageInterctToast : UIView

@property (nonatomic,weak) id <PXBarrageInterctToastDelegate> delegate;

@property (nonatomic,strong) PXBarrageItem *item;

@property (nonatomic,strong) PXBarrageCanvasView *canvasView;

- (instancetype)initWithBarrageItem:(PXBarrageItem *)item canvasView:(PXBarrageCanvasView *)canvasView;

- (void)showFromRect:(CGRect)rect;
- (void)dismissToRect:(CGRect)rect;

@end

NS_ASSUME_NONNULL_END
