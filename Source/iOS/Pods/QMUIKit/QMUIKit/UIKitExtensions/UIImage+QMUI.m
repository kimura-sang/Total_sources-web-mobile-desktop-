/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UIImage+QMUI.m
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import "UIImage+QMUI.h"
#import "QMUICore.h"
#import "UIBezierPath+QMUI.h"
#import "UIColor+QMUI.h"
#import "QMUILog.h"
#import <Accelerate/Accelerate.h>

CG_INLINE CGSize
CGSizeFlatSpecificScale(CGSize size, float scale) {
    return CGSizeMake(flatSpecificScale(size.width, scale), flatSpecificScale(size.height, scale));
}

@implementation UIImage (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExtendImplementationOfNonVoidMethodWithoutArguments([UIImage class], @selector(description), NSString *, ^NSString *(UIImage *selfObject, NSString *originReturnValue) {
            return ([NSString stringWithFormat:@"%@, scale = %@", originReturnValue, @(selfObject.scale)]);
        });
        
        OverrideImplementation([UIImage class], @selector(resizableImageWithCapInsets:resizingMode:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIImage *(UIImage *selfObject, UIEdgeInsets capInsets, UIImageResizingMode resizingMode) {
                
                if (!CGSizeIsEmpty(selfObject.size) && (UIEdgeInsetsGetHorizontalValue(capInsets) >= selfObject.size.width || UIEdgeInsetsGetVerticalValue(capInsets) >= selfObject.size.height)) {
                    // ???????????????????????????????????? capInsets ??????
                    QMUILogWarn(@"UIImage (QMUI)", @"UIImage (QMUI) resizableImageWithCapInsets ???????????? capInsets ?????????/????????????????????????????????????????????????????????????????????? render ????????? invalid context 0x0 ????????????");
                }
                
                // call super
                UIImage *(*originSelectorIMP)(id, SEL, UIEdgeInsets, UIImageResizingMode);
                originSelectorIMP = (UIImage *(*)(id, SEL, UIEdgeInsets, UIImageResizingMode))originalIMPProvider();
                UIImage *result = originSelectorIMP(selfObject, originCMD, capInsets, resizingMode);
                
                return result;
            };
        });
    });
}

+ (UIImage *)qmui_imageWithSize:(CGSize)size opaque:(BOOL)opaque scale:(CGFloat)scale actions:(void (^)(CGContextRef contextRef))actionBlock {
    if (!actionBlock || CGSizeIsEmpty(size)) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextInspectContext(context);
    actionBlock(context);
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageOut;
}

- (CGSize)qmui_sizeInPixel {
    CGSize size = CGSizeMake(self.size.width * self.scale, self.size.height * self.scale);
    return size;
}

- (BOOL)qmui_opaque {
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
    BOOL opaque = alphaInfo == kCGImageAlphaNoneSkipLast
    || alphaInfo == kCGImageAlphaNoneSkipFirst
    || alphaInfo == kCGImageAlphaNone;
    return opaque;
}

- (UIColor *)qmui_averageColor {
	unsigned char rgba[4] = {};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGContextInspectContext(context);
	CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
	CGColorSpaceRelease(colorSpace);
	CGContextRelease(context);
	if(rgba[3] > 0) {
		return [UIColor colorWithRed:((CGFloat)rgba[0] / rgba[3])
			                   green:((CGFloat)rgba[1] / rgba[3])
			                    blue:((CGFloat)rgba[2] / rgba[3])
			                   alpha:((CGFloat)rgba[3] / 255.0)];
	} else {
		return [UIColor colorWithRed:((CGFloat)rgba[0]) / 255.0
                               green:((CGFloat)rgba[1]) / 255.0
								blue:((CGFloat)rgba[2]) / 255.0
							   alpha:((CGFloat)rgba[3]) / 255.0];
	}
}

