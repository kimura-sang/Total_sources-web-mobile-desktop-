/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
//
//  QMUIAnimationHelper.h
//  WeRead
//
//  Created by zhoonchen on 2018/9/3.
//

#import <UIKit/UIKit.h>
#import "QMUIEasings.h"

@interface QMUIAnimationHelper : NSObject

typedef NS_ENUM(NSInteger, QMUIAnimationEasings) {
    QMUIAnimationEasingsLinear,
    QMUIAnimationEasingsEaseInSine,
    QMUIAnimationEasingsEaseOutSine,
    QMUIAnimationEasingsEaseInOutSine,
    QMUIAnimationEasingsEaseInQuad,
    QMUIAnimationEasingsEaseOutQuad,
    QMUIAnimationEasingsEaseInOutQuad,
    QMUIAnimationEasingsEaseInCubic,
    QMUIAnimationEasingsEaseOutCubic,
    QMUIAnimationEasingsEaseInOutCubic,
    QMUIAnimationEasingsEaseInQuart,
    QMUIAnimationEasingsEaseOutQuart,
    QMUIAnimationEasingsEaseInOutQuart,
    QMUIAnimationEasingsEaseInQuint,
    QMUIAnimationEasingsEaseOutQuint,
    QMUIAnimationEasingsEaseInOutQuint,
    QMUIAnimationEasingsEaseInExpo,
    QMUIAnimationEasingsEaseOutExpo,
    QMUIAnimationEasingsEaseInOutExpo,
    QMUIAnimationEasingsEaseInCirc,
    QMUIAnimationEasingsEaseOutCirc,
    QMUIAnimationEasingsEaseInOutCirc,
    QMUIAnimationEasingsEaseInBack,
    QMUIAnimationEasingsEaseOutBack,
    QMUIAnimationEasingsEaseInOutBack,
    QMUIAnimationEasingsEaseInElastic,
    QMUIAnimationEasingsEaseOutElastic,
    QMUIAnimationEasingsEaseInOutElastic,
    QMUIAnimationEasingsEaseInBounce,
    QMUIAnimationEasingsEaseOutBounce,
    QMUIAnimationEasingsEaseInOutBounce,
    QMUIAnimationEasingsSpring, // ???????????????????????????
    QMUIAnimationEasingsSpringKeyboard // ????????????????????????
};

/**
 * ???????????????
 * ??????????????? easing ????????????????????????????????????????????????????????? time ???????????????value ?????????????????? NSNumber???UIColor ?????? NSValue ????????? CGPoint???CGSize???CGRect???CGAffineTransform???UIEdgeInsets
 * @param fromValue ?????????
 * @param toValue ?????????
 * @param time ???????????????
 * @param easing ????????????`QMUIAnimationEasings`
 */
+ (id)interpolateFromValue:(id)fromValue
                   toValue:(id)toValue
                      time:(CGFloat)time
                    easing:(QMUIAnimationEasings)easing;
/**
 * ????????????????????????????????????
 * mass|damping|stiffness|initialVelocity ?????? QMUIAnimationEasingsSpring ??????????????????
 */
+ (id)interpolateSpringFromValue:(id)fromValue
                         toValue:(id)toValue
                            time:(CGFloat)time
                            mass:(CGFloat)mass
                         damping:(CGFloat)damping
                       stiffness:(CGFloat)stiffness
                 initialVelocity:(CGFloat)initialVelocity
                          easing:(QMUIAnimationEasings)easing;

@end
