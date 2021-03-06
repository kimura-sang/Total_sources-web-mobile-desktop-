/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UISearchBar+QMUI.m
//  qmui
//
//  Created by QMUI Team on 16/5/26.
//

#import "UISearchBar+QMUI.h"
#import "QMUICore.h"
#import "UIImage+QMUI.h"
#import "UIView+QMUI.h"

@implementation UISearchBar (QMUI)

QMUISynthesizeBOOLProperty(qmui_usedAsTableHeaderView, setQmui_usedAsTableHeaderView)
QMUISynthesizeUIEdgeInsetsProperty(qmui_textFieldMargins, setQmui_textFieldMargins)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExtendImplementationOfVoidMethodWithTwoArguments([UISearchBar class], @selector(setShowsCancelButton:animated:), BOOL, BOOL, ^(UISearchBar *selfObject, BOOL firstArgv, BOOL secondArgv) {
            if (selfObject.qmui_cancelButton && selfObject.qmui_cancelButtonFont) {
                selfObject.qmui_cancelButton.titleLabel.font = selfObject.qmui_cancelButtonFont;
            }
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UISearchBar class], @selector(setPlaceholder:), NSString *, (^(UISearchBar *selfObject, NSString *placeholder) {
            if (selfObject.qmui_placeholderColor || selfObject.qmui_font) {
                NSMutableAttributedString *string = selfObject.qmui_textField.attributedPlaceholder.mutableCopy;
                if (selfObject.qmui_placeholderColor) {
                    [string addAttribute:NSForegroundColorAttributeName value:selfObject.qmui_placeholderColor range:NSMakeRange(0, string.length)];
                }
                if (selfObject.qmui_font) {
                    [string addAttribute:NSFontAttributeName value:selfObject.qmui_font range:NSMakeRange(0, string.length)];
                }
                // ????????????????????????
                [string removeAttribute:NSShadowAttributeName range:NSMakeRange(0, string.length)];
                selfObject.qmui_textField.attributedPlaceholder = string.copy;
            }
        }));
        
        // iOS 13 ??????UISearchBar ?????? UITextField ??? _placeholderLabel ?????? didMoveToWindow ?????????????????? textColor?????????????????? searchBar ?????????????????????????????? placeholderColor ??????????????????????????????????????????
        // https://github.com/Tencent/QMUI_iOS/issues/830
        if (@available(iOS 13.0, *)) {
            ExtendImplementationOfVoidMethodWithoutArguments([UISearchBar class], @selector(didMoveToWindow), ^(UISearchBar *selfObject) {
                if (selfObject.qmui_placeholderColor) {
                    selfObject.placeholder = selfObject.placeholder;
                }
            });
        }

        if (@available(iOS 13.0, *)) {
            // -[_UISearchBarLayout applyLayout] ??? iOS 13 ????????????????????????????????????????????? -[UISearchBar layoutSubviews] ??????????????????????????????????????????
            Class _UISearchBarLayoutClass = NSClassFromString([NSString stringWithFormat:@"_%@%@",@"UISearchBar", @"Layout"]);
            OverrideImplementation(_UISearchBarLayoutClass, NSSelectorFromString(@"applyLayout"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIView *selfObject) {
                    
                    // call super
                    void (^callSuperBlock)(void) = ^{
                        void (*originSelectorIMP)(id, SEL);
                        originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD);
                    };

                    UISearchBar *searchBar = (UISearchBar *)((UIView *)[selfObject qmui_valueForKey:[NSString stringWithFormat:@"_%@",@"searchBarBackground"]]).superview.superview;
                    
                    NSAssert(searchBar == nil || [searchBar isKindOfClass:[UISearchBar class]], @"not a searchBar");

                    if (searchBar && searchBar.qmui_searchController.isBeingDismissed && searchBar.qmui_usedAsTableHeaderView) {
                        CGRect previousRect = searchBar.qmui_backgroundView.frame;
                        callSuperBlock();
                        // applyLayout ?????????????????? _searchBarBackground  ??? frame ?????????????????? qmui_usedAsTableHeaderView ???????????????????????????????????????????????????
                        searchBar.qmui_backgroundView.frame = previousRect;
                    } else {
                        callSuperBlock();
                    }
                };
                
            });
            
            // iOS 13 ??????cancelButton ??? frame ??? -[_UISearchBarSearchContainerView layoutSubviews] ?????????
            Class _UISearchBarSearchContainerViewClass = NSClassFromString([NSString stringWithFormat:@"_%@%@",@"UISearchBarSearch", @"ContainerView"]);
            ExtendImplementationOfVoidMethodWithoutArguments(_UISearchBarSearchContainerViewClass, @selector(layoutSubviews), ^(UIView *selfObject) {
                UISearchBar *searchBar = (UISearchBar *)selfObject.superview.superview;
                NSAssert(searchBar == nil || [searchBar isKindOfClass:[UISearchBar class]], @"not a searchBar");
                [searchBar qmui_adjustCancelButtonFrameIfNeeded];
            });
        }
        
        Class UISearchBarTextFieldClass = NSClassFromString([NSString stringWithFormat:@"%@%@",@"UISearchBarText", @"Field"]);
        OverrideImplementation(UISearchBarTextFieldClass, @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITextField *textField, CGRect frame) {
                
                UISearchBar *searchBar = nil;
                if (@available(iOS 13.0, *)) {
                    searchBar = (UISearchBar *)textField.superview.superview.superview;
                } else {
                    searchBar = (UISearchBar *)textField.superview.superview;
                }
                
                NSAssert(searchBar == nil || [searchBar isKindOfClass:[UISearchBar class]], @"not a searchBar");
                
                if (searchBar) {
                    frame = [searchBar qmui_adjustedSearchTextFieldFrameByOriginalFrame:frame];
                }
                
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(textField, originCMD, frame);
                
                [searchBar qmui_searchTextFieldFrameDidChange];
            };
        });
        
        
        ExtendImplementationOfVoidMethodWithoutArguments([UISearchBar class], @selector(layoutSubviews), ^(UISearchBar *selfObject) {
            // ?????? iOS 13 backgroundView ??????????????????????????????
            if (IOS_VERSION >= 13.0 && selfObject.qmui_usedAsTableHeaderView && selfObject.qmui_isActive) {
                selfObject.qmui_backgroundView.qmui_height = StatusBarHeightConstant + selfObject.qmui_height;
                selfObject.qmui_backgroundView.qmui_top = -StatusBarHeightConstant;
            }
            [selfObject qmui_adjustCancelButtonFrameIfNeeded];
            [selfObject qmui_fixDismissingAnimationIfNeeded];
            [selfObject qmui_fixSearchResultsScrollViewContentInsetIfNeeded];
            
        });
        
        OverrideImplementation([UISearchBar class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISearchBar *selfObject, CGRect frame) {
                
                frame = [selfObject qmui_adjustedSearchBarFrameByOriginalFrame:frame];
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, frame);
                
            };
        });
    });
}