- (UIImage *)qmui_grayImage {
    // CGBitmapContextCreate ??????????????????????????????????????????1???
    CGSize size = self.qmui_sizeInPixel;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGBitmapByteOrderDefault);
    CGContextInspectContext(context);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGRect imageRect = CGRectMakeWithSize(size);
    CGContextDrawImage(context, imageRect, self.CGImage);
    
    UIImage *grayImage = nil;
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    if (self.qmui_opaque) {
        grayImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    } else {
        CGContextRef alphaContext = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, nil, kCGImageAlphaOnly);
        CGContextDrawImage(alphaContext, imageRect, self.CGImage);
        CGImageRef mask = CGBitmapContextCreateImage(alphaContext);
		CGImageRef maskedGrayImageRef = CGImageCreateWithMask(imageRef, mask);
        grayImage = [UIImage imageWithCGImage:maskedGrayImageRef scale:self.scale orientation:self.imageOrientation];
        CGImageRelease(mask);
		CGImageRelease(maskedGrayImageRef);
        CGContextRelease(alphaContext);
        
        // ??? CGBitmapContextCreateImage ??????????????????????????????CGImageAlphaInfo ????????? CGImageAlphaInfoNone????????? qmui_opaque ????????????????????????????????????????????????
        grayImage = [UIImage qmui_imageWithSize:grayImage.size opaque:NO scale:grayImage.scale actions:^(CGContextRef contextRef) {
            [grayImage drawInRect:imageRect];
        }];
    }
    
    CGContextRelease(context);
    CGImageRelease(imageRef);
    return grayImage;
}

- (UIImage *)qmui_imageWithAlpha:(CGFloat)alpha {
    return [UIImage qmui_imageWithSize:self.size opaque:NO scale:self.scale actions:^(CGContextRef contextRef) {
        [self drawInRect:CGRectMakeWithSize(self.size) blendMode:kCGBlendModeNormal alpha:alpha];
    }];
}

- (UIImage *)qmui_imageWithTintColor:(UIColor *)tintColor {
    // iOS 13 ??? imageWithTintColor: ??????????????????????????? CGImage????????????????????????????????????????????????????????? CGImage ????????????????????????????????????
//#ifdef IOS13_SDK_ALLOWED
//    if (@available(iOS 13.0, *)) {
//        return [self imageWithTintColor:tintColor];
//    }
//#endif
    return [UIImage qmui_imageWithSize:self.size opaque:self.qmui_opaque scale:self.scale actions:^(CGContextRef contextRef) {
        CGContextTranslateCTM(contextRef, 0, self.size.height);
        CGContextScaleCTM(contextRef, 1.0, -1.0);
        CGContextSetBlendMode(contextRef, kCGBlendModeNormal);
        CGContextClipToMask(contextRef, CGRectMakeWithSize(self.size), self.CGImage);
        CGContextSetFillColorWithColor(contextRef, tintColor.CGColor);
        CGContextFillRect(contextRef, CGRectMakeWithSize(self.size));
    }];
}

- (UIImage *)qmui_imageWithBlendColor:(UIColor *)blendColor {
    UIImage *coloredImage = [self qmui_imageWithTintColor:blendColor];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorBlendMode"];
    [filter setValue:[CIImage imageWithCGImage:self.CGImage] forKey:kCIInputBackgroundImageKey];
    [filter setValue:[CIImage imageWithCGImage:coloredImage.CGImage] forKey:kCIInputImageKey];
    CIImage *outputImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:outputImage fromRect:outputImage.extent];
    UIImage *resultImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return resultImage;
}

- (UIImage *)qmui_imageWithImageAbove:(UIImage *)image atPoint:(CGPoint)point {
    return [UIImage qmui_imageWithSize:self.size opaque:self.qmui_opaque scale:self.scale actions:^(CGContextRef contextRef) {
        [self drawInRect:CGRectMakeWithSize(self.size)];
        [image drawAtPoint:point];
    }];
}

- (UIImage *)qmui_imageWithSpacingExtensionInsets:(UIEdgeInsets)extension {
    CGSize contextSize = CGSizeMake(self.size.width + UIEdgeInsetsGetHorizontalValue(extension), self.size.height + UIEdgeInsetsGetVerticalValue(extension));
    return [UIImage qmui_imageWithSize:contextSize opaque:self.qmui_opaque scale:self.scale actions:^(CGContextRef contextRef) {
        [self drawAtPoint:CGPointMake(extension.left, extension.top)];
    }];
}

