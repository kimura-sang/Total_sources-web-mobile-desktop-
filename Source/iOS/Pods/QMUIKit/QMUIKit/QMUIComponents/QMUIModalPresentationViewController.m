/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIModalPresentationViewController.m
//  qmui
//
//  Created by QMUI Team on 16/7/6.
//

#import "QMUIModalPresentationViewController.h"
#import "QMUICore.h"
#import "UIViewController+QMUI.h"
#import "UIView+QMUI.h"
#import "QMUIKeyboardManager.h"
#import "UIWindow+QMUI.h"

@interface UIViewController ()

@property(nonatomic, weak, readwrite) QMUIModalPresentationViewController *qmui_modalPresentationViewController;
@end

@implementation QMUIModalPresentationViewController (UIAppearance)

static QMUIModalPresentationViewController *appearance;
+ (nonnull instancetype)appearance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initDefaultAppearance];
    });
    return appearance;
}

+ (void)initDefaultAppearance {
    if (!appearance) {
        appearance = [[self alloc] init];
    }
    appearance.animationStyle = QMUIModalPresentationAnimationStyleFade;
    appearance.contentViewMargins = UIEdgeInsetsMake(20, 20, 20, 20);
    appearance.maximumContentViewWidth = CGFLOAT_MAX;
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self appearance];
    });
}

@end

@interface QMUIModalPresentationViewController ()<QMUIKeyboardManagerDelegate>

@property(nonatomic, strong) QMUIModalPresentationWindow *containerWindow;
@property(nonatomic, weak) UIWindow *previousKeyWindow;

@property(nonatomic, assign, readwrite, getter=isVisible) BOOL visible;

@property(nonatomic, assign) BOOL appearAnimated;
@property(nonatomic, copy) void (^appearCompletionBlock)(BOOL finished);

@property(nonatomic, assign) BOOL disappearAnimated;
@property(nonatomic, copy) void (^disappearCompletionBlock)(BOOL finished);

/// ?????? modal ????????? present ???????????????????????????????????? present ??????????????????????????????????????????????????? viewWillAppear:
@property(nonatomic, assign) BOOL viewWillAppearByPresentedViewController;

/// ??????????????????????????????viewWillDisappear????????????hideInView?????????
@property(nonatomic, assign) BOOL hasAlreadyViewWillDisappear;

/// ????????? showInView ????????????????????????????????????????????????????????? pop?????? push ?????????????????????????????????????????? viewWillDisappear:????????????????????????????????????????????? viewWillDisappear: ????????????????????? hide ??????????????????????????????
/// https://github.com/Tencent/QMUI_iOS/issues/639
@property(nonatomic, assign) BOOL willHideInView;

@property(nonatomic, strong) UITapGestureRecognizer *dimmingViewTapGestureRecognizer;
@property(nonatomic, strong) QMUIKeyboardManager *keyboardManager;
@property(nonatomic, assign) CGFloat keyboardHeight;
@end

