//
//  PXBarrageInterctToast.m
//  PXBarrage
//
//  Created by WZH ZHANG on 2022/5/11.
//

#import "PXBarrageInterctToast.h"
#import "Masonry/Masonry.h"

@interface PXBarrageInterctToast ()

@property (nonatomic,strong) UIView *content;

@property (nonatomic,assign) CGRect fromRect;

@property (nonatomic,assign) CGRect toRect;

@property (nonatomic,strong) UILabel *lblText;

@property (nonatomic,strong) UIButton *btnPraise;

@property (nonatomic,strong) UIButton *btnReport;

@end

@implementation PXBarrageInterctToast

- (instancetype)initWithBarrageItem:(PXBarrageItem *)item canvasView:(PXBarrageCanvasView *)canvasView {
    self = [super init];
    if (self) {
        _item = item;
        _canvasView = canvasView;
        [self addSubview:self.content];
        [self.content addSubview:self.lblText];
        [self.content addSubview:self.btnPraise];
        [self.content addSubview:self.btnReport];
        self.lblText.text = [item.descriptor.attributedText string];
    }
    return self;
}

#pragma mark - funcs

- (void)showFromRect:(CGRect)rect {
    self.fromRect = rect;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(window);
    }];
    
    [self.lblText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.content).offset(20);
        make.centerY.equalTo(self.content);
    }];
    [self.btnPraise mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.left.equalTo(self.lblText.mas_right).offset(20);
        make.centerY.equalTo(self.content);
    }];
    [self.btnReport mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.left.equalTo(self.btnPraise.mas_right).offset(20);
        make.centerY.equalTo(self.content);
    }];
    
    [self setupContentAtTrack:rect];

    self.content.alpha = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
                self.content.alpha = 1;
                [self setupContentAtCenter];
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
            }];
        });
}

- (void)dismissToRect:(CGRect)rect {
    self.toRect = rect;
    NSTimeInterval duration = 0.25;
    //消失动画执行过程需要0.25秒，这时弹幕又会继续往前移动一点距离，所以这里做一个纠偏
    rect.origin.x -= self.item.descriptor.speed * (duration + 0.1);
    self.content.alpha = 1;
    [UIView animateWithDuration:duration animations:^{
            self.content.alpha = 0;
            [self setupContentAtTrack:rect];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
}

- (void)setupContentAtTrack:(CGRect)rect {
    [self.content mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.right.equalTo(self.btnReport).offset(20);
        make.centerX.equalTo(self.mas_left).offset(CGRectGetMidX(rect));
        make.centerY.equalTo(self.mas_top).offset(CGRectGetMidY(rect));
    }];
    CGFloat scale = rect.size.height / 40;
    self.content.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)setupContentAtCenter {
    [self.content mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.right.equalTo(self.btnReport).offset(20);
        make.centerX.centerY.equalTo(self);
        make.left.mas_greaterThanOrEqualTo(self.mas_left).offset(20).priorityHigh();
    }];
    self.content.transform = CGAffineTransformMakeScale(1, 1);
}

- (void)btnClicked:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(barrageInterctToast:didClickButton:)]) {
        [self.delegate barrageInterctToast:self didClickButton:btn];
    }
}

#pragma mark - UIResponder touch

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(self.content.frame, point)) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(barrageInterctToastDidTouchBackground:)]) {
            [self.delegate barrageInterctToastDidTouchBackground:self];
        }
    }
}

#pragma mark - lazy load

- (UIView *)content {
    if (!_content) {
        _content = [[UIView alloc] init];
        _content.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7];
        _content.layer.cornerRadius = 20;
    }
    return  _content;
}

- (UILabel *)lblText {
    if (!_lblText) {
        _lblText = [[UILabel alloc] init];
        _lblText.font = [UIFont systemFontOfSize:20];
        [_lblText setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        _lblText.textColor = [UIColor whiteColor];
    }
    return  _lblText;
}

- (UIButton *)btnPraise {
    if (!_btnPraise) {
        _btnPraise = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnPraise setBackgroundColor:[UIColor yellowColor]];
        [_btnPraise addTarget:self action:@selector(btnClicked:)
             forControlEvents:UIControlEventTouchUpInside];
        [_btnPraise setTitle:@"点赞" forState:UIControlStateNormal];
    }
    return _btnPraise;
}

- (UIButton *)btnReport {
    if (!_btnReport) {
        _btnReport = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnReport setBackgroundColor:[UIColor yellowColor]];
        [_btnReport addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_btnReport setTitle:@"举报" forState:UIControlStateNormal];
    }
    return _btnReport;
}

@end