- (UIImage *)qmui_imageWithClippedRect:(CGRect)rect {
    CGContextInspectSize(rect.size);
    CGRect imageRect = CGRectMakeWithSize(self.size);
    if (CGRectContainsRect(rect, imageRect)) {
        // ???????????????????????????????????????????????????????????????????????????
        return self;
    }
    // ??????CGImage??????pixel???????????????????????????UIImage??????point?????????????????????????????????????????????point?????????pixel
    CGRect scaledRect = CGRectApplyScale(rect, self.scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, scaledRect);
    UIImage *imageOut = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return imageOut;
}

- (UIImage *)qmui_imageWithClippedCornerRadius:(CGFloat)cornerRadius {
    return [self qmui_imageWithClippedCornerRadius:cornerRadius scale:self.scale];
}

- (UIImage *)qmui_imageWithClippedCornerRadius:(CGFloat)cornerRadius scale:(CGFloat)scale {
    if (cornerRadius <= 0) {
        return self;
    }
    return [UIImage qmui_imageWithSize:self.size opaque:NO scale:scale actions:^(CGContextRef contextRef) {
        [[UIBezierPath bezierPathWithRoundedRect:CGRectMakeWithSize(self.size) cornerRadius:cornerRadius] addClip];
        [self drawInRect:CGRectMakeWithSize(self.size)];
    }];
}

- (UIImage *)qmui_imageResizedInLimitedSize:(CGSize)size {
    return [self qmui_imageResizedInLimitedSize:size resizingMode:QMUIImageResizingModeScaleAspectFit];
}

- (UIImage *)qmui_imageResizedInLimitedSize:(CGSize)size resizingMode:(QMUIImageResizingMode)resizingMode {
    return [self qmui_imageResizedInLimitedSize:size resizingMode:resizingMode scale:self.scale];
}

- (UIImage *)qmui_imageResizedInLimitedSize:(CGSize)size resizingMode:(QMUIImageResizingMode)resizingMode scale:(CGFloat)scale {
    size = CGSizeFlatSpecificScale(size, scale);
    CGSize imageSize = self.size;
    CGRect drawingRect = CGRectZero;// ??????????????? rect
    CGSize contextSize = CGSizeZero;// ???????????????
    
    if (CGSizeEqualToSize(size, imageSize) && scale == self.scale) {
        return self;
    }
    
    if (resizingMode >= QMUIImageResizingModeScaleAspectFit && resizingMode <= QMUIImageResizingModeScaleAspectFillBottom) {
        CGFloat horizontalRatio = size.width / imageSize.width;
        CGFloat verticalRatio = size.height / imageSize.height;
        CGFloat ratio = 0;
        if (resizingMode >= QMUIImageResizingModeScaleAspectFill && resizingMode < (QMUIImageResizingModeScaleAspectFill + 10)) {
            ratio = MAX(horizontalRatio, verticalRatio);
        } else {
            // ????????? QMUIImageResizingModeScaleAspectFit
            ratio = MIN(horizontalRatio, verticalRatio);
        }
        CGSize resizedSize = CGSizeMake(flatSpecificScale(imageSize.width * ratio, scale), flatSpecificScale(imageSize.height * ratio, scale));
        contextSize = CGSizeMake(MIN(size.width, resizedSize.width), MIN(size.height, resizedSize.height));
        drawingRect.origin.x = CGFloatGetCenter(contextSize.width, resizedSize.width);
        
        CGFloat originY = 0;
        if (resizingMode % 10 == 1) {
            // toTop
            originY = 0;
        } else if (resizingMode % 10 == 2) {
            // toBottom
            originY = contextSize.height - resizedSize.height;
        } else {
            // default is Center
            originY = CGFloatGetCenter(contextSize.height, resizedSize.height);
        }
        drawingRect.origin.y = originY;
        
        drawingRect.size = resizedSize;
    } else {
        // ???????????? QMUIImageResizingModeScaleToFill
        drawingRect = CGRectMakeWithSize(size);
        contextSize = size;
    }
    
    return [UIImage qmui_imageWithSize:contextSize opaque:self.qmui_opaque scale:scale actions:^(CGContextRef contextRef) {
        [self drawInRect:drawingRect];
    }];
}