@implementation QMUIModalPresentationViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    if (appearance) {
        self.animationStyle = appearance.animationStyle;
        self.contentViewMargins = appearance.contentViewMargins;
        self.maximumContentViewWidth = appearance.maximumContentViewWidth;
        self.onlyRespondsToKeyboardEventFromDescendantViews = YES;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationCustom;
        
        // ?????????????????? present ?????????????????????????????????????????????????????????????????? supportedInterfaceOrientations ????????????????????????????????????
        UIViewController *visibleViewController = [QMUIHelper visibleViewController];
        if (visibleViewController) {
            self.supportedOrientationMask = visibleViewController.supportedInterfaceOrientations;
        } else {
            self.supportedOrientationMask = SupportedOrientationMask;
        }
        
        if (self != appearance) {
            self.keyboardManager = [[QMUIKeyboardManager alloc] initWithDelegate:self];
            [self initDefaultDimmingViewWithoutAddToView];
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (self.contentViewController) {
        // ??? IB ???????????? contentViewController ???????????????????????????????????? contentView ?????????
        self.contentViewController = self.contentViewController;
    }
}

- (void)dealloc {
    self.containerWindow = nil;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    // ?????????childViewController?????????????????????????????????????????????????????????
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.dimmingView && !self.dimmingView.superview) {
        [self.view addSubview:self.dimmingView];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.dimmingView.frame = self.view.bounds;
    
    CGRect contentViewFrame = [self contentViewFrameForShowing];
    if (self.layoutBlock) {
        self.layoutBlock(self.view.bounds, self.keyboardHeight, contentViewFrame);
    } else {
        self.contentView.qmui_frameApplyTransform = contentViewFrame;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.shownInWindowMode) {
        // ????????????showWithAnimated:completion:?????????????????????????????????????????????????????????animated??????
        animated = self.appearAnimated;
    }
    
    self.keyboardManager.delegateEnabled = YES;
    
    if (self.contentViewController) {
        self.contentViewController.qmui_modalPresentationViewController = self;
        [self.contentViewController beginAppearanceTransition:YES animated:animated];
    }
    
    // ??????????????? present ???????????????????????????????????????????????? viewWillAppear???????????????????????????????????????????????????????????????????????????????????????????????????
    self.viewWillAppearByPresentedViewController = [self isShowingPresentedViewController];
    if (self.viewWillAppearByPresentedViewController) {
        return;
    }
    
    if (self.isShownInWindowMode) {
        [QMUIHelper dimmedApplicationWindow];
    }
    
    void (^didShownCompletion)(BOOL finished) = ^(BOOL finished) {
        if (self.contentViewController) {
            [self.contentViewController endAppearanceTransition];
        }
        
        self.visible = YES;
        
        if (self.appearCompletionBlock) {
            self.appearCompletionBlock(finished);
            self.appearCompletionBlock = nil;
        }
        
        self.appearAnimated = NO;
    };
    
    if (animated) {
        [self.view addSubview:self.contentView];
        [self.view layoutIfNeeded];
        
        CGRect contentViewFrame = [self contentViewFrameForShowing];
        if (self.showingAnimation) {
            // ????????????????????????
            if (self.layoutBlock) {
                self.layoutBlock(self.view.bounds, self.keyboardHeight, contentViewFrame);
                contentViewFrame = self.contentView.frame;
            }
            self.showingAnimation(self.dimmingView, self.view.bounds, self.keyboardHeight, contentViewFrame, didShownCompletion);
        } else {
            self.contentView.frame = contentViewFrame;
            [self.contentView setNeedsLayout];
            [self.contentView layoutIfNeeded];
            
            [self showingAnimationWithCompletion:didShownCompletion];
        }
    } else {
        CGRect contentViewFrame = [self contentViewFrameForShowing];
        self.contentView.frame = contentViewFrame;
        [self.view addSubview:self.contentView];
        self.dimmingView.alpha = 1;
        didShownCompletion(YES);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.viewWillAppearByPresentedViewController) {
        if (self.contentViewController) {
            [self.contentViewController endAppearanceTransition];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.hasAlreadyViewWillDisappear) {
        return;
    }
    
    /// ????????? showInView ????????????????????????????????????????????????????????? pop?????? push ?????????????????????????????????????????? viewWillDisappear:????????????????????????????????????????????? viewWillDisappear: ????????????????????? hide ???????????? willHideInView ????????????
    /// https://github.com/Tencent/QMUI_iOS/issues/639
    if (self.shownInSubviewMode && !self.willHideInView) {
        return;
    }
    
    [super viewWillDisappear:animated];
    
    if (self.shownInWindowMode) {
        animated = self.disappearAnimated;
    }
    
    BOOL willDisappearByPresentedViewController = [self isShowingPresentedViewController];
    
    if (!willDisappearByPresentedViewController) {
        if ([self.delegate respondsToSelector:@selector(willHideModalPresentationViewController:)]) {
            [self.delegate willHideModalPresentationViewController:self];
        }
    }
    
    // ????????????????????????????????????????????????????????????????????????????????????????????????
    self.keyboardManager.delegateEnabled = NO;
    [self.view endEditing:YES];
    
    if (self.contentViewController) {
        [self.contentViewController beginAppearanceTransition:NO animated:animated];
    }
    
    // ??????????????? present ??????????????????????????? willDisappear????????????????????????????????????????????????????????????
    if (willDisappearByPresentedViewController) {
        return;
    }
    
    if (self.isShownInWindowMode) {
        [QMUIHelper resetDimmedApplicationWindow];
    }
    
    void (^didHiddenCompletion)(BOOL finished) = ^(BOOL finished) {
        
        if (self.shownInWindowMode) {
            // ?????? keyWindow ?????????????????????????????????????????? https://github.com/Tencent/QMUI_iOS/issues/90
            if (UIApplication.sharedApplication.keyWindow == self.containerWindow) {
                if (self.previousKeyWindow.hidden) {
                    // ??????????????? issue ??????????????????????????? window ?????? keyWindow https://github.com/Tencent/QMUI_iOS/issues/315
                    [UIApplication.sharedApplication.delegate.window makeKeyWindow];
                } else {
                    [self.previousKeyWindow makeKeyWindow];
                }
            }
            self.containerWindow.hidden = YES;
            self.containerWindow.rootViewController = nil;
            self.previousKeyWindow = nil;
            [self endAppearanceTransition];
        }
        
        if (self.shownInSubviewMode) {
            self.willHideInView = NO;
            
            // ????????????addSubview?????????????????????????????????????????????????????????viewWillDisappear:??????????????????self.hasAlreadyViewWillDisappear??????
            [self.view removeFromSuperview];
            self.hasAlreadyViewWillDisappear = NO;
        }
        
        [self.contentView removeFromSuperview];
        if (self.contentViewController) {
            [self.contentViewController endAppearanceTransition];
        }
        
        self.visible = NO;
        
        if ([self.delegate respondsToSelector:@selector(didHideModalPresentationViewController:)]) {
            [self.delegate didHideModalPresentationViewController:self];
        }
        
        if (self.disappearCompletionBlock) {
            self.disappearCompletionBlock(YES);
            self.disappearCompletionBlock = nil;
        }
        
        if (self.contentViewController) {
            self.contentViewController.qmui_modalPresentationViewController = nil;
            self.contentViewController = nil;
        }
        
        self.disappearAnimated = NO;
    };
    
    if (animated) {
        if (self.hidingAnimation) {
            self.hidingAnimation(self.dimmingView, self.view.bounds, self.keyboardHeight, didHiddenCompletion);
        } else {
            [self hidingAnimationWithCompletion:didHiddenCompletion];
        }
    } else {
        didHiddenCompletion(YES);
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    BOOL willDisappearByPresentedViewController = [self isShowingPresentedViewController];
    if (willDisappearByPresentedViewController) {
        if (self.contentViewController) {
            [self.contentViewController endAppearanceTransition];
        }
    }
}

- (void)updateLayout {
    if ([self isViewLoaded]) {
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }
}

#pragma mark - Dimming View

- (void)setDimmingView:(UIView *)dimmingView {
    if (![self isViewLoaded]) {
        _dimmingView = dimmingView;
    } else {
        [self.view insertSubview:dimmingView belowSubview:_dimmingView];
        [_dimmingView removeFromSuperview];
        _dimmingView = dimmingView;
        [self.view setNeedsLayout];
    }
    [self addTapGestureRecognizerToDimmingViewIfNeeded];
}

- (void)initDefaultDimmingViewWithoutAddToView {
    if (!self.dimmingView) {
        _dimmingView = [[UIView alloc] init];
        self.dimmingView.backgroundColor = UIColorMask;
        [self addTapGestureRecognizerToDimmingViewIfNeeded];
        if ([self isViewLoaded]) {
            [self.view addSubview:self.dimmingView];
        }
    }
}

// ???????????????????????????????????????dimmingView??????tap??????????????????????????????
- (void)addTapGestureRecognizerToDimmingViewIfNeeded {
    if (!self.dimmingView) {
        return;
    }
    
    if (self.dimmingViewTapGestureRecognizer.view == self.dimmingView) {
        return;
    }
    
    if (!self.dimmingViewTapGestureRecognizer) {
        self.dimmingViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDimmingViewTapGestureRecognizer:)];
    }
    [self.dimmingView addGestureRecognizer:self.dimmingViewTapGestureRecognizer];
    self.dimmingView.userInteractionEnabled = YES;// UIImageView??????userInteractionEnabled???NO???????????????UIImageView??????????????????????????????YES
}

- (void)handleDimmingViewTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.modal) {
        return;
    }
    
    if (self.shownInWindowMode) {
        __weak __typeof(self)weakSelf = self;
        [self hideWithAnimated:YES completion:^(BOOL finished) {
            if (weakSelf.didHideByDimmingViewTappedBlock) {
                weakSelf.didHideByDimmingViewTappedBlock();
            }
        }];
    } else if (self.shownInPresentedMode) {
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.didHideByDimmingViewTappedBlock) {
                self.didHideByDimmingViewTappedBlock();
            }
        }];
    } else if (self.shownInSubviewMode) {
        __weak __typeof(self)weakSelf = self;
        [self hideInView:self.view.superview animated:YES completion:^(BOOL finished) {
            if (weakSelf.didHideByDimmingViewTappedBlock) {
                weakSelf.didHideByDimmingViewTappedBlock();
            }
        }];
    }
}

