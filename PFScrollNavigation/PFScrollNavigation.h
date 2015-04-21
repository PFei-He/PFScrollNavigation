//
//  PFScrollNavigation.h
//  PFScrollNavigation
//
//  Created by PFei_He on 15/4/17.
//  Copyright (c) 2015年 PF-Lib. All rights reserved.
//
//  https://github.com/PFei-He/PFScrollNavigation
//
//  vesion: 0.1.0-beta7
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import "UIViewController+PFScrollNavigation.h"

/**
 *  强弱引用转换，用于解决代码块（block）与强引用self之间的循环引用问题
 *  调用方式: `@weakify_self`实现弱引用转换，`@strongify_self`实现强引用转换
 *
 *  示例：
 *  @weakify_self
 *  [obj block:^{
 *  @strongify_self
 *      self.property = something;
 *  }];
 */
#ifndef	weakify_self
    #if __has_feature(objc_arc)
        #define weakify_self autoreleasepool{} __weak __typeof__(self) weakSelf = self;
    #else
        #define weakify_self autoreleasepool{} __block __typeof__(self) blockSelf = self;
    #endif
#endif
#ifndef	strongify_self
    #if __has_feature(objc_arc)
        #define strongify_self try{} @finally{} __typeof__(weakSelf) self = weakSelf;
    #else
        #define strongify_self try{} @finally{} __typeof__(blockSelf) self = blockSelf;
    #endif
#endif

/**
 *  强弱引用转换，用于解决代码块（block）与强引用对象之间的循环引用问题
 *  调用方式: `@weakify(object)`实现弱引用转换，`@strongify(object)`实现强引用转换
 *
 *  示例：
 *  @weakify(object)
 *  [obj block:^{
 *      @strongify(object)
 *      strong_object = something;
 *  }];
 */
#ifndef	weakify
    #if __has_feature(objc_arc)
        #define weakify(object)	autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
    #else
        #define weakify(object)	autoreleasepool{} __block __typeof__(object) block##_##object = object;
    #endif
#endif
#ifndef	strongify
    #if __has_feature(objc_arc)
        #define strongify(object) try{} @finally{} __typeof__(object) strong##_##object = weak##_##object;
    #else
        #define strongify(object) try{} @finally{} __typeof__(object) strong##_##object = block##_##object;
    #endif
#endif

@class PFScrollNavigation;

@protocol PFScrollNavigationDelegate <NSObject>

@optional

#pragma mark -

/**
 *  @brief 导航栏上滑
 *  @param y: Y坐标
 */
- (void)scrollNavigation:(PFScrollNavigation *)scrollNavigation scrollUpWithOriginY:(CGFloat)y;

/**
 *  @brief 导航栏下滑
 *  @param y: Y坐标
 */
- (void)scrollNavigation:(PFScrollNavigation *)scrollNavigation scrollDownWithOriginY:(CGFloat)y;

/**
 *  @brief 停止上滑
 */
- (void)scrollUpDidEndDragging:(PFScrollNavigation *)scrollNavigation;

/**
 *  @brief 停止下滑
 */
- (void)scrollDownDidEndDragging:(PFScrollNavigation *)scrollNavigation;

#pragma mark -

/**
 *  @brief 行高
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  @brief 点击
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  @brief 取消
 */
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface PFScrollNavigation : NSObject <UIScrollViewDelegate, UITableViewDelegate>

///上移阀值，当滚动试图超过阀值，导航栏才开始回收。默认为移动0个像素
@property (nonatomic) CGFloat upThresholdY;

///下移阀值，当滚动试图超过阀值，导航栏才开始重现。默认为移动200个像素
@property (nonatomic) CGFloat downThresholdY;

///代理
@property (nonatomic, weak) id<PFScrollNavigationDelegate> delegate;

#pragma mark -

/**
 *  @brief 重设
 */
- (void)reset;

#pragma mark -

/**
 *  @brief 导航栏上滑
 *  @param y: Y坐标
 */
- (void)scrollUpUsingBlock:(void (^)(CGFloat y))block;

/**
 *  @brief 导航栏下滑
 *  @param y: Y坐标
 */
- (void)scrollDownUsingBlock:(void (^)(CGFloat y))block;

/**
 *  @brief 停止上滑
 */
- (void)scrollUpDidEndDraggingUsingBlock:(void (^)(void))block;

/**
 *  @brief 停止下滑
 */
- (void)scrollDownDidEndDraggingUsingBlock:(void (^)(void))block;

#pragma mark - UITableViewDelegate

/**
 *  @brief 行高
 */
- (void)heightForRowUsingBlock:(CGFloat (^)(UITableView *tableView, NSIndexPath *indexPath))block;

/**
 *  @brief 点击
 */
- (void)didSelectRowUsingBlock:(void (^)(UITableView *tableView, NSIndexPath *indexPath))block;

/**
 *  @brief 取消
 */
- (void)didDeselectRowUsingBlock:(void (^)(UITableView *tableView, NSIndexPath *indexPath))block;

@end