- (UIImage *)qmui_imageWithOrientation:(UIImageOrientation)orientation {
    if (orientation == UIImageOrientationUp) {
        return self;
    }
    
    CGSize contextSize = self.size;
    if (orientation == UIImageOrientationLeft || orientation == UIImageOrientationRight) {
        contextSize = CGSizeMake(contextSize.height, contextSize.width);
    }
    
    contextSize = CGSizeFlatSpecificScale(contextSize, self.scale);
    
    return [UIImage qmui_imageWithSize:contextSize opaque:NO scale:self.scale actions:^(CGContextRef contextRef) {
        // ??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
        switch (orientation) {
            case UIImageOrientationUp:
                // ???
                break;
            case UIImageOrientationDown:
                // ???
                CGContextTranslateCTM(contextRef, contextSize.width, contextSize.height);
                CGContextRotateCTM(contextRef, AngleWithDegrees(180));
                break;
            case UIImageOrientationLeft:
                // ???
                CGContextTranslateCTM(contextRef, 0, contextSize.height);
                CGContextRotateCTM(contextRef, AngleWithDegrees(-90));
                break;
            case UIImageOrientationRight:
                // ???
                CGContextTranslateCTM(contextRef, contextSize.width, 0);
                CGContextRotateCTM(contextRef, AngleWithDegrees(90));
                break;
            case UIImageOrientationUpMirrored:
            case UIImageOrientationDownMirrored:
                // ?????????????????????????????????
                CGContextTranslateCTM(contextRef, 0, contextSize.height);
                CGContextScaleCTM(contextRef, 1, -1);
                break;
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRightMirrored:
                // ?????????????????????????????????
                CGContextTranslateCTM(contextRef, contextSize.width, 0);
                CGContextScaleCTM(contextRef, -1, 1);
                break;
        }
        
        // ????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
        [self drawInRect:CGRectMakeWithSize(self.size)];
    }];
}

- (UIImage *)qmui_imageWithBorderColor:(UIColor *)borderColor path:(UIBezierPath *)path {
    if (!borderColor) {
        return self;
    }
    
    return [UIImage qmui_imageWithSize:self.size opaque:self.qmui_opaque scale:self.scale actions:^(CGContextRef contextRef) {
        [self drawInRect:CGRectMakeWithSize(self.size)];
        CGContextSetStrokeColorWithColor(contextRef, borderColor.CGColor);
        [path stroke];
    }];
}

- (UIImage *)qmui_imageWithBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius {
    return [self qmui_imageWithBorderColor:borderColor borderWidth:borderWidth cornerRadius:cornerRadius dashedLengths:0];
}

- (UIImage *)qmui_imageWithBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius dashedLengths:(const CGFloat *)dashedLengths {
    if (!borderColor || !borderWidth) {
        return self;
    }
    
    UIBezierPath *path;
    CGRect rect = CGRectInset(CGRectMake(0, 0, self.size.width, self.size.height), borderWidth / 2, borderWidth / 2);// ??????rect??????????????????????????????????????????
    if (cornerRadius > 0) {
        path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    } else {
        path = [UIBezierPath bezierPathWithRect:rect];
    }
    
    path.lineWidth = borderWidth;
    if (dashedLengths) {
        [path setLineDash:dashedLengths count:2 phase:0];
    }
    return [self qmui_imageWithBorderColor:borderColor path:path];
}