#pragma mark - ContentView

- (void)setContentViewController:(UIViewController<QMUIModalPresentationContentViewControllerProtocol> *)contentViewController {
    _contentViewController = contentViewController;
    self.contentView = contentViewController.view;
}

#pragma mark - Showing and Hiding

- (void)showingAnimationWithCompletion:(void (^)(BOOL))completion {
    if (self.animationStyle == QMUIModalPresentationAnimationStyleFade) {
        self.dimmingView.alpha = 0.0;
        self.contentView.alpha = 0.0;
        [UIView animateWithDuration:.2 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.dimmingView.alpha = 1.0;
            self.contentView.alpha = 1.0;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
        
    } else if (self.animationStyle == QMUIModalPresentationAnimationStylePopup) {
        self.dimmingView.alpha = 0.0;
        self.contentView.transform = CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:.3 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.dimmingView.alpha = 1.0;
            self.contentView.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            self.contentView.transform = CGAffineTransformIdentity;
            if (completion) {
                completion(finished);
            }
        }];
        
    } else if (self.animationStyle == QMUIModalPresentationAnimationStyleSlide) {
        self.dimmingView.alpha = 0.0;
        self.contentView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.view.bounds) - CGRectGetMinY(self.contentView.frame));
        [UIView animateWithDuration:.3 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.dimmingView.alpha = 1.0;
            self.contentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    }
}