static char kAssociatedObjectKey_PlaceholderColor;
- (void)setQmui_placeholderColor:(UIColor *)qmui_placeholderColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_PlaceholderColor, qmui_placeholderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.placeholder) {
        // ?????? setPlaceholder ????????? placeholder ???????????????
        self.placeholder = self.placeholder;
    }
}

- (UIColor *)qmui_placeholderColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_PlaceholderColor);
}

static char kAssociatedObjectKey_TextColor;
- (void)setQmui_textColor:(UIColor *)qmui_textColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_TextColor, qmui_textColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_textField.textColor = qmui_textColor;
}

- (UIColor *)qmui_textColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_TextColor);
}

static char kAssociatedObjectKey_font;
- (void)setQmui_font:(UIFont *)qmui_font {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_font, qmui_font, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.placeholder) {
        // ?????? setPlaceholder ????????? placeholder ???????????????
        self.placeholder = self.placeholder;
    }
    
    // ??????????????????????????????
    self.qmui_textField.font = qmui_font;
}

- (UIFont *)qmui_font {
    return (UIFont *)objc_getAssociatedObject(self, &kAssociatedObjectKey_font);
}

- (UITextField *)qmui_textField {
    UITextField *textField = [self qmui_valueForKey:@"searchField"];
    return textField;
}

- (UIButton *)qmui_cancelButton {
    UIButton *cancelButton = [self qmui_valueForKey:@"cancelButton"];
    return cancelButton;
}