- (UIImage *)qmui_imageWithBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth borderPosition:(QMUIImageBorderPosition)borderPosition {
    if (borderPosition == QMUIImageBorderPositionAll) {
        return [self qmui_imageWithBorderColor:borderColor borderWidth:borderWidth cornerRadius:0];
    } else {
        // TODO ??????bezierPathWithRoundedRect:byRoundingCorners:cornerRadii:??????????????????
        UIBezierPath* path = [UIBezierPath bezierPath];
        if ((QMUIImageBorderPositionBottom & borderPosition) == QMUIImageBorderPositionBottom) {
            [path moveToPoint:CGPointMake(0, self.size.height - borderWidth / 2)];
            [path addLineToPoint:CGPointMake(self.size.width, self.size.height - borderWidth / 2)];
        }
        if ((QMUIImageBorderPositionTop & borderPosition) == QMUIImageBorderPositionTop) {
            [path moveToPoint:CGPointMake(0, borderWidth / 2)];
            [path addLineToPoint:CGPointMake(self.size.width, borderWidth / 2)];
        }
        if ((QMUIImageBorderPositionLeft & borderPosition) == QMUIImageBorderPositionLeft) {
            [path moveToPoint:CGPointMake(borderWidth / 2, 0)];
            [path addLineToPoint:CGPointMake(borderWidth / 2, self.size.height)];
        }
        if ((QMUIImageBorderPositionRight & borderPosition) == QMUIImageBorderPositionRight) {
            [path moveToPoint:CGPointMake(self.size.width - borderWidth / 2, 0)];
            [path addLineToPoint:CGPointMake(self.size.width - borderWidth / 2, self.size.height)];
        }
        [path setLineWidth:borderWidth];
        [path closePath];
        return [self qmui_imageWithBorderColor:borderColor path:path];
    }
    return self;
}

- (UIImage *)qmui_imageWithMaskImage:(UIImage *)maskImage usingMaskImageMode:(BOOL)usingMaskImageMode {
    CGImageRef maskRef = [maskImage CGImage];
    CGImageRef mask;
    if (usingMaskImageMode) {
        // ???CGImageMaskCreate??????????????? image mask???
        // ?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
        mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                 CGImageGetHeight(maskRef),
                                 CGImageGetBitsPerComponent(maskRef),
                                 CGImageGetBitsPerPixel(maskRef),
                                 CGImageGetBytesPerRow(maskRef),
                                 CGImageGetDataProvider(maskRef), nil, YES);
    } else {
        // ????????????CGImage??????mask?????????image???????????????(???????????????????????????)?????????alpha??????????????????????????????mask?????????????????????If `mask' is an image, then it must be in a monochrome color space (e.g. DeviceGray, GenericGray, etc...), may not have alpha, and may not itself be masked by an image mask or a masking color.
        // ?????????????????????????????????????????????????????????????????????????????????????????????????????????
         mask = maskRef;
    }
    CGImageRef maskedImage = CGImageCreateWithMask(self.CGImage, mask);
    UIImage *returnImage = [UIImage imageWithCGImage:maskedImage scale:self.scale orientation:self.imageOrientation];
    if (usingMaskImageMode) {
        CGImageRelease(mask);
    }
    CGImageRelease(maskedImage);
    return returnImage;
}

+ (UIImage *)qmui_animatedImageWithData:(NSData *)data {
    return [self qmui_animatedImageWithData:data scale:1];
}

+ (UIImage *)qmui_animatedImageWithData:(NSData *)data scale:(CGFloat)scale {
    // http://www.jianshu.com/p/767af9c690a3
    // https://github.com/rs/SDWebImage
    if (!data) {
        return nil;
    }
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t count = CGImageSourceGetCount(source);
    UIImage *animatedImage = nil;
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    } else {
        NSMutableArray<UIImage *> *images = [[NSMutableArray alloc] init];
        NSTimeInterval duration = 0.0f;
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            duration += [self qmui_frameDurationAtIndex:i source:source];
            UIImage *frameImage = [UIImage imageWithCGImage:image scale:scale == 0 ? ScreenScale : scale orientation:UIImageOrientationUp];
            [images addObject:frameImage];
            CGImageRelease(image);
        }
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    CFRelease(source);
    return animatedImage;
}

+ (float)qmui_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary<NSString *, NSDictionary *> *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary<NSString *, NSNumber *> *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    } else {
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    CFRelease(cfFrameProperties);
    return frameDuration;
}