- (void)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    // makeKeyAndVisible ????????? viewWillAppear: ?????? animated ??? NO ???????????????????????????????????????????????? animated ??????
    self.appearAnimated = animated;
    self.appearCompletionBlock = completion;
    self.previousKeyWindow = UIApplication.sharedApplication.keyWindow;
    if (!self.containerWindow) {
        self.containerWindow = [[QMUIModalPresentationWindow alloc] init];
        self.containerWindow.qmui_capturesStatusBarAppearance = NO;// modalPrensetationViewController.contentViewController ??????????????????????????????????????????????????????????????????????????????????????????????????? YES
        self.containerWindow.windowLevel = UIWindowLevelQMUIAlertView;
        self.containerWindow.backgroundColor = UIColorClear;// ????????????????????????????????????
    }
    self.containerWindow.rootViewController = self;
    [self.containerWindow makeKeyAndVisible];
}

- (void)hidingAnimationWithCompletion:(void (^)(BOOL))completion {
    if (self.animationStyle == QMUIModalPresentationAnimationStyleFade) {
        [UIView animateWithDuration:.2 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.dimmingView.alpha = 0.0;
            self.contentView.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    } else if (self.animationStyle == QMUIModalPresentationAnimationStylePopup) {
        [UIView animateWithDuration:.3 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.dimmingView.alpha = 0.0;
            self.contentView.transform = CGAffineTransformMakeScale(0.0, 0.0);
        } completion:^(BOOL finished) {
            if (completion) {
                self.contentView.transform = CGAffineTransformIdentity;
                completion(finished);
            }
        }];
    } else if (self.animationStyle == QMUIModalPresentationAnimationStyleSlide) {
        [UIView animateWithDuration:.3 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.dimmingView.alpha = 0.0;
            self.contentView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.view.bounds) - CGRectGetMinY(self.contentView.frame));
        } completion:^(BOOL finished) {
            if (completion) {
                self.contentView.transform = CGAffineTransformIdentity;
                completion(finished);
            }
        }];
    }
}

- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    self.disappearAnimated = animated;
    self.disappearCompletionBlock = completion;
    
    BOOL shouldHide = YES;
    if ([self.delegate respondsToSelector:@selector(shouldHideModalPresentationViewController:)]) {
        shouldHide = [self.delegate shouldHideModalPresentationViewController:self];
    }
    if (!shouldHide) {
        return;
    }
    
    // window??????????????????????????????viewWillDisappear:???????????????????????????
    if (self.shownInWindowMode) {
        [self beginAppearanceTransition:NO animated:animated];
    }
}

- (void)showInView:(UIView *)view animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    self.appearCompletionBlock = completion;
    [self loadViewIfNeeded];
    [self beginAppearanceTransition:YES animated:animated];
    [view addSubview:self.view];
    [self endAppearanceTransition];
}

- (void)hideInView:(UIView *)view animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    self.willHideInView = YES;
    self.disappearCompletionBlock = completion;
    [self beginAppearanceTransition:NO animated:animated];
    self.hasAlreadyViewWillDisappear = YES;
    [self endAppearanceTransition];
}

- (CGRect)contentViewFrameForShowing {
    CGSize contentViewContainerSize = CGSizeMake(CGRectGetWidth(self.view.bounds) - UIEdgeInsetsGetHorizontalValue(self.contentViewMargins), CGRectGetHeight(self.view.bounds) - self.keyboardHeight - UIEdgeInsetsGetVerticalValue(self.contentViewMargins));
    CGSize contentViewLimitSize = CGSizeMake(fmin(self.maximumContentViewWidth, contentViewContainerSize.width), contentViewContainerSize.height);
    CGSize contentViewSize = CGSizeZero;
    if ([self.contentViewController respondsToSelector:@selector(preferredContentSizeInModalPresentationViewController:keyboardHeight:limitSize:)]) {
        contentViewSize = [self.contentViewController preferredContentSizeInModalPresentationViewController:self keyboardHeight:self.keyboardHeight limitSize:contentViewLimitSize];
    } else {
        contentViewSize = [self.contentView sizeThatFits:contentViewLimitSize];
    }
    contentViewSize.width = fmin(contentViewLimitSize.width, contentViewSize.width);
    contentViewSize.height = fmin(contentViewLimitSize.height, contentViewSize.height);
    CGRect contentViewFrame = CGRectMake(CGFloatGetCenter(contentViewContainerSize.width, contentViewSize.width) + self.contentViewMargins.left, CGFloatGetCenter(contentViewContainerSize.height, contentViewSize.height) + self.contentViewMargins.top, contentViewSize.width, contentViewSize.height);
    return contentViewFrame;
}

- (BOOL)isShownInWindowMode {
    return !!self.containerWindow;
}

- (BOOL)isShownInPresentedMode {
    return !self.shownInWindowMode && self.presentingViewController && self.presentingViewController.presentedViewController == self;
}

- (BOOL)isShownInSubviewMode {
    return !self.shownInWindowMode && !self.shownInPresentedMode && self.view.superview;
}

- (BOOL)isShowingPresentedViewController {
    return self.shownInPresentedMode && self.presentedViewController && self.presentedViewController.presentingViewController == self;
}

#pragma mark - <QMUIKeyboardManagerDelegate>

- (void)keyboardWillChangeFrameWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.onlyRespondsToKeyboardEventFromDescendantViews) {
        UIResponder *firstResponder = keyboardUserInfo.targetResponder;
        if (!firstResponder || !([firstResponder isKindOfClass:[UIView class]] && [(UIView *)firstResponder isDescendantOfView:self.view])) {
            return;
        }
    }
    self.keyboardHeight = [keyboardUserInfo heightInView:self.view];
    [self updateLayout];
}