static char kAssociatedObjectKey_cancelButtonFont;
- (void)setQmui_cancelButtonFont:(UIFont *)qmui_cancelButtonFont {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_cancelButtonFont, qmui_cancelButtonFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_cancelButton.titleLabel.font = qmui_cancelButtonFont;
}

- (UIFont *)qmui_cancelButtonFont {
    return (UIFont *)objc_getAssociatedObject(self, &kAssociatedObjectKey_cancelButtonFont);
}

- (UISegmentedControl *)qmui_segmentedControl {
    // ?????????segmentedControl ???????????? scopeBar ?????????????????????????????? key ?????????scopeBar???
    UISegmentedControl *segmentedControl = [self qmui_valueForKey:@"scopeBar"];
    return segmentedControl;
}

- (BOOL)qmui_isActive {
    return (self.qmui_searchController.isBeingPresented || self.qmui_searchController.isActive);
}

- (UISearchController *)qmui_searchController {
    return [self qmui_valueForKey:@"_searchController"];
}

- (UIView *)qmui_backgroundView {
    BeginIgnorePerformSelectorLeaksWarning
    UIView *backgroundView = [self performSelector:NSSelectorFromString(@"_backgroundView")];
    EndIgnorePerformSelectorLeaksWarning
    return backgroundView;
}