+ (UIImage *)qmui_animatedImageNamed:(NSString *)name {
    return [UIImage qmui_animatedImageNamed:name scale:1];
}

+ (UIImage *)qmui_animatedImageNamed:(NSString *)name scale:(CGFloat)scale {
    NSString *type = name.pathExtension.lowercaseString;
    type = type.length > 0 ? type : @"gif";
    NSString *path = [[NSBundle mainBundle] pathForResource:name.stringByDeletingPathExtension ofType:type];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [UIImage qmui_animatedImageWithData:data scale:scale];
}

+ (UIImage *)qmui_imageWithStrokeColor:(UIColor *)strokeColor size:(CGSize)size path:(UIBezierPath *)path addClip:(BOOL)addClip {
    size = CGSizeFlatted(size);
    return [UIImage qmui_imageWithSize:size opaque:NO scale:0 actions:^(CGContextRef contextRef) {
        CGContextSetStrokeColorWithColor(contextRef, strokeColor.CGColor);
        if (addClip) [path addClip];
        [path stroke];
    }];
}

+ (UIImage *)qmui_imageWithStrokeColor:(UIColor *)strokeColor size:(CGSize)size lineWidth:(CGFloat)lineWidth cornerRadius:(CGFloat)cornerRadius {
    CGContextInspectSize(size);
    // ?????????????????????lineWidth?????????stroke???????????????????????????????????????
    // ??????cornerRadius???0???????????????bezierPathWithRoundedRect:cornerRadius:???????????????????????????????????????????????????????????????
    UIBezierPath *path;
    CGRect rect = CGRectInset(CGRectMakeWithSize(size), lineWidth / 2, lineWidth / 2);
    if (cornerRadius > 0) {
        path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    } else {
        path = [UIBezierPath bezierPathWithRect:rect];
    }
    [path setLineWidth:lineWidth];
    return [UIImage qmui_imageWithStrokeColor:strokeColor size:size path:path addClip:NO];
}

+ (UIImage *)qmui_imageWithStrokeColor:(UIColor *)strokeColor size:(CGSize)size lineWidth:(CGFloat)lineWidth borderPosition:(QMUIImageBorderPosition)borderPosition {
    CGContextInspectSize(size);
    if (borderPosition == QMUIImageBorderPositionAll) {
        return [UIImage qmui_imageWithStrokeColor:strokeColor size:size lineWidth:lineWidth cornerRadius:0];
    } else {
        // TODO ??????bezierPathWithRoundedRect:byRoundingCorners:cornerRadii:??????????????????
        UIBezierPath* path = [UIBezierPath bezierPath];
        if ((QMUIImageBorderPositionBottom & borderPosition) == QMUIImageBorderPositionBottom) {
            [path moveToPoint:CGPointMake(0, size.height - lineWidth / 2)];
            [path addLineToPoint:CGPointMake(size.width, size.height - lineWidth / 2)];
        }
        if ((QMUIImageBorderPositionTop & borderPosition) == QMUIImageBorderPositionTop) {
            [path moveToPoint:CGPointMake(0, lineWidth / 2)];
            [path addLineToPoint:CGPointMake(size.width, lineWidth / 2)];
        }
        if ((QMUIImageBorderPositionLeft & borderPosition) == QMUIImageBorderPositionLeft) {
            [path moveToPoint:CGPointMake(lineWidth / 2, 0)];
            [path addLineToPoint:CGPointMake(lineWidth / 2, size.height)];
        }
        if ((QMUIImageBorderPositionRight & borderPosition) == QMUIImageBorderPositionRight) {
            [path moveToPoint:CGPointMake(size.width - lineWidth / 2, 0)];
            [path addLineToPoint:CGPointMake(size.width - lineWidth / 2, size.height)];
        }
        [path setLineWidth:lineWidth];
        [path closePath];
        return [UIImage qmui_imageWithStrokeColor:strokeColor size:size path:path addClip:NO];
    }
}

+ (UIImage *)qmui_imageWithColor:(UIColor *)color {
    return [UIImage qmui_imageWithColor:color size:CGSizeMake(4, 4) cornerRadius:0];
}