#pragma mark - ????????????

- (BOOL)shouldAutorotate {
    UIViewController *visibleViewController = [QMUIHelper visibleViewController];
    if (visibleViewController != self && [visibleViewController respondsToSelector:@selector(shouldAutorotate)]) {
        return [visibleViewController shouldAutorotate];
    }
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *visibleViewController = [QMUIHelper visibleViewController];
    if (visibleViewController != self && [visibleViewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [visibleViewController supportedInterfaceOrientations];
    }
    return self.supportedOrientationMask;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    if (self.shownInPresentedMode) {
        return self.contentViewController;
    }
    return [super childViewControllerForStatusBarStyle];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    if (self.shownInPresentedMode) {
        return self.contentViewController;
    }
    return [super childViewControllerForStatusBarHidden];
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    if (self.shownInPresentedMode) {
        return self.contentViewController;
    }
    return [super childViewControllerForHomeIndicatorAutoHidden];
}

@end

@implementation QMUIModalPresentationViewController (Manager)

+ (BOOL)isAnyModalPresentationViewControllerVisible {
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        if ([window isKindOfClass:[QMUIModalPresentationWindow class]] && !window.hidden) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)hideAllVisibleModalPresentationViewControllerIfCan {
    
    BOOL hideAllFinally = YES;
    
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        if (![window isKindOfClass:[QMUIModalPresentationWindow class]]) {
            continue;
        }
        
        // ??????modalViewController????????????????????????????????????????????????
        if (window.hidden) {
            continue;
        }
        
        // ??????window???????????????modalViewController?????????????????????window??????
        if (!window.rootViewController) {
            window.hidden = YES;
            continue;
        }
        
        QMUIModalPresentationViewController *modalViewController = (QMUIModalPresentationViewController *)window.rootViewController;
        BOOL canHide = YES;
        if ([modalViewController.delegate respondsToSelector:@selector(shouldHideModalPresentationViewController:)]) {
            canHide = [modalViewController.delegate shouldHideModalPresentationViewController:modalViewController];
        }
        if (canHide) {
            // ?????????????????????????????????????????? QMUIModalPresentationViewController ???????????????????????????????????????????????????????????? hide ?????????????????? QMUIModalPresentationViewController ????????? hideWithAnimated:completion:
            id<QMUIModalPresentationComponentProtocol> modalPresentationComponent = nil;
            if ([modalViewController.contentViewController conformsToProtocol:@protocol(QMUIModalPresentationComponentProtocol)]) {
                modalPresentationComponent = (id<QMUIModalPresentationComponentProtocol>)modalViewController.contentViewController;
            } else if ([modalViewController.contentView conformsToProtocol:@protocol(QMUIModalPresentationComponentProtocol)]) {
                modalPresentationComponent = (id<QMUIModalPresentationComponentProtocol>)modalViewController.contentView;
            }
            if (modalPresentationComponent) {
                [modalPresentationComponent hideModalPresentationComponent];
            } else {
                [modalViewController hideWithAnimated:NO completion:nil];
            }
        } else {
            // ???????????????modalViewController?????????????????????????????????????????????NO
            hideAllFinally = NO;
        }
    }
    
    return hideAllFinally;
}

@end

@implementation QMUIModalPresentationWindow

- (void)layoutSubviews {
    [super layoutSubviews];
    // ???????????????????????? modal ???????????????????????????????????????
    // ?????? iOS 13 ???????????????????????????????????????????????????????????????
    // https://github.com/Tencent/QMUI_iOS/issues/375
    if (@available(iOS 13.0, *)) {
    } else {
        if (self.rootViewController) {
            UIView *rootView = self.rootViewController.view;
            if (CGRectGetMinY(rootView.frame) > 0 && !UIApplication.sharedApplication.statusBarHidden && StatusBarHeight > CGRectGetMinY(rootView.frame)) {
                rootView.frame = self.bounds;
            }
        }
    }

}

@end

@implementation UIViewController (QMUIModalPresentationViewController)

QMUISynthesizeIdWeakProperty(qmui_modalPresentationViewController, setQmui_modalPresentationViewController)

@end
