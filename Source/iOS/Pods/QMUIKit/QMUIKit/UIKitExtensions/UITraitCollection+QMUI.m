/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
//
//  UITraitCollection+QMUI.m
//  QMUIKit
//
//  Created by ziezheng on 2019/7/19.
//

#import "UITraitCollection+QMUI.h"
#import "QMUICore.h"

NSNotificationName const QMUIUserInterfaceStyleWillChangeNotification = @"QMUIUserInterfaceStyleWillChangeNotification";

@implementation UIWindow (QMUIUserInterfaceStyleWillChangeNotification)

#ifdef IOS13_SDK_ALLOWED
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 13.0, *)) {
            static UIUserInterfaceStyle qmui_lastNotifiedUserInterfaceStyle;
            qmui_lastNotifiedUserInterfaceStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
            OverrideImplementation([UIWindow class] , @selector(traitCollection), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UITraitCollection *(UIWindow *selfObject) {
                    
                    id (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (id (*)(id, SEL))originalIMPProvider();
                    UITraitCollection *traitCollection = originSelectorIMP(selfObject, originCMD);
                    
                    BOOL snapshotFinishedOnBackground = traitCollection.userInterfaceLevel == UIUserInterfaceLevelElevated && UIApplication.sharedApplication.applicationState == UIApplicationStateBackground;
                     // ??????????????????????????????????????????????????? style ??????????????? iOS 13.0 iPad ??????????????????????????????????????????????????? style????????????????????????????????????????????????????????????
                    if (selfObject.windowScene && !snapshotFinishedOnBackground) {
                        NSPointerArray *windows = [[selfObject windowScene] valueForKeyPath:@"_contextBinder._attachedBindables"];
                        // ????????????????????????????????????????????? window ??? traitCollection???????????????????????????????????? window
                        UIWindow *firstValidatedWindow = nil;
                        for (NSUInteger i = 0, count = windows.count; i < count; i++) {
                            UIWindow *window = [windows pointerAtIndex:i];
                            // ?????? Keyboard ???????????? keyboardAppearance ????????? userInterfaceStyle ??? Dark/Light????????????????????????????????????????????????
                            if ([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")] || [window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")]) {
                                continue;
                            }
                            if (window.overrideUserInterfaceStyle != UIUserInterfaceStyleUnspecified) {
                                QMUILogWarn(@"UITraitCollection+QMUI", @"?????? : %@ ????????? overrideUserInterfaceStyle ???????????????????????? QMUIUserInterfaceStyleWillChangeNotification ?????????", selfObject);
                                continue;
                            }
                            firstValidatedWindow = window;
                            break;
                        }
                        if (selfObject == firstValidatedWindow) {
                            if (qmui_lastNotifiedUserInterfaceStyle != traitCollection.userInterfaceStyle) {
                                qmui_lastNotifiedUserInterfaceStyle = traitCollection.userInterfaceStyle;
                                [[NSNotificationCenter defaultCenter] postNotificationName:QMUIUserInterfaceStyleWillChangeNotification object:traitCollection];
                            }
                        }
                    }
                    return traitCollection;
                    
                };
            });
        }
    });
}
#endif

@end