+ (UIImage *)qmui_imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius {
    size = CGSizeFlatted(size);
    CGContextInspectSize(size);
    
    color = color ? color : UIColorClear;
	BOOL opaque = (cornerRadius == 0.0 && [color qmui_alpha] == 1.0);
    return [UIImage qmui_imageWithSize:size opaque:opaque scale:0 actions:^(CGContextRef contextRef) {
        CGContextSetFillColorWithColor(contextRef, color.CGColor);
        
        if (cornerRadius > 0) {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMakeWithSize(size) cornerRadius:cornerRadius];
            [path addClip];
            [path fill];
        } else {
            CGContextFillRect(contextRef, CGRectMakeWithSize(size));
        }
    }];
}

+ (UIImage *)qmui_imageWithColor:(UIColor *)color size:(CGSize)size cornerRadiusArray:(NSArray<NSNumber *> *)cornerRadius {
    size = CGSizeFlatted(size);
    CGContextInspectSize(size);
    color = color ? color : UIColorWhite;
    return [UIImage qmui_imageWithSize:size opaque:NO scale:0 actions:^(CGContextRef contextRef) {
        
        CGContextSetFillColorWithColor(contextRef, color.CGColor);
        
        UIBezierPath *path = [UIBezierPath qmui_bezierPathWithRoundedRect:CGRectMakeWithSize(size) cornerRadiusArray:cornerRadius lineWidth:0];
        [path addClip];
        [path fill];
    }];
}

+ (UIImage *)qmui_imageWithShape:(QMUIImageShape)shape size:(CGSize)size lineWidth:(CGFloat)lineWidth tintColor:(UIColor *)tintColor {
    size = CGSizeFlatted(size);
    CGContextInspectSize(size);
    
    tintColor = tintColor ? : [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    
    return [UIImage qmui_imageWithSize:size opaque:NO scale:0 actions:^(CGContextRef contextRef) {
        UIBezierPath *path = nil;
        BOOL drawByStroke = NO;
        CGFloat drawOffset = lineWidth / 2;
        switch (shape) {
            case QMUIImageShapeOval: {
                path = [UIBezierPath bezierPathWithOvalInRect:CGRectMakeWithSize(size)];
            }
                break;
            case QMUIImageShapeTriangle: {
                path = [UIBezierPath bezierPath];
                [path moveToPoint:CGPointMake(0, size.height)];
                [path addLineToPoint:CGPointMake(size.width / 2, 0)];
                [path addLineToPoint:CGPointMake(size.width, size.height)];
                [path closePath];
            }
                break;
            case QMUIImageShapeNavBack: {
                drawByStroke = YES;
                path = [UIBezierPath bezierPath];
                path.lineWidth = lineWidth;
                [path moveToPoint:CGPointMake(size.width - drawOffset, drawOffset)];
                [path addLineToPoint:CGPointMake(0 + drawOffset, size.height / 2.0)];
                [path addLineToPoint:CGPointMake(size.width - drawOffset, size.height - drawOffset)];
            }
                break;
            case QMUIImageShapeDisclosureIndicator: {
                drawByStroke = YES;
                path = [UIBezierPath bezierPath];
                path.lineWidth = lineWidth;
                [path moveToPoint:CGPointMake(drawOffset, drawOffset)];
                [path addLineToPoint:CGPointMake(size.width - drawOffset, size.height / 2)];
                [path addLineToPoint:CGPointMake(drawOffset, size.height - drawOffset)];
            }
                break;
            case QMUIImageShapeCheckmark: {
                CGFloat lineAngle = M_PI_4;
                path = [UIBezierPath bezierPath];
                [path moveToPoint:CGPointMake(0, size.height / 2)];
                [path addLineToPoint:CGPointMake(size.width / 3, size.height)];
                [path addLineToPoint:CGPointMake(size.width, lineWidth * sin(lineAngle))];
                [path addLineToPoint:CGPointMake(size.width - lineWidth * cos(lineAngle), 0)];
                [path addLineToPoint:CGPointMake(size.width / 3, size.height - lineWidth / sin(lineAngle))];
                [path addLineToPoint:CGPointMake(lineWidth * sin(lineAngle), size.height / 2 - lineWidth * sin(lineAngle))];
                [path closePath];
            }
                break;
            case QMUIImageShapeDetailButtonImage: {
                drawByStroke = YES;
                path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(CGRectMakeWithSize(size), drawOffset, drawOffset)];
                path.lineWidth = lineWidth;
            }
                break;
            case QMUIImageShapeNavClose: {
                drawByStroke = YES;
                path = [UIBezierPath bezierPath];
                [path moveToPoint:CGPointMake(0, 0)];
                [path addLineToPoint:CGPointMake(size.width, size.height)];
                [path closePath];
                [path moveToPoint:CGPointMake(size.width, 0)];
                [path addLineToPoint:CGPointMake(0, size.height)];
                [path closePath];
                path.lineWidth = lineWidth;
                path.lineCapStyle = kCGLineCapRound;
            }
                break;
            default:
                break;
        }
        
        if (drawByStroke) {
            CGContextSetStrokeColorWithColor(contextRef, tintColor.CGColor);
            [path stroke];
        } else {
            CGContextSetFillColorWithColor(contextRef, tintColor.CGColor);
            [path fill];
        }
        
        if (shape == QMUIImageShapeDetailButtonImage) {
            CGFloat fontPointSize = flat(size.height * 0.8);
            UIFont *font = [UIFont fontWithName:@"Georgia" size:fontPointSize];
            NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"i" attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: tintColor}];
            CGSize stringSize = [string boundingRectWithSize:size options:NSStringDrawingUsesFontLeading context:nil].size;
            [string drawAtPoint:CGPointMake(CGFloatGetCenter(size.width, stringSize.width), CGFloatGetCenter(size.height, stringSize.height))];
        }
    }];
}

