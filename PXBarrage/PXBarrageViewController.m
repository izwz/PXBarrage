//
//  PXBarrageViewController.m
//  PXBarrage
//
//  Created by WZH ZHANG on 2022/5/11.
//

#import "PXBarrageViewController.h"
#import "Masonry/Masonry.h"
#import "PXBarrage/PXBarrage.h"
#import "NSString+PX.h"
#import "PXMacro.h"


@interface PXBarrageViewController ()<UITextFieldDelegate,PXBarrageCanvasViewDelegate,PXBarrageInterctToastDelegate>

@property (nonatomic,strong) PXBarrageManager *barrageManager;

@property (nonatomic,strong) UIView *barrageBg;

@property (nonatomic,strong) UITextField *txtField;
@property (nonatomic,strong) UIButton *btnStart;
@property (nonatomic,strong) UIButton *btnPause;
@property (nonatomic,strong) UIButton *btnResume;
@property (nonatomic,strong) UIButton *btnStop;
@property (nonatomic,strong) UIButton *btnBigQuantity;

@end

@implementation PXBarrageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"弹幕";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.barrageBg];
    [self.barrageBg addSubview:self.barrageManager.barrageCanvasView];
    self.barrageManager.barrageCanvasView.interactType = PXBarrageInteractTypeNone;
    self.barrageManager.barrageCanvasView.delegate = self;
    
    [self.view addSubview:self.txtField];
    [self.txtField becomeFirstResponder];
    [self.view addSubview:self.btnStart];
    [self.view addSubview:self.btnPause];
    [self.view addSubview:self.btnResume];
    [self.view addSubview:self.btnStop];
    [self.view addSubview:self.btnBigQuantity];
    
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:@[@"none",@"pause",@"toast"]];
    seg.selectedSegmentIndex = 0;
    [seg addTarget:self action:@selector(segChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = seg;
    [self makeConstraints];
}

#pragma mark funcs

- (void)makeConstraints {
    [self.barrageBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.top.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }
    }];
    
    [self.barrageManager.barrageCanvasView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.barrageBg);
    }];
    
    [self.txtField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.centerY.equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
    
    [self.btnStart mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
        } else {
            make.left.equalTo(self.view);
        }
        make.bottom.equalTo(self.txtField.mas_top).offset(-2);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(40);
    }];
    
    [self.btnPause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.btnStart.mas_right).offset(3);
        make.bottom.equalTo(self.txtField.mas_top).offset(-2);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(40);
    }];
    
    [self.btnResume mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.btnPause.mas_right).offset(3);
        make.bottom.equalTo(self.txtField.mas_top).offset(-2);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(40);
    }];
    [self.btnStop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.btnResume.mas_right).offset(3);
        make.bottom.equalTo(self.txtField.mas_top).offset(-2);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(40);
    }];
    [self.btnBigQuantity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.btnStop.mas_right).offset(3);
        make.bottom.equalTo(self.txtField.mas_top).offset(-2);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(40);
    }];
}

- (void)sendLargeQuantityOfBarrage {
    for (int i = 0; i < 100; i ++) {
        NSString *str = [NSString stringWithFormat:@"%d 呵呵呵呵🙄🙄🙄",i];
        [self sendBarrageText:str];
    }
}

- (void)sendBarrageText:(NSString *)text  {
    if (self.barrageManager.barrageCanvasView.status != PXBarrageStatusStarted) {
        NSLog(@"请先点击“开始”");
        return;
    }
    
    CGFloat randomFontSize = arc4random()%11 + 10; //10-20之间的随机数
    [self sendBarrageText:text alpha:0.9 textColor:[self randomColor] font:[UIFont systemFontOfSize:randomFontSize]];
}

- (void)sendBarrageText:(NSString *)text alpha:(CGFloat)alpha textColor:(UIColor *)textColor font:(UIFont *)font {
    if ([NSString px_isNilOrEmpty:text]) {
        return;
    }
    if (alpha == 0) {
        alpha = 1;
    }
    if (!textColor) {
        textColor = [UIColor whiteColor];
    }
    if (!font) {
        font = [UIFont systemFontOfSize:18];
    }
    NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithString:text];
    NSDictionary *attribute = @{NSFontAttributeName: font, NSForegroundColorAttributeName:[textColor colorWithAlphaComponent:alpha]};
    NSRange range = NSMakeRange(0, attributeText.length);
    [attributeText addAttributes:attribute range:range];
    
    PXBarrageItemDescriptor *descriptor = [[PXBarrageItemDescriptor alloc] initWithAttributedText:attributeText];
    descriptor.speed = 70;
    descriptor.remainDuration = 3;
    [self.barrageManager fireBarrage:descriptor];
}