- (void)qmui_styledAsQMUISearchBar {
    if (!QMUICMIActivated) {
        return;
    }
    
    // ????????????????????? placeholder ?????????
    self.qmui_font = SearchBarFont;

    // ????????????????????????
    self.qmui_textColor = SearchBarTextColor;

    // placeholder ???????????????
    self.qmui_placeholderColor = SearchBarPlaceholderColor;

    self.placeholder = @"??????";
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;

    // ????????????icon
    UIImage *searchIconImage = SearchBarSearchIconImage;
    if (searchIconImage) {
        if (!CGSizeEqualToSize(searchIconImage.size, CGSizeMake(14, 14))) {
            NSLog(@"???????????????????????????SearchBarSearchIconImage????????????????????? (14, 14)??????????????????????????????????????? %@", NSStringFromCGSize(searchIconImage.size));
        }
        [self setImage:searchIconImage forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    }

    // ????????????????????????????????????icon
    UIImage *clearIconImage = SearchBarClearIconImage;
    if (clearIconImage) {
        [self setImage:clearIconImage forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    }

    // ??????SearchBar??????????????????
    self.tintColor = SearchBarTintColor;

    // ??????????????????
    UIImage *searchFieldBackgroundImage = SearchBarTextFieldBackgroundImage;
    if (searchFieldBackgroundImage) {
        [self setSearchFieldBackgroundImage:searchFieldBackgroundImage forState:UIControlStateNormal];
    }
    
    // ???????????????
    UIColor *textFieldBorderColor = SearchBarTextFieldBorderColor;
    if (textFieldBorderColor) {
        self.qmui_textField.layer.borderWidth = PixelOne;
        self.qmui_textField.layer.borderColor = textFieldBorderColor.CGColor;
    }
    
    // ??????bar?????????
    // ????????? searchBar ?????????????????????????????????????????????????????? barTintColor ??????????????????????????? backgroundImage
    UIImage *backgroundImage = SearchBarBackgroundImage;
    if (backgroundImage) {
        [self setBackgroundImage:backgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [self setBackgroundImage:backgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefaultPrompt];
    }
}

+ (UIImage *)qmui_generateTextFieldBackgroundImageWithColor:(UIColor *)color {
    // ?????????????????????????????????????????????????????? iOS 11 ????????????????????????????????? 36???iOS 10 ????????????????????? 28 ?????????????????????????????????:QMUIKit/UIKitExtensions/UISearchBar+QMUI.m
    // ?????????????????????????????? UIView ???????????????????????????????????????
    return [[UIImage qmui_imageWithColor:color size:self.qmui_textFieldDefaultSize cornerRadius:0] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
}

+ (UIImage *)qmui_generateBackgroundImageWithColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor {
    UIImage *backgroundImage = nil;
    if (backgroundColor || borderColor) {
        backgroundImage = [UIImage qmui_imageWithColor:backgroundColor ?: UIColorWhite size:CGSizeMake(10, 10) cornerRadius:0];
        if (borderColor) {
            backgroundImage = [backgroundImage qmui_imageWithBorderColor:borderColor borderWidth:PixelOne borderPosition:QMUIImageBorderPositionBottom];
        }
        backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    }
    return backgroundImage;
}

#pragma mark - Layout Fix

- (BOOL)qmui_shouldFixLayoutWhenUsedAsTableHeaderView {
    if (@available(iOS 11, *)) {
        return self.qmui_usedAsTableHeaderView && self.qmui_searchController.hidesNavigationBarDuringPresentation;
    }
    return NO;
}

- (void)qmui_adjustCancelButtonFrameIfNeeded  {
    if (!self.qmui_shouldFixLayoutWhenUsedAsTableHeaderView) return;
    if ([self qmui_isActive]) {
        CGRect textFieldFrame = self.qmui_textField.frame;
        self.qmui_cancelButton.qmui_top = CGRectGetMinYVerticallyCenter(textFieldFrame, self.qmui_cancelButton.frame);
        if (self.qmui_segmentedControl.superview.qmui_top < self.qmui_textField.qmui_bottom) {
            // scopeBar ????????????????????????
            self.qmui_segmentedControl.superview.qmui_top = CGRectGetMinYVerticallyCenter(textFieldFrame, self.qmui_segmentedControl.superview.frame);
        }
    }
}

- (CGRect)qmui_adjustedSearchBarFrameByOriginalFrame:(CGRect)frame {
    if (!self.qmui_shouldFixLayoutWhenUsedAsTableHeaderView) return frame;
    
    // ?????? setFrame: ??????????????? issue???https://github.com/Tencent/QMUI_iOS/issues/233
    // iOS 11 ?????? tableHeaderView ??????????????? searchBar ?????????????????????????????? y ??????????????????????????????
    // iOS 13 iPad ?????????????????? y ??????????????????????????????
    
    if (self.qmui_searchController.isBeingDismissed && CGRectGetMinY(frame) < 0) {
        frame = CGRectSetY(frame, 0);
    }
    
    if (![self qmui_isActive]) {
        return frame;
    }
    
    if (IS_NOTCHED_SCREEN) {
        // ??????
        if (CGRectGetMinY(frame) == 38) {
            // searching
            frame = CGRectSetY(frame, 44);
        }
        
        // ????????? iPad
        if (CGRectGetMinY(frame) == 18) {
            // searching
            frame = CGRectSetY(frame, 24);
        }
        
        // ??????
        if (CGRectGetMinY(frame) == -6) {
            frame = CGRectSetY(frame, 0);
        }
    } else {
        
        // ??????
        if (CGRectGetMinY(frame) == 14) {
            frame = CGRectSetY(frame, 20);
        }
        
        // ??????
        if (CGRectGetMinY(frame) == -6) {
            frame = CGRectSetY(frame, 0);
        }
    }
    // ???????????????????????? ???????????? 56???????????????????????????????????? (iOS 11 ????????????????????????????????????????????? 50???????????????????????? 55)
    if (frame.size.height != 56) {
        frame.size.height = 56;
    }
    return frame;
}

- (CGRect)qmui_adjustedSearchTextFieldFrameByOriginalFrame:(CGRect)frame {
    if (self.qmui_shouldFixLayoutWhenUsedAsTableHeaderView) {
        if (self.qmui_searchController.isBeingPresented) {
            BOOL statusBarHidden = NO;
            if (@available(iOS 13.0, *)) {
                statusBarHidden = self.window.windowScene.statusBarManager.statusBarHidden;
            } else {
                statusBarHidden = UIApplication.sharedApplication.statusBarHidden;
            }
            CGFloat visibleHeight = statusBarHidden ? 56 : 50;
            frame.origin.y = (visibleHeight - self.qmui_textField.qmui_height) / 2;
        } else if (self.qmui_searchController.isBeingDismissed) {
            frame.origin.y = (56 - self.qmui_textField.qmui_height) / 2;
        }
    }
    
    // apply qmui_textFieldMargins
    if (!UIEdgeInsetsEqualToEdgeInsets(self.qmui_textFieldMargins, UIEdgeInsetsZero)) {
        frame = CGRectInsetEdges(frame, self.qmui_textFieldMargins);
    }
    return frame;
}

- (void)qmui_searchTextFieldFrameDidChange {
    // apply SearchBarTextFieldCornerRadius
    CGFloat textFieldCornerRadius = SearchBarTextFieldCornerRadius;
    if (textFieldCornerRadius != 0) {
        textFieldCornerRadius = textFieldCornerRadius > 0 ? textFieldCornerRadius : CGRectGetHeight(self.qmui_textField.frame) / 2.0;
    }
    self.qmui_textField.layer.cornerRadius = textFieldCornerRadius;
    self.qmui_textField.clipsToBounds = textFieldCornerRadius != 0;
    
    [self qmui_adjustCancelButtonFrameIfNeeded];
}


- (void)qmui_fixDismissingAnimationIfNeeded {
    if (!self.qmui_shouldFixLayoutWhenUsedAsTableHeaderView) return;
    
    if (self.qmui_searchController.isBeingDismissed) {
        
        if (IS_NOTCHED_SCREEN && self.frame.origin.y == 43) { // ????????????????????????????????????????????? pt
            self.frame = CGRectSetY(self.frame, StatusBarHeightConstant);
        }
        
        UIView *searchBarContainerView = self.superview;
        // ????????????????????????searchBarContainerView ????????????????????????
        if (searchBarContainerView.layer.masksToBounds == YES) {
            searchBarContainerView.layer.masksToBounds = NO;
            // backgroundView ??? searchBarContainerView masksToBounds ?????????????????????
            CGFloat backgroundViewBottomClipped = CGRectGetMaxY([searchBarContainerView convertRect:self.qmui_backgroundView.frame fromView:self.qmui_backgroundView.superview]) - CGRectGetHeight(searchBarContainerView.bounds);
            // UISeachbar ???????????????????????? BackgroundView ??????????????? searchBarContainerView???????????????????????????????????????
            if (backgroundViewBottomClipped > 0) {
                CGFloat previousHeight = self.qmui_backgroundView.qmui_height;
                [UIView performWithoutAnimation:^{
                    // ????????? backgroundViewBottomClipped ?????? backgroundView ??? searchBarContainerView ????????????????????????????????????????????? animationBlock ??????????????????????????? performWithoutAnimation ????????????
                    self.qmui_backgroundView.qmui_height -= backgroundViewBottomClipped;
                }];
                // ??????????????????????????? animationBlock ?????????????????????????????????????????????
                self.qmui_backgroundView.qmui_height = previousHeight;
                
                // ?????????????????????????????????????????? mask???????????? NavigationBar ???????????????????????????????????? backgroundView
                CAShapeLayer *maskLayer = [CAShapeLayer layer];
                CGMutablePathRef path = CGPathCreateMutable();
                CGPathAddRect(path, NULL, CGRectMake(0, 0, searchBarContainerView.qmui_width, previousHeight));
                maskLayer.path = path;
                searchBarContainerView.layer.mask = maskLayer;
            }
        }
    }
}

- (void)qmui_fixSearchResultsScrollViewContentInsetIfNeeded {
    if (!self.qmui_shouldFixLayoutWhenUsedAsTableHeaderView) return;
    if (self.qmui_isActive) {
        UIViewController *searchResultsController = self.qmui_searchController.searchResultsController;
        if (searchResultsController && [searchResultsController isViewLoaded]) {
            UIView *view = searchResultsController.view;
            UIScrollView *scrollView =
            [view isKindOfClass:UIScrollView.class] ? view :
            [view.subviews.firstObject isKindOfClass:UIScrollView.class] ? view.subviews.firstObject : nil;
            UIView *searchBarContainerView = self.superview;
            if (scrollView && searchBarContainerView) {
                scrollView.contentInset = UIEdgeInsetsMake(searchBarContainerView.qmui_height, 0, 0, 0);
            }
        }
    }
}

static CGSize textFieldDefaultSize;
+ (CGSize)qmui_textFieldDefaultSize {
    if (CGSizeIsEmpty(textFieldDefaultSize)) {
        textFieldDefaultSize = CGSizeMake(60, 28);
        // ??? iOS 11 ???????????????????????????????????????????????? 36???iOS 10 ????????????????????? 28
        if (@available(iOS 11.0, *)) {
            textFieldDefaultSize.height = 36;
        }
    }
    return textFieldDefaultSize;
}

@end