+ (UIImage *)qmui_imageWithShape:(QMUIImageShape)shape size:(CGSize)size tintColor:(UIColor *)tintColor {
    CGFloat lineWidth = 0;
    switch (shape) {
        case QMUIImageShapeNavBack:
            lineWidth = 2.0f;
            break;
        case QMUIImageShapeDisclosureIndicator:
            lineWidth = 1.5f;
            break;
        case QMUIImageShapeCheckmark:
            lineWidth = 1.5f;
            break;
        case QMUIImageShapeDetailButtonImage:
            lineWidth = 1.0f;
            break;
        case QMUIImageShapeNavClose:
            lineWidth = 1.2f;   // ??????icon?????????lineWidth
            break;
        default:
            break;
    }
    return [UIImage qmui_imageWithShape:shape size:size lineWidth:lineWidth tintColor:tintColor];
}

+ (UIImage *)qmui_imageWithAttributedString:(NSAttributedString *)attributedString {
    CGSize stringSize = [attributedString boundingRectWithSize:CGSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    stringSize = CGSizeCeil(stringSize);
    return [UIImage qmui_imageWithSize:stringSize opaque:NO scale:0 actions:^(CGContextRef contextRef) {
        [attributedString drawInRect:CGRectMakeWithSize(stringSize)];
    }];
}

+ (UIImage *)qmui_imageWithView:(UIView *)view {
    CGContextInspectSize(view.bounds.size);
    return [UIImage qmui_imageWithSize:view.bounds.size opaque:NO scale:0 actions:^(CGContextRef contextRef) {
        [view.layer renderInContext:contextRef];
    }];
}

+ (UIImage *)qmui_imageWithView:(UIView *)view afterScreenUpdates:(BOOL)afterUpdates {
    // iOS 7 ????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????render?????????????????????????????????empty???
    CGContextInspectSize(view.bounds.size);
    return [UIImage qmui_imageWithSize:view.bounds.size opaque:NO scale:0 actions:^(CGContextRef contextRef) {
        [view drawViewHierarchyInRect:CGRectMakeWithSize(view.bounds.size) afterScreenUpdates:afterUpdates];
    }];
}

@end