- (UIColor *)randomColor {
    CGFloat hue = (arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}

- (void)segChanged:(UISegmentedControl *)seg {
    [self.barrageManager stop];
    if (seg.selectedSegmentIndex == 0) {
        self.barrageManager.barrageCanvasView.interactType = PXBarrageInteractTypeNone;
    } else if (seg.selectedSegmentIndex == 1){
        self.barrageManager.barrageCanvasView.interactType = PXBarrageInteractTypePause;
    } else if (seg.selectedSegmentIndex == 2){
        self.barrageManager.barrageCanvasView.interactType = PXBarrageInteractTypeFadeAndToast;
    }
}

- (void)btnStartClicked {
    [self.barrageManager start];
}

- (void)btnPauseClicked {
    [self.barrageManager pause];
}

- (void)btnResumeClicked {
    [self.barrageManager resume];
}

- (void)btnStopClicked {
    [self.barrageManager stop];
}

#pragma mark - PHBarrageCanvasViewDelegate

- (void)barrageCanvasView:(PXBarrageCanvasView *)barrageCanvasView didInteract:(PXBarrageItem *)barrageItem{
    if (barrageCanvasView.interactType != PXBarrageInteractTypeFadeAndToast) {
        return;
    }
    CGRect rect = barrageItem.layer.presentationLayer.frame;
    NSString *msg = [NSString stringWithFormat:@"交互弹幕“%@” rect：%@",barrageItem.descriptor.attributedText.string,[NSValue valueWithCGRect:rect]];
    NSLog(@"%@", msg);
    PXBarrageInterctToast *toast = [[PXBarrageInterctToast alloc] initWithBarrageItem:barrageItem canvasView:barrageCanvasView];
    toast.delegate = self;
    barrageItem.toast = toast;
    CGRect rectOnWindow = [barrageCanvasView convertRect:rect toView:PX_KEY_WINDOW];
    [toast showFromRect:rectOnWindow];
}
 
- (void)barrageCanvasView:(PXBarrageCanvasView *_Nullable)barrageCanvasView itemDidEndInteract:(PXBarrageItem *_Nullable)barrageItem {
    if (barrageCanvasView.interactType != PXBarrageInteractTypeFadeAndToast) {
        return;
    }
    CGRect rect = barrageItem.layer.presentationLayer.frame;
    NSString *msg = [NSString stringWithFormat:@"弹幕结束交互“%@” rect：%@",barrageItem.descriptor.attributedText.string,[NSValue valueWithCGRect:rect]];
    NSLog(@"%@", msg);
    
    if (barrageItem.toast) {
        CGRect rectOnWindow = [barrageCanvasView convertRect:rect toView:PX_KEY_WINDOW];
        [barrageItem.toast dismissToRect:rectOnWindow];
    }
}

#pragma  mark - PXBarrageInterctToastDelegate

- (void)barrageInterctToastDidTouchBackground:(PXBarrageInterctToast *)toast {
    [self.barrageManager.barrageCanvasView endInteractBarrageItemAndCancelPrevious:toast.item];
}

- (void)barrageInterctToast:(PXBarrageInterctToast *)toast didClickButton:(UIButton *)btn {
    NSLog(@"%@ clicked",btn.currentTitle);
    [self.barrageManager.barrageCanvasView endInteractBarrageItemAndCancelPrevious:toast.item];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 0) {
        [self sendBarrageText:textField.text];
    }
    return  YES;
}

#pragma mark - lazy load

- (PXBarrageManager *)barrageManager {
    if (!_barrageManager) {
        _barrageManager = [[PXBarrageManager alloc] init];
        [_barrageManager setTracksNumber:5 startPositionY:30 spacing:40];
    }
    return _barrageManager;
}

- (UIView *)barrageBg {
    if (!_barrageBg) {
        _barrageBg = [[UIView alloc] init];
        _barrageBg.backgroundColor = [UIColor lightGrayColor];
    }
    return _barrageBg;
}

- (UITextField *)txtField {
    if (!_txtField) {
        _txtField = [[UITextField alloc] init];
        _txtField.placeholder = @"发送弹幕";
        _txtField.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _txtField.layer.borderWidth = 1;
        _txtField.layer.cornerRadius = 3;
        _txtField.backgroundColor = [UIColor whiteColor];
        _txtField.delegate = self;
        _txtField.returnKeyType = UIReturnKeySend;
    }
    return _txtField;
}

- (UIButton *)btnStart {
    if (!_btnStart) {
        _btnStart = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnStart setTitle:@"开始" forState:UIControlStateNormal];
        _btnStart.backgroundColor = [UIColor grayColor];
        [_btnStart setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnStart addTarget:self action:@selector(btnStartClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _btnStart;
}

- (UIButton *)btnPause {
    if (!_btnPause) {
        _btnPause = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnPause setTitle:@"暂停" forState:UIControlStateNormal];
        _btnPause.backgroundColor = [UIColor grayColor];
        [_btnPause setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnPause addTarget:self action:@selector(btnPauseClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _btnPause;
}

- (UIButton *)btnResume {
    if (!_btnResume) {
        _btnResume = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnResume setTitle:@"继续" forState:UIControlStateNormal];
        _btnResume.backgroundColor = [UIColor grayColor];
        [_btnResume setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnResume addTarget:self action:@selector(btnResumeClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _btnResume;
}

- (UIButton *)btnStop {
    if (!_btnStop) {
        _btnStop = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnStop setTitle:@"停止" forState:UIControlStateNormal];
        _btnStop.backgroundColor = [UIColor grayColor];
        [_btnStop setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnStop addTarget:self action:@selector(btnStopClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _btnStop;
}

- (UIButton *)btnBigQuantity {
    if (!_btnBigQuantity) {
        _btnBigQuantity = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnBigQuantity setTitle:@"大量弹幕" forState:UIControlStateNormal];
        _btnBigQuantity.backgroundColor = [UIColor grayColor];
        [_btnBigQuantity setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnBigQuantity addTarget:self action:@selector(sendLargeQuantityOfBarrage) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _btnBigQuantity;
}

@end
